# This was an attempt to build a Nova application with the official ASP.NET Core image
# The limitation is that Bluestar - a Nova dependency - needs Boost 1.58
# Boost 1.58 does not exist on Debian, which this image is based on
# Because of this, I tried to use Boost from a Ubuntu PPA 
# It manages to fetch it but fails to build it on Debian because 
# of mismatched build dependencies.
# Decided not to pursue this further when I hit that.
# Instead, I'll use the Ubuntu image where I can install
# Boost 1.58 without any hacks.
# When Boost is a static dependency of Bluestar,
# it should be possible to use this Dockerfile again, but without the Boost parts

FROM microsoft/aspnetcore-build:2.0 AS build-env
WORKDIR /app

# Uncomment if you want to see the debian version you're running
# RUN cd /etc && echo "$(cat debian_version)"

# Get Debian tools for building
RUN apt-get update && apt install -qq -y build-essential devscripts

# Add PPT with Boost package
RUN echo "deb-src http://ppa.launchpad.net/csaba-kertesz/random/ubuntu xenial main" > /etc/apt/sources.list.d/boost.list && \
    apt-get update && \
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E7521F759FA801CAA6E5230ABE0811DFCA8C7AC3 && \
	apt-get install -qy boost1.58

# Build Boost
RUN apt update && \
	mkdir builddir && \
	cd builddir && \
	apt source -t xenial --build boost1.58 && \
	dpkg -i *.deb && \
	cd /app

# Get Bluestar dependencies 
RUN apt-get update && \ 
	apt-get install -qq -y swi-prolog-nox

# Copy csproj
COPY *.csproj ./

# Only include this line if you have locally built dependencies
# in the %STAR_NUGET% directory that you want to include
# It will otherwise fetch from NuGet or MyGet
COPY %STAR_NUGET% ./%STAR_NUGET%

# Required since we use MyGet as a source for packages
COPY NuGet.Config ./

# Restore as a distinct layer
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM microsoft/aspnetcore:2.0
WORKDIR /app
COPY --from=build-env /app/out .

# We have to set StarcounterBin manually to help Nova find the Bluestar binaries
ENV StarcounterBin ./runtimes/ubuntu.16.04-x64/native

# Replace Nova.SimpleProducts with the name of your DLL
ENTRYPOINT ["dotnet", "Nova.SimpleProducts.dll"]