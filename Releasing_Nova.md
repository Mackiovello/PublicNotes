## Releasing a new version of Nova

### Test against Bluestar

When releasing a new version of Nova, it should be released together with a specific version of Bluestar. Thus, you need to test against Bluestar before releasing.

1. Clone level0: `git clone https://github.com/Starcounter/level0.git`. If you already have level0, do a `git pull` to have the latest version on the `develop` branch
2. Setup the environment to be able to build level0 by following the instructions here: https://github.com/Starcounter/level0#windows-requirements
3. Build level0 by running `cmake_vs.bat Release`. This has to be run as an administrator
4. Set the `StarcounterBin` environment variable to the directory where the level0 binaries are, such as `C:\Starcounter\level0\msbuild\x64\Release`
5. Clone Nova: `git clone https://github.com/Starcounter/Starcounter.Core.git`
6. Execute `Starcounter.Core/test/run_all_tests.bat`
7. If the tests don't pass, they have to be fixed before proceding with the following steps

For Linux, the steps are the same, except for step 2, 3, and 6.

For step 2 and 3, use these instructions to setup the environment and build: https://github.com/Starcounter/AdminTrack/blob/master/DevelopmentInstructions/development_setup_linux.md and https://github.com/Starcounter/level0#build-on-linux.

For step 6, execute `run_all_tests.sh` instead of `run_all_tests.bat`.

The tests for Linux and Windows have to pass in order to continue.

### Test against Starcounter.QueryProcessor

Nova also relies on the NuGet package Starcounter.QueryProcessor. The source for that package is in level1. To test Nova against Starcounter.QueryProcessor, clone the develop branch of level1, [setup the development environment](https://github.com/Starcounter/AdminTrack/blob/master/DevelopmentInstructions/development_setup_windows.md#starcounter-build-setup), and build the Starcounter.QueryProcessor project. This will create the `Starcounter.QueryProcessor.dll` file in the binaries directory. 

Remove the reference to the Starcounter.QueryProcessor package and replace with the DLL from level1. Then, build and run the tests.

This package works the same as with Bluestar - it has to be released manually. Consult with the query processing team to release a new version of this package.

### Test against Starcounter.ErrorCodes

Nova also relies on the NuGet package Starcounter.ErrorCodes. To test against this package, follow the same steps as for testing against Starcounter.QueryProcessor except that this package is in its own repository: https://github.com/Starcounter/Starcounter.ErrorCodes. Follow the [build instructions](https://github.com/Starcounter/Starcounter.ErrorCodes), exchange the reference in Nova, and run the tests in Nova.

This package works the same as with Bluestar - it has to be released manually. Consult with the platform team, or the current maintainer of the project to release a new version of this package.

### Publish a new version of Bluestar

Nova relies on the NuGet package `runtime.native.Starcounter.Bluestar`. This package is manually released with new versions of Nova. Bluestar has to be published for both Linux and Windows. If you've built Bluestar, the only thing you need to do is to run `nuget_pack_and_push.bat` for Windows and `nuget_pack_and_push.sh` for Linux.

Write down the version number of the pushed NuGet package - it will be used when writing the release notes.

### Publish a new version of Nova

1. In `global.props` in the root of the Starcounter.Core directory increment `VersionPrefix` according to semver 2.0
2. Create a commit with only the change from step 1, set the message to the version, such as v0.8.0-alpha
3. Add a tag to the commit: `git tag -a "v0.8.0-alpha" -m "v0.8.0-alpha"`
4. Pack and publish to NuGet by running `pack_and_push.bat`
5. Push the tag and commit: `git push && git push --tags`
6. Write a release on GitHub and note that it's compatible with the specific version of Bluestar that you wrote down earlier.