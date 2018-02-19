# Following Docker instructions

Trying to follow the instructions here: https://github.com/Starcounter/Starcounter.Docker.Windows/blob/master/README.md

* Install Docker from https://docs.docker.com/docker-for-windows/install/#download-docker-for-windows
* Run the Docker "Hello-world" to test the installation: https://docs.docker.com/get-started/#test-docker-installation
* Execute this command:

```
docker run -it --storage-opt "size=50GB" --cpu-count 8 -m 16g -p 8080:8080 -p 8181:8181 -e "StarcounterDataDir=C:/Starcounter/shared/Personal" -v %~dp0ServerSampleData:C:/Starcounter/shared starcounter/docker.windows.sc.2.3.2
```

**There's a "cmd" at the end of the command above in the README. Did not include it since it looked like a typo** 

* Get an error:

```
"--cpu-count" requires the Docker daemon to run on windows, but the Docker daemon is running on linux
```

* Run `docker pull starcounter/docker.windows.sc.2.3.2`

* Get an error:

```
Error response from daemon: pull access denied for starcounter/docker.windows.sc.2.3.2, repository does not exist or may require 'docker login'
```

* Execute `& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchDaemon` in PowerShell

* Execute this command again:

```
docker run -it --storage-opt "size=50GB" --cpu-count 8 -m 16g -p 8080:8080 -p 8181:8181 -e "StarcounterDataDir=C:/Starcounter/shared/Personal" -v %~dp0ServerSampleData:C:/Starcounter/shared starcounter/docker.windows.sc.2.3.2
```

* Get an error:

```
Unable to find image 'starcounter/docker.windows.sc.2.3.2:latest' locally
C:\Program Files\Docker\Docker\Resources\bin\docker.exe: Error response from daemon: pull access denied for starcounter/docker.windows.sc.2.3.2, repository does not exist or may require 'docker login'.
See 'C:\Program Files\Docker\Docker\Resources\bin\docker.exe run --help'.
```

* Get instructions from Urban that I need to build the container first.

* At this point, the `StarcounterBin` environment variable is set to `C:\Starcounter\level0\msbuild\x64\Release`, the place for locally built level0 binaries.

* Install Starcounter-Develop-2.4.0.5027, `StarcounterBin` is now set to `C:\Program Files\Starcounter`.

* Create a `copy.bat` file on the desktop:

```
rd /s /q "%~dp0Docker\Bin"
xcopy /s /e "%StarcounterBin%" "%~dp0Docker\Bin\"

:: Replace Personal.xml
del "%~dp0Docker\Bin\Configuration\Personal.xml"
xcopy "%~dp0Personal.xml" "%~dp0Docker\Bin\Configuration\"
```

* Create a `build.bat` file on the desktop:

```
@echo off
for /F "tokens=* USEBACKQ" %%F IN (`git rev-parse HEAD`) DO (
    set GitCommitHash=%%F
)

for /F "tokens=* USEBACKQ" %%F IN (`%~dp0Docker/Bin/star.exe -v`) DO (
    set StarcounterVersion=%%F
)

@echo on

docker build %~dp0Docker -t starcounter/docker.windows.sc.2.3.2 ^
    --build-arg vcs_ref=%GitCommitHash% --build-arg starcounter_version=%StarcounterVersion:~8%
```

* Run `copy.bat`, the script seems to execute properly.

* Run `build.bat`, get this error:

```
fatal: Not a git repository (or any of the parent directories): .git

C:\Users\User\Desktop>docker build C:\Users\User\Desktop\Docker -t starcounter/docker.windows.sc.2.3.2     --build-arg vcs_ref= --build-arg starcounter_version=2.4.0.5027
unable to prepare context: unable to evaluate symlinks in Dockerfile path: GetFileAttributesEx C:\Users\User\Desktop\Docker\Dockerfile: The system cannot find the file specified.
```

* Understand that I should run the scripts in the existing GitHub repository

* Clone the `Starcounter.Docker.Windows` repository: `git clone https://github.com/Starcounter/Starcounter.Docker.Windows.git`

* `cd` into the `Starcounter.Docker.Windows` directory and execute `copy.bat`. 

* Get this response:

```
./copy.bat

C:\Users\User\Desktop\Starcounter.Docker.Windows>rd /s /q "C:\Users\User\Desktop\Starcounter.Docker.Windows\Docker\Bin"
The system cannot find the file specified.

C:\Users\User\Desktop\Starcounter.Docker.Windows>xcopy /s /e "" "C:\Users\User\Desktop\Starcounter.Docker.Windows\Docker\Bin\"
Invalid drive specification
0 File(s) copied

C:\Users\User\Desktop\Starcounter.Docker.Windows>del "C:\Users\User\Desktop\Starcounter.Docker.Windows\Docker\Bin\Configuration\Personal.xml"
The system cannot find the path specified.

C:\Users\User\Desktop\Starcounter.Docker.Windows>xcopy "C:\Users\User\Desktop\Starcounter.Docker.Windows\Personal.xml" "C:\Users\User\Desktop\Starcounter.Docker.Windows\Docker\Bin\Configuration\"
C:\Users\User\Desktop\Starcounter.Docker.Windows\Personal.xml
1 File(s) copied
```

* Run `build.bat` in the `Starcounter.Docker.Windows` directory:

```
PS C:\Users\User\Desktop\Starcounter.Docker.Windows> ./build.bat
'C:\Users\User\Desktop\Starcounter.Docker.Windows\Docker/Bin/star.exe' is not recognized as an internal or external command,
operable program or batch file.

C:\Users\User\Desktop\Starcounter.Docker.Windows>docker build C:\Users\User\Desktop\Starcounter.Docker.Windows\Docker -t starcounter/docker.windows.sc.2.3.2     --build-arg vcs_ref=6989fe0161ab2f3dd5399b6ca077f13a1af8de75 --build-arg starcounter_version=~8
Sending build context to Docker daemon   5.12kB
Step 1/10 : FROM microsoft/windowsservercore
latest: Pulling from microsoft/windowsservercore
3889bb8d808b: Downloading [>                                                  ]  21.07MB/4.07GB
cfb27c9ba25f: Downloading [>                                                  ]  22.66MB/1.308GB
```

* Cancel early because I don't have an internet connection to download 5GB right now.