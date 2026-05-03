# UN-Locode
United Nations Code for Trade and Transport Location 
[UN/Locode](https://unece.org/trade/cefact/UNLOCODE-Download)

## Project 
1. Use external source of LOCODE 
2. Code to translate country and name/city and reverse. 
3. Build container 


### 1 Source
[Codes for Trade](https://unece.org/trade/cefact/UNLOCODE-Download)

### 2 Code

#### Rust 2026-05-03
Changed to RUST since Microsoft do not maintain [Powershell in MCR](mcr.microsoft.com/powershell)

The result is 20% faster runtime with a 1/18th of the container size.

##### Command
```bash
docker run --rm  klaspihl/unlocode:latest --city yngsjö --country se
```
##### Result
```json
{
  "Location": "YNG",
  "LocatioName": "Yngsjö",
  "Country": "SE",
  "CountryName": "Sweden",
  "Coordinates": "55.88333,14.21667",
  "OpenStreetMap": "https://www.openstreetmap.org/?mlat=55.88333&mlon=14.21667#map=11/55.88333/14.21667"
}
```

#### Powershell Archived
[Code in src](/archive/src/find-UNlocation.ps1)
```powershell
.\find-UNlocation.ps1 -name Helsingborg  -Exceptions ..\res\exceptions.json -Verbose
VERBOSE: Exceptions requested
VERBOSE: Exceptions added to UN/LOCODE data
VERBOSE: Find location on location name
VERBOSE: Added exception gives multiple locations, return location in exception

Location    : HBG
LocatioName : Helsingborg
Country     : SE
CountryName : Sweden
Coordinates : 
```

```powershell
.\find-UNlocation.ps1 -name Ystad
VERBOSE: Find location on location name

Location    : YST
LocatioName : Ystad
Country     : SE
CountryName : Sweden
Coordinates : +55.42 ,+13.82
```

### Container

#### Tags

|Tag|Note|
|---|---|
|Latest|Same as latest version|
|Version number|Source data loaded at runtime from compressed files|
|Version-bin|Source data is within binary, ~5 MB larger image with 2% faster query time|



[Dockerhub](https://hub.docker.com/r/klaspihl/unlocode)
```docker
docker run --rm --env location=yng --env country=se  klaspihl/unlocode
```

[Dockerfile](/container/dockerfile)
```docker
docker run --rm --env name=yngsjö --env country=se  klaspihl/unlocode
{
  "Location": "YNG",
  "LocatioName": "Yngsjö",
  "Country": "SE",
  "CountryName": "Sweden",
  "Coordinates": "+55.88,+14.22"
}
```
