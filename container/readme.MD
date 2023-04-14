# Container
Uses code from [src](../src/find-UNlocation.ps1)
Downloads country and UN/Locode lists from [datasets](https://github.com/datasets/un-locode) on GitHub

When run within a container the UN/Locode is not updatet until the container is rebuild.

Exceptions from UN/Locode is not (present time) implementet in container. If code is run interactive exceptions or additions can be used. 

## Build
```docker 
docker build --pull --rm -f "container\dockerfile" -t unlocode:lts-alpine-3.14 "src" 
```

## RUN

### Pull from [DockerHub](https://hub.docker.com/r/klaspihl/unlocode)
```docker
docker run --rm --env name=yngsjö --env country=se  klaspihl/unlocode:lts-alpine-3.14 
```

### Run with variables
```docker 
docker run --rm --env name=yngsjö --env country=se  unlocode:lts-alpine-3.14
```

### Run with environment file
```docker  
docker run --rm --env-file locode.env  unlocode:lts-alpine-3.14
```
  
## Example
```docker
:> docker run --rm --env name=yngsjö --env country=se  unlocode:lts-alpine-3.14
{
  "Location": "YNG",
  "LocatioName": "Yngsjö",
  "Country": "SE",
  "CountryName": "Sweden",
  "Coordinates": "+55.88,+14.22"
}
```