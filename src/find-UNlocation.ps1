
<#
.SYNOPSIS
    Find location by name or short name by UN/LOCODE database. Converts coordinates to working long/lat
.DESCRIPTION
    If data sources for location or country codes is missing at local system they are downloaded.
    If the local files are older then 6 month they are refreshed
.NOTES
    2023-03-31 Version 1 Klas.Pihl@gmail.com

.LINK
    https://github.com/datasets/un-locode
    Datasets location and country
.LINK 
    https://en.wikipedia.org/wiki/UN/LOCODE

.LINK
    IATA airport codes https://www.iata.org/en/publications/directories/code-search/
.EXAMPLE
     find-UNlocation.ps1 -Country se -Location hbg -Exceptions .\exceptions.json 
        Locations in exeptions.json overrides UN/LOCODE. Search by location short name.

.EXAMPLE
     find-UNlocation.ps1 -Country Sweden -Name helsingborg 
        Find by location name and country full name

.EXAMPLE
    .\find-UNlocation.ps1 -name Yngsjö -ForceDownload
        Force re-download of location and country data files regardless of age.

.PARAMETER Name
    Full name of location

.PARAMETER Location 
    UN/LOCODE short name of location. A three letter abbreviation

.PARAMETER Country 
    UN/LOCODE short name or a two letter abbreviation of country.

.PARAMETER uriData 
    Dataset source data base URI

.PARAMETER DataEndpoint 
    Dataset reference data

.PARAMETER CSVDataPath 
    Location of UN/LOCODE location set

.PARAMETER CSVCountryPath 
    Location of UN/LOCODE country set

.PARAMETER ForceDownload
    Force download of data sets

.PARAMETER Exceptions
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

#>


[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(ParameterSetName = 'Name')]
    $Name,
    [Parameter(ParameterSetName = 'Location')]
    $Location,
    [Parameter(ParameterSetName = 'Name')]
    [Parameter(ParameterSetName = 'Location')]
    $Country,
    [parameter(DontShow)]
    $uriData = 'https://raw.githubusercontent.com/datasets/un-locode/main/',
    [parameter(DontShow)]
    $DataEndpoint = 'datapackage.json',
    $CSVDataPath = 'un-locode.csv',
    $CSVCountryPath = 'country-codes.csv',
    [switch]$ForceDownload,
    [string]$Exceptions
)
#region functions
    function convert-coordinates {
        <#
        .SYNOPSIS
            Translate UN/LOCODE cordinates to GPS coordinates working with google maps and similar services.
        
        .EXAMPLE
            get-coordinates '5525N 01349E'
            Get longitude and latitude coordinates 
        .NOTES
            2023-03-01 Version 1 Klas.Pihl@gmail.com
        #>
        
        
        param (
            $latlong #'5525N 01349E' 0000lat 00000long
        )
        function convert-longlat {
            param (
                $value
            )
            $valuecalc = ($value -replace "\D")/100
            $valuefloor = [math]::Floor($valuecalc)
            $valuedec = [math]::Round(($valuecalc - $valuefloor)/0.6*100)
            $Direction = switch ($value -replace "[0-9]") {
                'W' { '-' }
                'S' { '-' }
                Default {'+'}
            } 
            
            $valuetude = "{0}{1}.{2} " -f $direction,$valuefloor,$valuedec
            


            return $valuetude
        }
        if($latlong) {
            $lat,$long = $latlong.split(' ')
            return ("{0},{1}" -f (convert-longlat $lat),(convert-longlat $long))
        }

        
    }
    #endregion functions

#region get UN/LOCODE data
    while([string]::IsNullOrEmpty($unlocode)) {
        if(Test-Path $CSVDataPath) {
            if((get-item $CSVDataPath).CreationTime -gt (get-date).AddMonths(-6) ) {
                $unlocode = Import-Csv -Path $csvdatapath 
            } else {
                $ForceDownload = $true
            }
        } else {
            $ForceDownload = $true
        }
        if($ForceDownload) {
            Write-Verbose "Initiate download of UN/LOCODE data"
            $datapackage = Invoke-WebRequest ($uriData+$DataEndpoint)
            $Databackageobject = $datapackage.Content | ConvertFrom-Json
            $PackageAge = get-date($Databackageobject.version.Substring(0,6))
            $csvpath = $Databackageobject.resources | Where-Object Name -eq 'code-list' | Select-Object -ExpandProperty 'path'
            Invoke-WebRequest ($uriData+$csvpath) | Select-Object -ExpandProperty 'content' | Out-File $csvdatapath -Force
        } 
    }
    #endregion get UN/LOCODE data

#region get country data
    while([string]::IsNullOrEmpty($countrycode)) {
        if(Test-Path $CSVCountryPath) {
            if((get-item $CSVCountryPath).CreationTime -gt (get-date).AddMonths(-6) ) {
                $countrycode = Import-Csv -Path $CSVCountryPath 
            } else {
                $ForceDownload = $true
            }
        } else {
            $ForceDownload = $true
        }
        if($ForceDownload) {
            Write-Verbose "Initiate download of UN/LOCODE country codes"
            $datapackage = Invoke-WebRequest ($uriData+$DataEndpoint)
            $Databackageobject = $datapackage.Content | ConvertFrom-Json
            $PackageAge = get-date($Databackageobject.version.Substring(0,6))
            $csvpath = $Databackageobject.resources | Where-Object Name -eq 'country-codes' | Select-Object -ExpandProperty 'path'
            Invoke-WebRequest ($uriData+$csvpath) | Select-Object -ExpandProperty 'content' | Out-File $CSVCountryPath -Force
        }
    }
    #endregion get country data

#region add exceptions from file
    if($PSBoundParameters.ContainsKey("Exceptions")) {
        Write-Verbose "Exceptions requested"
        if(Test-Path $Exceptions) {
            $ExceptionProperties = "Change, Coordinates, Country, Date, Function, IATA, Location, Name, NameWoDiacritics, Remarks, Status, Subdivision"
            $ExceptionsRawData = Get-Content -Path $Exceptions
            $ExceptionsData = switch ($Exceptions) {
                {$PSitem -like "*.json"} { $ExceptionsRawData | ConvertFrom-Json }
                {$PSitem -like "*.csv"} { $ExceptionsRawData | ConvertFrom-CSV }
                Default {throw "Can not read format, need to be extention json or csv"}
            }
            if(($ExceptionsData | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | Sort-Object) -join ', ' -ne $ExceptionProperties) {
                throw "Exceptions loaded from $Exceptions do not contain required properties; $ExceptionProperties"
            }
        } else {
            throw "Can not find requested exceptions file at: $Exceptions"
        }
        Write-Verbose "Exceptions added to UN/LOCODE data"
        $unlocode += $ExceptionsData
    }
    #endregion add exceptions from file

#region get and convert data
    if($PSBoundParameters.ContainsKey('Name')) {
        Write-Verbose "Find location on location name"
        $Location = $unlocode | Where-Object Name -eq $Name 
        if($PSBoundParameters.ContainsKey('Country') -and $Location) {
            if($country.length -gt 2) {
                Write-Verbose "Country full name entered, search country code"
                $Country = $countrycode | Where-Object CountryName -eq $Country | Select-Object -ExpandProperty CountryCode
                
            }
            $Location = $Location | Where-Object Country -eq $Country
        }
    }
    if($PSBoundParameters.ContainsKey('Location')) {
        Write-Verbose "Find location on location short name"
        $Location = $unlocode | Where-Object Location -eq $Location
        if($PSBoundParameters.ContainsKey('Country') -and $Location) {
            if($country.length -gt 2) {
                Write-Verbose "Country full name entered, search country code"
                $Country = $countrycode | Where-Object CountryName -eq $Country | Select-Object -ExpandProperty CountryCode
                
            }
            $Location = $Location | Where-Object Country -eq $Country
        }
    }
    #endregion get and convert data

#region output
    if(
        $Location.Count -eq 2 -and
        $Exceptions -and
        $Location[0].Country  -eq $Location[1].Country  -and
        (
            $Location[0].Name -eq $Location[1].Name -or
            $Location[0].Location -eq $Location[1].Location 
        )
        ) {
        Write-Verbose "Added exception gives multiple locations, return location in exception"
        $Location = $Location | Select-Object -last 1
    }

    if($Location.Count -gt 1) {
        throw "Multiple sites found, narrow search by Country. Sites found in countries; $($Location.Country -join ', ')"
    } elseif ([string]::IsNullOrEmpty($Location)) {
        write-warning "No location found on; $Country $Name$Location"
        $Output = $null
    } else {
        if($Location.Coordinates) {
            $Coordinates = convert-coordinates $Location.Coordinates
        } else {
            $Coordinates = $null
        }
        $CountryName = $countrycode | Where-Object CountryCode -eq $Location.Country | Select-Object -ExpandProperty CountryName
        $Output = [PSCustomObject]@{
            Location = $Location.Location
            LocatioName = $Location.Name
            Country = $Location.Country
            CountryName = $CountryName
            Coordinates = $Coordinates
        }
    }
    return $Output
    #endregion output