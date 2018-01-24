# Set up the development environment for Nova

## Resolve Bluestar

Nova depends on Bluestar - the Starcounter kernel. The Bluestar dependency is resolved with the environment variable `StarcounterBin`. You can either build Bluestar yourself or download Starcounter on .NET Framework and use its Bluestar version:

1. Download a version of Starcounter on .NET Framework from http://downloads.starcounter.com/download. The installer will set the `StarcounterBin` environment variable to where the program files are installed, by default `C:\Program Files\Starcounter`.
2. Build level0 locally and set the `StarcounterBin` environment variable to the directory where the binaries are stored. The instructions for building level0 are in the level0 repository: https://github.com/Starcounter/level0

Keep in mind that each Nova version only guarantees compatibility with one Bluestar version. This version is written down in the release notes on GitHub: https://github.com/Starcounter/Starcounter.Core/releases.

