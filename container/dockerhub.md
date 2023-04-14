# UN/Locode
United Nations Code for Trade and Transport Location 
[UN/Locode](https://unece.org/trade/cefact/UNLOCODE-Download)

## Function
Contaner translate location code to name and back. 
If multiple location codes is found they can be selected by adding country.
In some cases a coordinates to the location is avaiable and those coordinates is translated to long/lat working with [maps](https://www.google.com/maps/place/55%C2%B052'48.0%22N+14%C2%B013'12.0%22E/@55.88,14.2174251,17z/data=!3m1!4b1!4m4!3m3!8m2!3d55.88!4d14.22)

## Examples
### From Name to location code
```docker
docker run --rm --env name=yngsjö --env country=se  klaspihl/unlocode
```
### Result
```json
{
  "Location": "YNG",
  "LocatioName": "Yngsjö",
  "Country": "SE",
  "CountryName": "Sweden",
  "Coordinates": "+55.88,+14.22"
}
```

### From location code to name
```docker
docker run --rm --env location=yng --env country=se  klaspihl/unlocode
```

## Quick reference

Maintained by: [GitHub.com/klaspihl](https://github.com/klaspihl/UN-Locode)

Requests or help [GitHub Issue](https://github.com/klaspihl/UN-Locode/issues)