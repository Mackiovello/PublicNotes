#!/bin/sh

set -e

dotnet build Reprod1/Reprod1.csproj
dotnet run -p Reprod/Reprod.csproj