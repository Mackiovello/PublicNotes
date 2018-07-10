using System;
using Starcounter.Nova;
using Starcounter.Nova.Hosting;
using System.IO;

namespace Reprod
{
    [Database]
    public class Person
    {
        public virtual string FirstName { get; set; }
        public virtual string LastName { get; set; }
    }

    [Database]
    public class Another
    {
        public virtual string Value { get; set; }
    }

    class Program
    {
        static void Main(string[] args)
        {
            var databaseName = "MyDatabase";

            if (Directory.Exists(databaseName))
            {
                Directory.Delete(databaseName);
            }

            Directory.CreateDirectory(databaseName);
            Starcounter.Nova.Bluestar.ScCreateDb.Execute(databaseName);

            using (var appHost = new AppHostBuilder().UseDatabase(databaseName).Build())
            {
                appHost.Start();

                Db.Transact(() =>
                {
                    var p = Db.Insert<Person>();
                    p.FirstName = "Jane";
                    p.LastName = "Doe";

                    var o = Db.Insert<Another>();
                    o.Value = "Something";
                });

                Db.Transact(() =>
                {
                    var result = Db.SQL<Person>("SELECT p FROM Reprod.Person p").First;
                    System.Console.WriteLine(result.FirstName);
                });
            }
        }
    }
}
