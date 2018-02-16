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