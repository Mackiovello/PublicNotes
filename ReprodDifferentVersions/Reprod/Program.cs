using System;
using System.Reflection;
using Starcounter.Nova;
using Starcounter.Nova.Hosting;
using System.IO;
using Starcounter.Nova.Hosting.BindingExtensions;

namespace Reprod1
{
    [Database]
    public class Thing
    {
        public virtual string FirstName { get; set; }
        public virtual string LastName { get; set; }
    }

    class Program
    {
        static void Main(string[] args)
        {
            var databaseName = "MyDatabase";

            if (Directory.Exists(databaseName))
            {
                Directory.Delete(databaseName, true);
            }

            Directory.CreateDirectory(databaseName);
            Starcounter.Nova.Bluestar.ScCreateDb.Execute(databaseName);

            using (var appHost = new AppHostBuilder()
                .UseDatabase(databaseName)
                .UseTypes(typeSelector => typeSelector.AddTypes(GetTypes()))
                .Build())
            {
                appHost.Start();
            }
        }

        private static Type[] GetTypes()
        {
            return Assembly.LoadFrom("Reprod1/bin/Debug/netcoreapp2.1/Reprod1.dll").GetTypes();
        }
    }
}
