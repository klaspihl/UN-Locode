FROM mcr.microsoft.com/powershell:alpine-3.20
LABEL maintainer   "Klas.Pihl@gmail.com"
LABEL description  "Find UN location code for a given country and location name\
                     To download the required source location and country files run the following command: .\find-UNlocation.ps1 -ForceDownload"
LABEL example      "docker run --rm --env location=yst -e country=es --env verbosepreference=continue  unlocode:latest"
LABEL link "https://github.com/klaspihl/UN-Locode"
ENV scrdirectory=/app

#Copy UNlocode files to directory
ADD https://raw.githubusercontent.com/datasets/un-locode/main/data/country-codes.csv ${scrdirectory}/country-codes.csv
ADD https://raw.githubusercontent.com/datasets/un-locode/main/data/code-list.csv ${scrdirectory}/code-list.csv

#set working directory
WORKDIR ${scrdirectory}

#copy explicit files to directory
COPY ./src/find-UNlocation.ps1 ${scrdirectory}

ENTRYPOINT pwsh /${scrdirectory}/find-UNlocation.ps1
