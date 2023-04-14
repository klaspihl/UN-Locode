
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
            "Country": "SE",
            "Location": "HBG",
            "Name": "Helsingborg",
            "Coordinates": "",
        }
    ]

#>


[CmdletBinding(SupportsShouldProcess)]
param (
    #[Parameter(ParameterSetName = 'Name')]
    $Name,
    #[Parameter(ParameterSetName = 'Location')]
    $Location,
    #[Parameter(ParameterSetName = 'Name')]
    #[Parameter(ParameterSetName = 'Location')]
    $Country,
    [parameter(DontShow)]
    $uriData = 'https://raw.githubusercontent.com/datasets/un-locode/main/',
    [parameter(DontShow)]
    $DataEndpoint = 'datapackage.json',
    $CSVDataPath = 'code-list.csv',
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
            return ("{0},{1}" -f (convert-longlat $lat).trim(),(convert-longlat $long).trim())
        }

        
    }
    #endregion functions
    'VerbosePreference','Name','Location','Country','Exceptions' | ForEach-Object {
        if(-not $PSBoundParameters.ContainsKey($PSItem)) {
            Write-Verbose "$PSItem argument not found, use environment variable"
            $EnvVar = Get-ChildItem env: | Where-Object Name -eq $PSItem | Select-Object -ExpandProperty value
            if($EnvVar) {
                Set-Variable -Name $PSItem -Value $EnvVar
            } else {
                Write-Verbose "Environment '$PSItem' variable not found"
            }
        }
    }


#region get UN/LOCODE data
    while([string]::IsNullOrEmpty($unlocode)) {
        if(Test-Path $CSVDataPath) {
            if($IsLinux -and -not $ForceDownload) {
                $unlocode = Import-Csv -Path $CSVDataPath
            } elseif((get-item $CSVDataPath).CreationTime -gt (get-date).AddMonths(-6) ) {
                $unlocode = Import-Csv -Path $CSVDataPath 
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
            if($IsLinux -and -not $ForceDownload) {
                $countrycode = Import-Csv -Path $CSVCountryPath
            } elseif((get-item $CSVCountryPath).CreationTime -gt (get-date).AddMonths(-6) ) {
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
    if($Exceptions) {
        Write-Verbose "Exceptions requested"
        if(Test-Path $Exceptions) {
            $ExceptionProperties = @("Country", "Location", "Name")
            $ExceptionsRawData = Get-Content -Path $Exceptions
            $ExceptionsData = switch ($Exceptions) {
                {$PSitem -like "*.json"} { $ExceptionsRawData | ConvertFrom-Json }
                {$PSitem -like "*.csv"} { $ExceptionsRawData | ConvertFrom-CSV }
                Default {throw "Can not read format, need to be extention json or csv"}
            }
            if((Compare-Object $ExceptionProperties ($ExceptionsData | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name) ).sideindicator -contains '<=') {
                throw "Exceptions loaded from $Exceptions do not contain required properties; $ExceptionProperties"
            }
        } else {
            throw "Can not find requested exceptions file at: $Exceptions"
        }
        Write-Verbose "Exceptions added to UN/LOCODE data"
        $unlocode += ($ExceptionsData | Select-Object ( $unlocode | Get-Member -MemberType NoteProperty).name)
    }
    #endregion add exceptions from file
    Write-Verbose "From data tables: Unicode locations: $($unlocode.count), Countrys $($countrycode.count)"

#region get and convert data
    if($Name) {
        Write-Verbose "Find location on location name"
        $LocationResult = $unlocode | Where-Object Name -eq $Name 
        if($Country -and $LocationResult) {
            if($country.length -gt 2) {
                Write-Verbose "Country full name entered, search country code"
                $Country = $countrycode | Where-Object CountryName -eq $Country | Select-Object -ExpandProperty CountryCode
                
            }
            $LocationResult = $LocationResult | Where-Object Country -eq $Country
        }
    }
    if($Location) {
        Write-Verbose "Find location on location short name"
        $LocationResult = $unlocode | Where-Object Location -eq $Location
        if($Country -and $LocationResult) {
            if($country.length -gt 2) {
                Write-Verbose "Country full name entered, search country code"
                $Country = $countrycode | Where-Object CountryName -eq $Country | Select-Object -ExpandProperty CountryCode
                
            }
            $LocationResult = $LocationResult | Where-Object Country -eq $Country
        }
    }
    #endregion get and convert data

#region output
    if(
        $LocationResult.Count -eq 2 -and
        $Exceptions -and
        $LocationResult[0].Country  -eq $LocationResult[1].Country  -and
        (
            $LocationResult[0].Name -eq $LocationResult[1].Name -or
            $LocationResult[0].Location -eq $LocationResult[1].Location 
        )
        ) {
        Write-Verbose "Added exception gives multiple locations, return location in exception"
        $LocationResult = $LocationResult | Select-Object -last 1
    }

    if($LocationResult.Count -gt 1) {
        throw "Multiple sites found, narrow search by Country. Sites found in countries; $($LocationResult.Country -join ', ')"
    } elseif ([string]::IsNullOrEmpty($LocationResult)) {
        write-warning "No location found on; $Country $Name $Location"
        $Output = $null
    } else {
        if($LocationResult.Coordinates) {
            $Coordinates = convert-coordinates $LocationResult.Coordinates
        } else {
            $Coordinates = $null
        }
        $CountryName = $countrycode | Where-Object CountryCode -eq $LocationResult.Country | Select-Object -ExpandProperty CountryName
        $Output = [PSCustomObject]@{
            Location = $LocationResult.Location
            LocatioName = $LocationResult.Name
            Country = $LocationResult.Country
            CountryName = $CountryName
            Coordinates = $Coordinates
        }
    }
    if($IsLinux) {
        return ($Output | ConvertTo-Json)
    } else {
        return $Output
    }
    
    #endregion output