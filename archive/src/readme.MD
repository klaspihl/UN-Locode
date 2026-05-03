# SYNOPSIS

```powershell
get-help .\find-UNlocation.ps1 -Full

NAME
    H:\Git\UN-Locode\src\find-UNlocation.ps1

SYNOPSIS
    Find location by name or short name by UN/LOCODE database. Converts coordinates to working long/lat


SYNTAX
    H:\Git\UN-Locode\src\find-UNlocation.ps1 [-Name <Object>] [-Country <Object>] [-uriData <Object>] [-DataEndpoint <Object>] [-CSVDataPath <Object>] [-CSVCountryPath <Object>] [-ForceDownload]
    [-Exceptions <String>] [-WhatIf] [-Confirm] [<CommonParameters>]

    H:\Git\UN-Locode\src\find-UNlocation.ps1 [-Location <Object>] [-Country <Object>] [-uriData <Object>] [-DataEndpoint <Object>] [-CSVDataPath <Object>] [-CSVCountryPath <Object>] [-ForceDownload]       
    [-Exceptions <String>] [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIPTION
    If data sources for location or country codes is missing at local system they are downloaded.
    If the local files are older then 6 month they are refreshed


PARAMETERS
    -Name <Object>
        Full name of location

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Location <Object>
        UN/LOCODE short name of location. A three letter abbreviation

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Country <Object>
        UN/LOCODE short name or a two letter abbreviation of country.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -uriData <Object>
        Dataset source data base URI

        Required?                    false
        Position?                    named
        Default value                https://raw.githubusercontent.com/datasets/un-locode/main/
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -DataEndpoint <Object>
        Dataset reference data

        Required?                    false
        Position?                    named
        Default value                datapackage.json
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -CSVDataPath <Object>
        Location of UN/LOCODE location set

        Required?                    false
        Position?                    named
        Default value                un-locode.csv
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -CSVCountryPath <Object>
        Location of UN/LOCODE country set

        Required?                    false
        Position?                    named
        Default value                country-codes.csv
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -ForceDownload [<SwitchParameter>]
        Force download of data sets

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Exceptions <String>
        Path to json or CSV file containing any local exceptions from UN/LOCODE.


        Example Helsingborg in Sweden is refered localy as HBG instead of HEL from UN/LOCODE
        Example;
        [
            {
                "Change": "",
                "Country": "SE",
                "Location": "HBG",
                "Name": "Helsingborg",
                "NameWoDiacritics": "Helsingborg",
                "Subdivision": "",
                "Status": "",
                "Function": "",
                "Date": "",
                "IATA": "",
                "Coordinates": "",
                "Remarks": ""
            }
        ]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -WhatIf [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Confirm [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

NOTES


        2023-03-31 Version 1 Klas.Pihl@gmail.com

    -------------------------- EXAMPLE 1 --------------------------

    PS > find-UNlocation.ps1 -Country se -Location hbg -Exceptions .\exceptions.json
       Locations in exeptions.json overrides UN/LOCODE. Search by location short name.






    -------------------------- EXAMPLE 2 --------------------------

    PS > find-UNlocation.ps1 -Country Sweden -Name helsingborg
       Find by location name and country full name






    -------------------------- EXAMPLE 3 --------------------------

    PS > .\find-UNlocation.ps1 -name Yngsjö -ForceDownload
        Force re-download of location and country data files regardless of age.







RELATED LINKS
    https://github.com/datasets/un-locode
    Datasets location and country
    https://en.wikipedia.org/wiki/UN/LOCODE
    IATA airport codes https://www.iata.org/en/publications/directories/code-search/
```