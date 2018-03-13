# Make Nova persistence of Linux

Issue: https://github.com/Starcounter/level0/issues/596

## Initial state on Ubuntu

* Clean Starcounter.Nova on this commit: https://github.com/Starcounter/Starcounter.Nova/commit/a78d6c380519428f3afa0ec927e1b205db5c50bd
* Clean level0 on this commit: https://github.com/Starcounter/level0/commit/e844582a1d98b53a0bb335820e6313a16e24f318

## Steps

1. Add this line to `runtime.ubuntu.16.04-x64.runtime.native.Starcounter.Bluestar.nuspec` in the `nuget` directory in level0:

```
<file src="make/x64/Release/sccreatedb*" target="runtimes/ubuntu.16.04-x64/native" />
```

2. Build level0 

```
python level0/teamcity.py --config=Release
``` 

Result:

```
82% tests passed, 8 tests failed out of 45

Total Test time (real) =  44.88 sec

The following tests FAILED:
         10 - kernel_functest (Failed)
         13 - metalayer_functest (Failed)
         39 - sqlprocessor_functest (Failed)
         40 - sqlprocessor_unittest (Failed)
         41 - sql_query_cachetest (Failed)
         42 - ddl_functest (Failed)
         45 - sql_regression_testing (Failed)
         47 - sqltypebinder_testing (Failed)
Errors while running CTest
-- Publishing CTest output:
Outputing test xml file: /home/Mackiovello/level0/build/Testing/20180313-1206/Test.xml
##teamcity[importData type='ctest' path='/home/Mackiovello/level0/build/Testing/20180313-1206/Test.xml']
-- CTest finished with error code: 8
```

3. Create the NuGet package

```
$ ./nuget_pack.sh
NuGet packing using version number 2.4.0-pre-012428
Attempting to build package from 'runtime.ubuntu.16.04-x64.runtime.native.Starcounter.Bluestar.nuspec'.

Id: runtime.ubuntu.16.04-x64.runtime.native.Starcounter.Bluestar
Version: 2.4.0-pre-012428
Authors: starcounter
Description: Native Ubuntu Linux x64 binaries for Starcounter Bluestar.
Dependencies: None

Added file 'runtimes/ubuntu.16.04-x64/native/clang++'.
Added file 'runtimes/ubuntu.16.04-x64/native/ld.lld'.
Added file 'runtimes/ubuntu.16.04-x64/native/libbehemoth.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/libloader.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/liblog_writer_client.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/liblogreader.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/liboptlogreader.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/libsccoredb.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/libsccoredbm.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/libsccoreerr.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/libsccorelog.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/libscdbmetalayer.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/libscllvm.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/libscsqlparser.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/libscsqlprocessor.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/libsynccommit.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/libTurboText_en-GB_4.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/libTurboText_en-GB-CI-AS_4.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/libTurboText_nb-NO_4.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/libTurboText_ru-RU_4.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/libTurboText_sv-SE_4.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/libTurboText_x-tid_4.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/libwriter.so'.
Added file 'runtimes/ubuntu.16.04-x64/native/sccreatedb'.
Added file 'runtimes/ubuntu.16.04-x64/native/scdata'.
Added file 'runtimes/ubuntu.16.04-x64/native/Starcounter.OptimalBinTree.dll'.

Successfully created package '/home/Mackiovello/level0/nuget/runtime.ubuntu.16.04-x64.runtime.native.Starcounter.Bluestar.2.4.0-pre-012428.nupkg'.
Attempting to build package from 'runtime.native.Starcounter.Bluestar.nuspec'.

Id: runtime.native.Starcounter.Bluestar
Version: 2.4.0-pre-012428
Authors: starcounter
Description: Native binaries for Starcounter Bluestar.
Dependencies: runtime.win7-x64.runtime.native.Starcounter.Bluestar (≥ 2.4.0-pre-012428), runtime.ubuntu.16.04-x64.runtime.native.Starcounter.Bluestar (≥ 2.4.0-pre-012428)

Added file 'content/Starcounter/metaschema.json'.

Successfully created package '/home/Mackiovello/level0/nuget/runtime.native.Starcounter.Bluestar.2.4.0-pre-012428.nupkg'.
```

4. Move to the `%STAR_NUGET%` directory in `Starcounter.Nova`

```
$ mv nuget/runtime.native.Starcounter.Bluestar.2.4.0-pre-012428.nupkg ../Starcounter.Nova/%STAR_NUGET%/
$ mv nuget/runtime.ubuntu.16.04-x64.runtime.native.Starcounter.Bluestar.2.4.0-pre-012428.nupkg ../Starcounter.Nova/%STAR_NUGET%/
```

5. Add add a reference to the NuGet package in MinimalApp

```xml
<ItemGroup>
    <PackageReference Include="runtime.native.Starcounter.Bluestar" Version="2.4.0-*" />
</ItemGroup>
```

5. Build and run `MinimalApp`

```
$ dotnet build; dotnet run --framework=netcoreapp2.0

/home/Mackiovello/Starcounter.Nova/samples/MinimalApp/MinimalApp.csproj : error NU1102: Unable to find package runtime.win7-x64.runtime.native.Starcounter.Bluestar with version (>= 2.4.0-pre-012428)
/home/Mackiovello/Starcounter.Nova/samples/MinimalApp/MinimalApp.csproj : error NU1102:   - Found 4 version(s) in Starcounter [ Nearest version: 2.4.0-pre-012099 ]
/home/Mackiovello/Starcounter.Nova/samples/MinimalApp/MinimalApp.csproj : error NU1102:   - Found 0 version(s) in STAR_NUGET
/home/Mackiovello/Starcounter.Nova/samples/MinimalApp/MinimalApp.csproj : error NU1102:   - Found 0 version(s) in nuget.org
/home/Mackiovello/Starcounter.Nova/samples/MinimalApp/MinimalApp.csproj : error NU1102:   - Found 0 version(s) in cli-deps
/home/Mackiovello/Starcounter.Nova/samples/MinimalApp/MinimalApp.csproj : error NU1102:   - Found 0 version(s) in dotnet-buildtools
/home/Mackiovello/Starcounter.Nova/samples/MinimalApp/MinimalApp.csproj : error NU1102:   - Found 0 version(s) in dotnet-core
/home/Mackiovello/Starcounter.Nova/samples/MinimalApp/MinimalApp.csproj : error NU1102: Unable to find package runtime.win7-x64.runtime.native.Starcounter.Bluestar with version (>= 2.4.0-pre-012428)
/home/Mackiovello/Starcounter.Nova/samples/MinimalApp/MinimalApp.csproj : error NU1102:   - Found 4 version(s) in Starcounter [ Nearest version: 2.4.0-pre-012099 ]
/home/Mackiovello/Starcounter.Nova/samples/MinimalApp/MinimalApp.csproj : error NU1102:   - Found 0 version(s) in STAR_NUGET
/home/Mackiovello/Starcounter.Nova/samples/MinimalApp/MinimalApp.csproj : error NU1102:   - Found 0 version(s) in nuget.org
/home/Mackiovello/Starcounter.Nova/samples/MinimalApp/MinimalApp.csproj : error NU1102:   - Found 0 version(s) in cli-deps
/home/Mackiovello/Starcounter.Nova/samples/MinimalApp/MinimalApp.csproj : error NU1102:   - Found 0 version(s) in dotnet-buildtools
/home/Mackiovello/Starcounter.Nova/samples/MinimalApp/MinimalApp.csproj : error NU1102:   - Found 0 version(s) in dotnet-core

The build failed. Please fix the build errors and run again.
```

6. Build and create NuGet package on windows

```
$ ./build.bat Release
$ ./nuget_pack.bat
Successfully created package 'C:\Starcounter\level0\nuget\runtime.native.Starcounter.Bluestar.2.4.0-pre-012428.nupkg'.
```

7. Move the NuGet packages to the `%STAR_NUGET%` directory of `Starcounter.Nova` on Ubuntu

The `%STAR_NUGET%` directory now has four files:

```
~/Starcounter.Nova/%STAR_NUGET%$ ls
README.md
runtime.native.Starcounter.Bluestar.2.4.0-pre-012428.nupkg
runtime.ubuntu.16.04-x64.runtime.native.Starcounter.Bluestar.2.4.0-pre-012428.nupkg
runtime.win7-x64.runtime.native.Starcounter.Bluestar.2.4.0-pre-012428.nupkg
```

8. Build and run `MinimalApp`

```
dotnet build; dotnet run --framework=netcoreapp2.0

Current value of StarcounterBin=""
Current value of STAR_QP=""
Current query processor before Start() is "None"
Starcounter permanent storage creation utility.
Copyright (C) Starcounter AB 2007-2016. All rights reserved.


Unhandled Exception: System.DllNotFoundException: Unable to load DLL 'sccoredb': The specified module or one of its dependencies could not be found.
 (Exception from HRESULT: 0x8007007E)
   at Starcounter.Nova.Interop.sccoredb.star_set_system_callbacks(sccoredb_callbacks& pcallbacks)
   at Starcounter.Nova.Hosting.Connection.ConnectToDataManager(StarcounterOptions options) in /home/Mackiovello/Starcounter.Nova/src/Starcounter.Nova.Hosting/Connection.cs:line 189
   at Starcounter.Nova.Hosting.Connection.Start() in /home/Mackiovello/Starcounter.Nova/src/Starcounter.Nova.Hosting/Connection.cs:line 77
   at Starcounter.Nova.Hosting.DefaultAppHost.Start() in /home/Mackiovello/Starcounter.Nova/src/Starcounter.Nova.Hosting/DefaultAppHost.cs:line 26
   at MinimalApp.Program.Main(String[] args) in /home/Mackiovello/Starcounter.Nova/samples/MinimalApp/Program.cs:line 299
```

9. Set `StarcounterBin`

```
$ export StarcounterBin=/home/Mackiovello/level0/make/x64/Release/
```

10. Set `LD_LIBRARY_PATH`

export LD_LIBRARY_PATH=$StarcounterBin

11. Build and run MinimalApp

```
$ dotnet build; dotnet run --framework=netcoreapp2.0
Microsoft (R) Build Engine version 15.3.409.57025 for .NET Core
Copyright (C) Microsoft Corporation. All rights reserved.

  Starcounter.Nova.Interop -> /home/Mackiovello/Starcounter.Nova/src/Starcounter.Nova.Interop/bin/Debug/netstandard1.6/Starcounter.Nova.Interop.dll
  Starcounter.Nova -> /home/Mackiovello/Starcounter.Nova/src/Starcounter.Nova/bin/Debug/netstandard1.6/Starcounter.Nova.dll
  Starcounter.Nova.Error -> /home/Mackiovello/Starcounter.Nova/src/Starcounter.Nova.Error/bin/Debug/netstandard1.6/Starcounter.Nova.Error.dll
  Starcounter.Nova.Metadata -> /home/Mackiovello/Starcounter.Nova/src/Starcounter.Nova.Metadata/bin/Debug/netstandard1.6/Starcounter.Nova.Metadata.dll
  Starcounter.Nova.X6Decimal -> /home/Mackiovello/Starcounter.Nova/src/Starcounter.Nova.X6Decimal/bin/Debug/netstandard1.6/Starcounter.Nova.X6Decimal.dll
  Starcounter.Nova.Bluestar -> /home/Mackiovello/Starcounter.Nova/src/Starcounter.Nova.Bluestar/bin/Debug/netstandard1.6/Starcounter.Nova.Bluestar.dll
  Starcounter.Nova.Database -> /home/Mackiovello/Starcounter.Nova/src/Starcounter.Nova.Database/bin/Debug/netstandard1.6/Starcounter.Nova.Database.dll
  Starcounter.Nova.Binding -> /home/Mackiovello/Starcounter.Nova/src/Starcounter.Nova.Binding/bin/Debug/netstandard1.6/Starcounter.Nova.Binding.dll
  Starcounter.Nova.Level1QPBridge -> /home/Mackiovello/Starcounter.Nova/src/Starcounter.Nova.Level1QPBridge/bin/Debug/netstandard1.6/Starcounter.Nova.Level1QPBridge.dll
  Starcounter.Nova.Query -> /home/Mackiovello/Starcounter.Nova/src/Starcounter.Nova.Query/bin/Debug/netstandard1.6/Starcounter.Nova.Query.dll
  Starcounter.Nova.Options -> /home/Mackiovello/Starcounter.Nova/src/Starcounter.Nova.Options/bin/Debug/netstandard1.6/Starcounter.Nova.Options.dll
  Starcounter.Nova.Hosting -> /home/Mackiovello/Starcounter.Nova/src/Starcounter.Nova.Hosting/bin/Debug/netstandard1.6/Starcounter.Nova.Hosting.dll
  Starcounter.Nova.AspNetCore -> /home/Mackiovello/Starcounter.Nova/src/Starcounter.Nova.AspNetCore/bin/Debug/netstandard1.6/Starcounter.Nova.AspNetCore.dll
  MinimalApp -> /home/Mackiovello/Starcounter.Nova/samples/MinimalApp/bin/Debug/netcoreapp2.0/MinimalApp.dll

Build succeeded.
    0 Warning(s)
    0 Error(s)

Time Elapsed 00:00:33.45
Current value of StarcounterBin="/home/Mackiovello/level0/make/x64/Release/"
Current value of STAR_QP=""
Current query processor before Start() is "None"
Starcounter permanent storage creation utility.
Copyright (C) Starcounter AB 2007-2016. All rights reserved.


Unhandled Exception: System.DllNotFoundException: Unable to load DLL 'sccoredb': The specified module or one of its dependencies could not be found.
 (Exception from HRESULT: 0x8007007E)
   at Starcounter.Nova.Interop.sccoredb.star_set_system_callbacks(sccoredb_callbacks& pcallbacks)
   at Starcounter.Nova.Hosting.Connection.ConnectToDataManager(StarcounterOptions options) in /home/Mackiovello/Starcounter.Nova/src/Starcounter.Nova.Hosting/Connection.cs:line 189
   at Starcounter.Nova.Hosting.Connection.Start() in /home/Mackiovello/Starcounter.Nova/src/Starcounter.Nova.Hosting/Connection.cs:line 77
   at Starcounter.Nova.Hosting.DefaultAppHost.Start() in /home/Mackiovello/Starcounter.Nova/src/Starcounter.Nova.Hosting/DefaultAppHost.cs:line 26
   at MinimalApp.Program.Main(String[] args) in /home/Mackiovello/Starcounter.Nova/samples/MinimalApp/Program.cs:line 299
```