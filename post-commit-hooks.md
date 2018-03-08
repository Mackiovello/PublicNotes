# Post-commit hooks

## Introduction

Post-commit hooks is a way to guarantee that some code is executed after committing a transaction. This is, for example, useful if you want to send out confirmation emails after you've created orders in the database:

```cs
using Starcounter;

[Database]
public class Order
{
    // Properties that are included in an order
}

public class Program
{
    static void Main()
    {
        Hook<Order>.AfterCommitInsert += (sender, id) =>
        {
            // Executes after you commit a new Order
            var order = Db.FromId<Order>(id);
            SendConfirmationEmail(order);
        };

        // Create a new order and trigger the hook
        Db.Transact(() => new Order());
    }

    private static void SendConfirmationEmail(Order order) 
    { 
        // Implementation for sending a confirmation email   
    }
}
```  

With this, you're guaranteed to always send out a confirmation email after someone creates a new order. The hook is triggered no matter where the order is created, as long as its in the same database. 

The fact that post-commit hooks execute after the transaction is the differentiator from normal commit hooks where the hook is executed as part of the transaction.

## API

There are three different post-commit hooks:

```cs
Hook<DatabaseClass>.AfterCommitInsert += (sender, id) => { /* Implementation */ };
Hook<DatabaseClass>.AfterCommitUpdate += (sender, id) => { /* Implementation */ };
Hook<DatabaseClass>.AfterCommitDelete += (sender, id) => { /* Implementation */ };
```

Each event uses the standard `EventHandler<T>` delegate, where `T` is `ulong`. The ID provided to the hook is the unique object ID of the triggering object. The sender is an `object` that can be cast to a `Task` that represents the asyncronous operation for the transaction that triggered the hook.

The `DatabaseClass` in the code sample above is the database class that should trigger the hook when an instance from the class is inserted, updated, or deleted. 

## Invocation

The hook is invoked when the an instance of the specified class is inserted, updated, or deleted. For example, say that we have these four post-commit hooks:

```cs
Hook<Order>.AfterCommitInsert += (sender, id) => Debug.WriteLine("AfterCommitInsert-Order");
Hook<Person>.AfterCommitInsert += (sender, id) => Debug.WriteLine("AfterCommitInsert-Person");
Hook<Person>.AfterCommitUpdate += (sender, id) => Debug.WriteLine("AfterCommitUpdate-Person");
Hook<Person>.AfterCommitDelete += (sender, id) => Debug.WriteLine("AfterCommitDelete-Person");
```

To trigger each of these, we could write something like this:

```cs
// Insert order
Db.Transact(() => new Order());

// Insert person
var person = Db.Transact(() => new Person());

// Update person
Db.Transact(() => person.Name = "Someone");

// Delete person
Db.Transact(() => person.Delete());
```

```
AfterCommitInsert-Order
AfterCommitInsert-Person
AfterCommitUpdate-Person
AfterCommitDelete-Person
```

Notice how each of these operations is in a separate transaction. If we put them in the same transaction, the result is different:

```cs
Db.Transact(() =>
{
    // Insert order
    new Order();

    // Insert person
    var person = new Person();

    // Update person
    person.Name = "Someone";

    // Delete person
    person.Delete();
});
```

```
AfterCommitInsert-Order
```

This code only triggers the `AfterCommitInsert` hook for the `Order` class. The reason for this is that the hooks are triggered based on the final result of the transaction, not the individual operations themselves. The only state change after the transaction was that an `Order` was created since the `Person` was deleted in the transaction. 

Post-commit hooks trigger multiple times if there are several operations in one transaction:

```cs
Db.Transact(() =>
{
    new Person();
    new Person();
}); 
```

```
AfterCommitInsert-Person
AfterCommitInsert-Person
```

If you invoke a post-commit hook from inside a commit hook, it runs in an infinite loop until you run out of memory or something else stops the execution:

```cs
// This will cause an infinite loop once invoked
Hook<Order>.AfterCommitInsert += (sender, id) =>
{
    Db.Transact(() => new Order());
};
```

Also, post-commit hooks are not guaranteed to execute right after the transaction. It's possible that another transaction executes before executing the hook. Thus, you can't assume that the database state that existed after the transaction that triggered the hook is still the same:

```cs
Hook<Person>.AfterCommitInsert += (sender, id) => 
{
    var person = Db.FromId<Person>(id);
    // Here, person can be null
};

var person = Db.Transact(() => new Person());

// This may run before the hook, it's 
// unlikely but possible
Db.Transact(() => person.Delete());
```

If another thread deletes the person between the time the transaction completes and before the hook is invoked, the object will no longer exist.

## Durability

Post-commit hooks are executed after the transaction is committed to memory but before the commit is flushed to the transaction log. This means that the transaction is not guaranteed to be durable:

```cs
Hook<Order>.AfterCommitInsert += (sender, id) =>
{
    // Executes after you commit a new Order
    var order = Db.FromId<Order>(id);
    SendConfirmationEmail(order);

    // POWER OUTAGE
};

// Create a new order and trigger the hook
Db.Transact(() => new Order());
```

If the transaction with the new order has not been flushed to the transaction log where the power outage happens, then the customer gets the confirmation email but the order has not been stored in the database.

You can guarantee that the transaction is durable by awaiting the task that is sent through the `sender` argument:

```cs
Hook<Order>.AfterCommitInsert += (sender, id) =>
{
    var task = (System.Threading.Tasks.Task)sender;

    // Flush the transaction to the log
    task.Wait();

    // The transaction is now durable
};
```

## Registering hooks

Hooks can be registered almost anywhere. A common practice is to have them in a specific class with a `Register` method and invoke this method in the entry point:

```cs
public static class PostCommitHooks
{
    public static void Register()
    {
        Hook<Order>.AfterCommitInsert += (sender, id) => { /* */ };
        // The other post-commit hooks
    }
}

public class Program
{
    static void Main()
    {
        PostCommitHooks.Register();
    }
}
```

There are two of things to avoid when registering post-commit hooks: don't register them in a transaction or in another hook.

The reason for this is that the transaction may have to restart if there's a conflict which would register the hook several times. If you register it in another hook the inner hook will be registered every time the outer hook is called. 

If you register a hook many times, it's called as many times as its registered:

```cs
public class Program
{
    static void Main()
    {
        for (int i = 0; i < 3; i++)
        {
            Hook<Order>.AfterCommitInsert += (sender, id) => Debug.WriteLine("In insert hook");
        }

        Db.Transact(() => new Order());
    }
}
```

``` 
In insert hook
In insert hook
In insert hook
```

## Advanced: post-commit hooking using a custom scheduler
Starcounter uses its default scheduling mechanism to schedule tasks that the post-commit hooks execute in. Currently, that's an instance of `DbTaskScheduler`.

Using a complementary API, it's possible to provide a custom scheduler when you register post-commit hooks, forcing Starcounter to utilize that instead of the built-in default.

The example below shows a custom task scheduler that extends the Starcounter database task scheduler, executing a callback every time the hook in which it is installed in is queued:

 ```cs
using Starcounter;
using System;
using System.Threading.Tasks;

[Database]
public class Order
{
    // Properties that are included in an order
}

public class Program
{
    static void Main()
    {
        Hook<Order>.OnAfterCommitInsert(
            (sender, id) => { /* */ }, 
            new NotifyingScheduler(() => Console.Write("A task was scheduled")));

        Db.Transact(() => new Order());
    }
}

class NotifyingScheduler : DbTaskScheduler
{
    readonly Action callback;

    public NotifyingScheduler(Action action)
    {
        callback = action;
    }

    protected override void QueueTask(Task task)
    {
        base.QueueTask(task);
        callback?.Invoke();
    }
}
```

Corresponding APIs are available for all other hooks:
* `Hook<DatabaseClass>.OnAfterCommitInsert`
* `Hook<DatabaseClass>.OnAfterCommitUpdate`
* `Hook<DatabaseClass>.OnAfterCommitDelete`