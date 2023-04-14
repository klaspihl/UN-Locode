# UN-Locode
United Nations Code for Trade and Transport Location 
[UN/Locode](https://unece.org/trade/cefact/UNLOCODE-Download)

## Project 
1. Use external source of LOCODE 
2. Code to translate country and name/city and reverse. 
3. Build container
4. Azure App
5. Azure Function

### 1 Source
[Codes for Trade](https://unece.org/trade/cefact/UNLOCODE-Download)

### 2 Code

#### Powershell
[Code in src](/src/find-UNlocation.ps1)
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
[Dockerfile](/container/dockerfile)
```docker
docker run --rm --env name=yngsjö --env country=se  unlocode:lts-alpine-3.14
{
  "Location": "YNG",
  "LocatioName": "Yngsjö",
  "Country": "SE",
  "CountryName": "Sweden",
  "Coordinates": "+55.88,+14.22"
}
```

## Additional Resources