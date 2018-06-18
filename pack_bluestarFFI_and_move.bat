:: Clear NuGet cache for BluestarFFI and QueryProcessor
rmdir C:\Users\User\.nuget\packages\starcounter.bluestarffi /s
REM rmdir C:\Users\User\.nuget\packages\starcounter.queryprocessor /s

:: Build BluestarFFI
pushd C:\Starcounter\Starcounter.BluestarFFI\src\Starcounter.BluestarFFI
dotnet build

pushd C:\Starcounter\Starcounter.BluestarFFI\nuget
call nuget_pack.bat

:: Move BluestarFFI to level1 and Nova
pushd C:\Starcounter\level1\src\%%STAR_NUGET%%
del Starcounter.BluestarFFI.* /a /s

pushd C:\Starcounter\Starcounter.Nova\%%STAR_NUGET%%
del Starcounter.BluestarFFI.* /a /s

robocopy C:\Starcounter\Starcounter.BluestarFFI\%%STAR_NUGET%% %STAR_NUGET%

REM robocopy C:\Starcounter\Starcounter.BluestarFFI\%%STAR_NUGET%% C:\Starcounter\level1\src\%%STAR_NUGET%% Starcounter.BluestarFFI.2.2.0.nupkg
REM robocopy C:\Starcounter\Starcounter.BluestarFFI\%%STAR_NUGET%% C:\Starcounter\Starcounter.Nova\%%STAR_NUGET%% Starcounter.BluestarFFI.2.2.0.nupkg

:: Build and move Starcounter.QueryProcessor to Nova
REM pushd C:\Starcounter\level1\src\Starcounter.QueryProcessor
REM dotnet restore
REM pushd .\package
REM python .\pack_msbuild.py --config=Release --csproj_full_path=..\Starcounter.QueryProcessor.csproj --nupsec_full_path=./package/Starcounter.QueryProcessor.nuspec --build_number=1.2.3 --star_nuget_dir=C:\Users\User\Desktop\my_nugets