# UN-Locode
United Nations Code for Trade and Transport Location

## Project 
1. Use external source of LOCODE
2. Code to translate country and name/city and reverse. 
3. Build container

### 1 Source
[Codes for Trade](https://unece.org/trade/cefact/UNLOCODE-Download)

### 2 Code

#### Powershell
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
## Additional Resources