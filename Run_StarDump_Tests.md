# Investigate broken StarDump tests

The StarDump system tests are failing: https://teamcity.starcounter.org/viewLog.html?buildId=47230&tab=buildResultsDiv&buildTypeId=Starcounter_DevelopDailyWindowsExtended. The error message, on seemingly all of the tests is "The number of rows in the different test databases are not the same for "StarDumpStringTable" table", although on different tables.

The instructions from Konstantin, the author of StarDump, says:

> Okay, please kill starcounter, start it back.

> Then delete all of the database related to StarDump testing.

> Also clean up the unloaded dumps.

> And then try again.

> make sure that you have the latest 2.4 and the latest Nova.
    Then try to run `develop` tests from StarDump.
    If that doesn't work, then it's really weird.

## Steps

* Download the Starcounter version from the develop release channel that was released the february 14th 2018; 
2.4.0.5027.

* Install Starcounter 2.4.0.5027.

* Run `git clean -dfX` in the `StarDump` directory to delete all the `obj` and `bin` directories:

```
PS C:\Starcounter\StarDump> git clean -dfX
Removing src/StarDump.Common/bin/
Removing src/StarDump.Common/obj/
Removing src/StarDump.Core/bin/
Removing src/StarDump.Core/obj/
Removing src/StarDump/bin/
Removing src/StarDump/obj/
Removing src/StarDump/sccore.log
Removing test/StarDump.System.Tests/bin/
Removing test/StarDump.System.Tests/obj/
Removing test/StarDump.Unit.Tests/obj/
```

* Run `git pull` in the `Starcounter.Nova` directory:

```
PS C:\Starcounter\Starcounter.Nova> git pull
Already up to date.
```

* Create NuGet packages from Nova by running the `Starcounter.Nova/nuget/nuget_pack.bat` script.

* Run `find . \( -iname "*.nupkg" \) -print0 | xargs -0 cp -t ../../Users/User/Desktop/nuget_packages/` to copy all the Nova NuGet packages to the `nuget_packages` directory.

* In Visual Studio, add the `nuget_packages` directory as a NuGet source and put it at the top of the sources.

* Change the projects to use the packages from `nuget_packages`.

* To confirm that the package used is the local package, check that the `Data published` of the package is the data the package was packaged.

* Validate that you're on branch develop of StarDump

* Run `python .\stardump_system_test.py` in the `StarDump/scripts` directory.

* Tests fail:

```
StarDump.System.Tests.UnloadTablesArgumentTestSet.UnloadDatabaseTest [FAIL]
StarDump unload execution failed.
StarDump calls in made during this TestSet:
    reload --database=stardumpunloadtablesargument --file=C:\Starcounter\StarDump\test\StarDump.System.Tests\bin\Debug\netcoreapp2.0\Resources\DefaultTestDump.sqlite3
    unload --database=stardumpunloadtablesargument --file=C:\Starcounter\StarDump\test\StarDump.System.Tests\bin\Debug\netcoreapp2.0\Resources\UnloadTablesArgumentTestDump.sqlite3 --unloadtables="StarDumpTestDumpData.StarDumpDoubleTable StarDumpTestDumpData.StarDumpIntTable"

Expected: True
Actual:   False
Stack Trace:
C:\Starcounter\StarDump\test\StarDump.System.Tests\Collections\BaseTest.cs(57,0): at StarDump.System.Tests.BaseTest`1.UnloadDatabase()
C:\Starcounter\StarDump\test\StarDump.System.Tests\TestSets\UnloadTablesArgumentTestSet.cs(40,0): at StarDump.System.Tests.UnloadTablesArgumentTestSet.UnloadDatabaseTest()
StarDump.System.Tests.UnloadTablesArgumentTestSet.CheckStarDumpDatabaseExistenceAndOpenSqlConnectionTest
StarDump.System.Tests.UnloadTablesArgumentTestSet.CheckStarDumpDatabaseExistenceAndOpenSqlConnectionTest [FAIL]
C:\Starcounter\StarDump\test\StarDump.System.Tests\bin\Debug\netcoreapp2.0\Resources\UnloadTablesArgumentTestDump.sqlite3 test file does not exist.
StarDump calls in made during this TestSet:
    reload --database=stardumpunloadtablesargument --file=C:\Starcounter\StarDump\test\StarDump.System.Tests\bin\Debug\netcoreapp2.0\Resources\DefaultTestDump.sqlite3
    unload --database=stardumpunloadtablesargument --file=C:\Starcounter\StarDump\test\StarDump.System.Tests\bin\Debug\netcoreapp2.0\Resources\UnloadTablesArgumentTestDump.sqlite3 --unloadtables="StarDumpTestDumpData.StarDumpDoubleTable StarDumpTestDumpData.StarDumpIntTable"

Expected: True
Actual:   False
Stack Trace:
C:\Starcounter\StarDump\test\StarDump.System.Tests\Collections\BaseTest.cs(70,0): at StarDump.System.Tests.BaseTest`1.CheckStarDumpDatabaseExistenceAndOpenSqlConnection()
C:\Starcounter\StarDump\test\StarDump.System.Tests\TestSets\UnloadTablesArgumentTestSet.cs(46,0): at StarDump.System.Tests.UnloadTablesArgumentTestSet.CheckStarDumpDatabaseExistenceAndOpenSqlConnectionTest()
StarDump.System.Tests.UnloadTablesArgumentTestSet.BoolTests
StarDump.System.Tests.UnloadTablesArgumentTestSet.BoolTests [FAIL]
System.InvalidOperationException: ExecuteReader can only be called when the connection is open.
    at Microsoft.Data.Sqlite.SqliteCommand.ExecuteReader(CommandBehavior behavior)
    at StarDump.System.Tests.BaseTestCollection`1.ReadSqlData(SqliteConnection cn, String tableName) in C:\Starcounter\StarDump\test\StarDump.System.Tests\Collections\BaseTestCollection.cs:line 56
StarDump calls in made during this TestSet:
    reload --database=stardumpunloadtablesargument --file=C:\Starcounter\StarDump\test\StarDump.System.Tests\bin\Debug\netcoreapp2.0\Resources\DefaultTestDump.sqlite3
    unload --database=stardumpunloadtablesargument --file=C:\Starcounter\StarDump\test\StarDump.System.Tests\bin\Debug\netcoreapp2.0\Resources\UnloadTablesArgumentTestDump.sqlite3 --unloadtables="StarDumpTestDumpData.StarDumpDoubleTable StarDumpTestDumpData.StarDumpIntTable"

Expected: True
Actual:   False
Stack Trace:
C:\Starcounter\StarDump\test\StarDump.System.Tests\Collections\BaseTestCollection.cs(65,0): at StarDump.System.Tests.BaseTestCollection`1.ReadSqlData(SqliteConnection cn, String tableName)
C:\Starcounter\StarDump\test\StarDump.System.Tests\Collections\BaseTest.cs(414,0): at StarDump.System.Tests.BaseTest`1.Bool(Boolean isEmpty)
C:\Starcounter\StarDump\test\StarDump.System.Tests\TestSets\UnloadTablesArgumentTestSet.cs(118,0): at StarDump.System.Tests.UnloadTablesArgumentTestSet.BoolTests()
StarDump.System.Tests.UnloadTablesArgumentTestSet.ByteTests
StarDump.System.Tests.UnloadTablesArgumentTestSet.ByteTests [FAIL]
System.InvalidOperationException: ExecuteReader can only be called when the connection is open.
    at Microsoft.Data.Sqlite.SqliteCommand.ExecuteReader(CommandBehavior behavior)
    at StarDump.System.Tests.BaseTestCollection`1.ReadSqlData(SqliteConnection cn, String tableName) in C:\Starcounter\StarDump\test\StarDump.System.Tests\Collections\BaseTestCollection.cs:line 56
StarDump calls in made during this TestSet:
    reload --database=stardumpunloadtablesargument --file=C:\Starcounter\StarDump\test\StarDump.System.Tests\bin\Debug\netcoreapp2.0\Resources\DefaultTestDump.sqlite3
    unload --database=stardumpunloadtablesargument --file=C:\Starcounter\StarDump\test\StarDump.System.Tests\bin\Debug\netcoreapp2.0\Resources\UnloadTablesArgumentTestDump.sqlite3 --unloadtables="StarDumpTestDumpData.StarDumpDoubleTable StarDumpTestDumpData.StarDumpIntTable"

Expected: True
Actual:   False
Stack Trace:
C:\Starcounter\StarDump\test\StarDump.System.Tests\Collections\BaseTestCollection.cs(65,0): at StarDump.System.Tests.BaseTestCollection`1.ReadSqlData(SqliteConnection cn, String tableName)
C:\Starcounter\StarDump\test\StarDump.System.Tests\Collections\BaseTest.cs(354,0): at StarDump.System.Tests.BaseTest`1.Byte(Boolean isEmpty)
C:\Starcounter\StarDump\test\StarDump.System.Tests\TestSets\UnloadTablesArgumentTestSet.cs(106,0): at StarDump.System.Tests.UnloadTablesArgumentTestSet.ByteTests()
StarDump.System.Tests.UnloadTablesArgumentTestSet.DateTimeTests
```

The root of the error seems to be here:

```
Executed with exit code "10024": staradmin.exe stop db stardumpmigrationtest
```

The code "10024" is likely about the host not running.
