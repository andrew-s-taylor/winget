Function Find-WinGetPackage{
    <#
        .SYNOPSIS
        Searches for a package on configured sources. 
        Additional options can be provided to filter the output, much like the search command.
        
        .DESCRIPTION
        By running this cmdlet with the required inputs, it will retrieve the packages installed on the local system.

        .PARAMETER Filter
        Used to search across multiple fields of the package.
        
        .PARAMETER Id
        Used to specify the Id of the package

        .PARAMETER Name
        Used to specify the Name of the package

        .PARAMETER Moniker
        Used to specify the Moniker of the package

        .PARAMETER Tag
        Used to specify the Tag of the package
        
        .PARAMETER Command
        Used to specify the Command of the package
        
        .PARAMETER Exact
        Used to specify an exact match for any parameters provided. Many of the other parameters may be used for case insensitive substring matches if Exact is not specified.

        .PARAMETER Source
        Name of the Windows Package Manager private source. Can be identified by running: "Get-WinGetSource" and using the source Name

        .PARAMETER Count
        Used to specify the maximum number of packages to return

        .PARAMETER Header
        Used to specify the value to pass as the "Windows-Package-Manager" HTTP header for a REST source.

        .PARAMETER VerboseLog
        Used to provide verbose logging for the Windows Package Manager.
        
        .PARAMETER AcceptSourceAgreement
        Used to accept any source agreement required for the source.

        .EXAMPLE
        Find-WinGetPackage -id "Publisher.Package"

        This example searches for a package containing "Publisher.Package" as a valid identifier on all configured sources.

        .EXAMPLE
        Find-WinGetPackage -id "Publisher.Package" -source "Private"

        This example searches for a package containing "Publisher.Package" as a valid identifier from the source named "Private".

        .EXAMPLE
        Find-WinGetPackage -Name "Package"

        This example searches for a package containing "Package" as a valid name on all configured sources.
    #>
    PARAM(
        [Parameter(Position=0)] $Filter,
        [Parameter()]           $Id,
        [Parameter()]           $Name,
        [Parameter()]           $Moniker,
        [Parameter()]           $Tag,
        [Parameter()]           $Command,
        [Parameter()] [switch]  $Exact,
        [Parameter()]           $Source,
        [Parameter()] [ValidateRange(1, [int]::maxvalue)][int]$Count,
        [Parameter()] [ValidateLength(1, 1024)]$Header,
        [Parameter()] [switch]  $VerboseLog,
        [Parameter()] [switch]  $AcceptSourceAgreement
    )
    BEGIN
    {
        [string[]]          $WinGetArgs  = @("Search")
        [WinGetPackage[]]   $Result      = @()
        [string[]]          $IndexTitles = @("Name", "Id", "Version", "Available", "Source")

        if($PSBoundParameters.ContainsKey('Filter')){
            ## Search across Name, ID, moniker, and tags
            $WinGetArgs += $Filter
        }
        if($PSBoundParameters.ContainsKey('Id')){
            ## Search for the ID
            $WinGetArgs += "--Id", $Id.Replace("…", "")
        }
        if($PSBoundParameters.ContainsKey('Name')){
            ## Search for the Name
            $WinGetArgs += "--Name", $Name.Replace("…", "")
        }
        if($PSBoundParameters.ContainsKey('Moniker')){
            ## Search for the Moniker
            $WinGetArgs += "--Moniker", $Moniker.Replace("…", "")
        }
        if($PSBoundParameters.ContainsKey('Tag')){
            ## Search for the Tag
            $WinGetArgs += "--Tag", $Tag.Replace("…", "")
        }
        if($PSBoundParameters.ContainsKey('Command')){
            ## Search for the Moniker
            $WinGetArgs += "--Command", $Command.Replace("…", "")
        }
        if($Exact){
            ## Search using exact values specified (case sensitive)
            $WinGetArgs += "--Exact"
        }
        if($PSBoundParameters.ContainsKey('Source')){
            ## Search for the Source
            $WinGetArgs += "--Source", $Source.Replace("…", "")
        }
        if($PSBoundParameters.ContainsKey('Count')){
            ## Specify the number of results to return
            $WinGetArgs += "--Count", $Count
        }
        if($PSBoundParameters.ContainsKey('Header')){
            ## Pass the value specified as the Windows-Package-Manager HTTP header
            $WinGetArgs += "--header", $Header
        }
        if($PSBoundParameters.ContainsKey('VerboseLog')){
            ## Search using exact values specified (case sensitive)
            $WinGetArgs += "--VerboseLog", $VerboseLog
        }
        if($AcceptSourceAgreement){
            ## Accept source agreements
            $WinGetArgs += "--accept-source-agreements"
        }
    }
    PROCESS
    {
        $List = Invoke-WinGetCommand -WinGetArgs $WinGetArgs -IndexTitles $IndexTitles
    
        foreach ($Obj in $List) {
            $Result += [WinGetPackage]::New($Obj) 
        }
    }
    END
    {
        return $Result
    }
}


Function Install-WinGetPackage
{
    <#
        .SYNOPSIS
        Installs a package on the local system. 
        Additional options can be provided to filter the output, much like the search command.
        
        .DESCRIPTION
        By running this cmdlet with the required inputs, it will retrieve the packages installed on the local system.

        .PARAMETER Filter
        Used to search across multiple fields of the package.
        
        .PARAMETER Id
        Used to specify the Id of the package

        .PARAMETER Name
        Used to specify the Name of the package

        .PARAMETER Moniker
        Used to specify the Moniker of the package

        .PARAMETER Tag
        Used to specify the Tag of the package
        
        .PARAMETER Command
        Used to specify the Command of the package

        .PARAMETER Scope
        Used to specify install scope (user or machine)
        
        .PARAMETER Exact
        Used to specify an exact match for any parameters provided. Many of the other parameters may be used for case insensitive substring matches if Exact is not specified.

        .PARAMETER Source
        Name of the Windows Package Manager private source. Can be identified by running: "Get-WinGetSource" and using the source Name

        .PARAMETER Interactive
        Used to specify the installer should be run in interactive mode.

        .PARAMETER Silent
        Used to specify the installer should be run in silent mode with no user input.

        .PARAMETER Locale
        Used to specify the locale for localized package installer.

        .PARAMETER Log
        Used to specify the location for the log location if it is supported by the package installer.

        .PARAMETER Header
        Used to specify the value to pass as the "Windows-Package-Manager" HTTP header for a REST source.

        .PARAMETER Version
        Used to specify the Version of the package

        .PARAMETER VerboseLog
        Used to provide verbose logging for the Windows Package Manager.
        
        .PARAMETER AcceptPackageAgreement
        Used to accept any package agreement required for the package.
        
        .PARAMETER AcceptSourceAgreement
        Used to explicitly accept any agreement required by the source.

        .PARAMETER Local
        Used to install from a local manifest

        .EXAMPLE
        Install-WinGetPackage -id "Publisher.Package"

        This example expects only a single package containing "Publisher.Package" as a valid identifier.

        .EXAMPLE
        Install-WinGetPackage -id "Publisher.Package" -source "Private"

        This example expects the source named "Private" contains a package with "Publisher.Package" as a valid identifier.

        .EXAMPLE
        Install-WinGetPackage -Name "Package"

        This example expects a configured source contains a package with "Package" as a valid name.
    #>

    PARAM(
        [Parameter(Position=0)] $Filter,
        [Parameter()]           $Name,
        [Parameter()]           $Id,
        [Parameter()]           $Moniker,
        [Parameter()]           $Source,
        [Parameter()] [ValidateSet("User", "Machine")] $Scope,
        [Parameter()] [switch]  $Interactive,
        [Parameter()] [switch]  $Silent,
        [Parameter()] [string]  $Version,
        [Parameter()] [switch]  $Exact,
        [Parameter()] [switch]  $Override,
        [Parameter()] [System.IO.FileInfo]  $Location,
        [Parameter()] [switch]  $Force,
        [Parameter()] [ValidatePattern("^([a-zA-Z]{2,3}|[iI]-[a-zA-Z]+|[xX]-[a-zA-Z]{1,8})(-[a-zA-Z]{1,8})*$")] [string] $Locale,
        [Parameter()] [System.IO.FileInfo]  $Log, ## This is a path of where to create a log.
        [Parameter()] [switch]  $AcceptSourceAgreements,
        [Parameter()] [switch]  $Local # This is for installing local manifests
    )
    BEGIN
    {
        $WinGetFindArgs = @{}
        [string[]] $WinGetInstallArgs  = "Install"
        IF($PSBoundParameters.ContainsKey('Filter')){
            IF($Local) {
                $WinGetInstallArgs += "--Manifest"
            }
            $WinGetInstallArgs += $Filter
        }
        IF($PSBoundParameters.ContainsKey('Filter')){
            IF($Local) {
                $WinGetInstallArgs += "--Manifest"
            }
            $WinGetInstallArgs += $Filter
            $WinGetFindArgs.Add('Filter', $Filter)
        }
        IF($PSBoundParameters.ContainsKey('Name')){
            $WinGetInstallArgs += "--Name", $Name
            $WinGetFindArgs.Add('Name', $Name)
        }
        IF($PSBoundParameters.ContainsKey('Id')){
            $WinGetInstallArgs += "--Id", $Id
            $WinGetFindArgs.Add('Id', $Id)
        }
        IF($PSBoundParameters.ContainsKey('Moniker')){
            $WinGetInstallArgs += "--Moniker", $Moniker
            $WinGetFindArgs.Add('Moniker', $Moniker)
        }
        IF($PSBoundParameters.ContainsKey('Source')){
            $WinGetInstallArgs += "--Source", $Source
            $WinGetFindArgs.Add('Source', $Source)
        }
        IF($PSBoundParameters.ContainsKey('Scope')){
            $WinGetInstallArgs += "--Scope", $Scope
        }
        IF($Interactive){
            $WinGetInstallArgs += "--Interactive"
        }
        IF($Silent){
            $WinGetInstallArgs += "--Silent"
        }
        IF($PSBoundParameters.ContainsKey('Locale')){
            $WinGetInstallArgs += "--locale", $Locale
        }
        if($PSBoundParameters.ContainsKey('Version')){
            $WinGetInstallArgs += "--Version", $Version
        }
        if($Exact){
            $WinGetInstallArgs += "--Exact"
            $WinGetFindArgs.Add('Exact', $true)
        }
        if($PSBoundParameters.ContainsKey('Log')){
            $WinGetInstallArgs += "--Log", $Log
        }
        if($PSBoundParameters.ContainsKey('Override')){
            $WinGetInstallArgs += "--override", $Override
        }
        if($PSBoundParameters.ContainsKey('Location')){
            $WinGetInstallArgs += "--Location", $Location
        }
        if($Force){
            $WinGetInstallArgs += "--Force"
        }
    }
    PROCESS
    {
        ## Exact, ID and Source - Talk with Demitrius tomorrow to better understand this.
        IF(!$Local) {
            $Result = Find-WinGetPackage @WinGetFindArgs
        }

        if($Result.count -eq 1 -or $Local) {
            & "WinGet" $WinGetInstallArgs
            $Result = ""
        }
        elseif($Result.count -lt 1){
            Write-Host "Unable to locate package for installation"
            $Result = ""
        }
        else {
            Write-Host "Multiple packages found matching input criteria. Please refine the input."
        }
    }
    END
    {
        return $Result
    }
}

filter Assert-WhiteSpaceIsNull {
    IF ([string]::IsNullOrWhiteSpace($_)){$null}
    ELSE {$_}
}

class WinGetSource
{
    [string] $Name
    [string] $Argument
    [string] $Data
    [string] $Identifier
    [string] $Type

    WinGetSource ()
    {  }

    WinGetSource ([string]$a, [string]$b, [string]$c, [string]$d, [string]$e)
    {
        $this.Name       = $a.TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Argument   = $b.TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Data       = $c.TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Identifier = $d.TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Type       = $e.TrimEnd() | Assert-WhiteSpaceIsNull
    }

    WinGetSource ([string[]]$a)
    {
        $this.name       = $a[0].TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Argument   = $a[1].TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Data       = $a[2].TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Identifier = $a[3].TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Type       = $a[4].TrimEnd() | Assert-WhiteSpaceIsNull
    }
    
    WinGetSource ([WinGetSource]$a)
    {
        $this.Name       = $a.Name.TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Argument   = $a.Argument.TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Data       = $a.Data.TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Identifier = $a.Identifier.TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Type       = $a.Type.TrimEnd() | Assert-WhiteSpaceIsNull

    }
    
    [WinGetSource[]] Add ([WinGetSource]$a)
    {
        $FirstValue  = [WinGetSource]::New($this)
        $SecondValue = [WinGetSource]::New($a)
        
        [WinGetSource[]] $Combined = @([WinGetSource]::New($FirstValue), [WinGetSource]::New($SecondValue))

        Return $Combined
    }

    [WinGetSource[]] Add ([String[]]$a)
    {
        $FirstValue  = [WinGetSource]::New($this)
        $SecondValue = [WinGetSource]::New($a)
        
        [WinGetSource[]] $Combined = @([WinGetSource]::New($FirstValue), [WinGetSource]::New($SecondValue))

        Return $Combined
    }
}

class WinGetPackage
{
    [string]$Name
    [string]$Id
    [string]$Version
    [string]$Available
    [string]$Source
    [string]$Match

    WinGetPackage ([string] $a, [string]$b, [string]$c, [string]$d, [string]$e)
    {
        $this.Name    = $a.TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Id      = $b.TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Version = $c.TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Available = $d.TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Source  = $e.TrimEnd() | Assert-WhiteSpaceIsNull
    }
    
    WinGetPackage ([WinGetPackage] $a) {
        $this.Name    = $a.Name | Assert-WhiteSpaceIsNull
        $this.Id      = $a.Id | Assert-WhiteSpaceIsNull
        $this.Version = $a.Version | Assert-WhiteSpaceIsNull
        $this.Available = $a.Available | Assert-WhiteSpaceIsNull
        $this.Source  = $a.Source | Assert-WhiteSpaceIsNull

    }
    WinGetPackage ([psobject] $a) {
        $this.Name      = $a.Name | Assert-WhiteSpaceIsNull
        $this.Id        = $a.Id | Assert-WhiteSpaceIsNull
        $this.Version   = $a.Version | Assert-WhiteSpaceIsNull
        $this.Available = $a.Available | Assert-WhiteSpaceIsNull
        $this.Source    = $a.Source | Assert-WhiteSpaceIsNull
    }
    
    WinGetSource ([string[]]$a)
    {
        $this.name      = $a[0].TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Id        = $a[1].TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Version   = $a[2].TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Available = $a[3].TrimEnd() | Assert-WhiteSpaceIsNull
        $this.Source    = $a[4].TrimEnd() | Assert-WhiteSpaceIsNull
    }

    
    [WinGetPackage[]] Add ([WinGetPackage] $a)
    {
        $FirstValue  = [WinGetPackage]::New($this)
        $SecondValue = [WinGetPackage]::New($a)

        [WinGetPackage[]]$Result = @([WinGetPackage]::New($FirstValue), [WinGetPackage]::New($SecondValue))

        Return $Result
    }

    [WinGetPackage[]] Add ([String[]]$a)
    {
        $FirstValue  = [WinGetPackage]::New($this)
        $SecondValue = [WinGetPackage]::New($a)
        
        [WinGetPackage[]] $Combined = @([WinGetPackage]::New($FirstValue), [WinGetPackage]::New($SecondValue))

        Return $Combined
    }
}
Function Invoke-WinGetCommand
{
    PARAM(
        [Parameter(Position=0, Mandatory=$true)] [string[]]$WinGetArgs,
        [Parameter(Position=0, Mandatory=$true)] [string[]]$IndexTitles,
        [Parameter()]                            [switch] $JSON
    )
    BEGIN
    {
        $Index  = @()
        $Result = @()
        $i      = 0
        $IndexTitlesCount = $IndexTitles.Count
        $Offset = 0
        $Found = $false
        
        ## Remove two characters from the string length and add "..." to the end (only if there is the three below characters present).
        [string[]]$WinGetSourceListRaw = & "WinGet" $WingetArgs | out-string -stream | foreach-object{$_ -replace ("$([char]915)$([char]199)$([char]170)", "$([char]199)")}
    }
    PROCESS
    {
        if($JSON){
            ## If expecting JSON content, return the object
            return $WinGetSourceListRaw | ConvertFrom-Json
        }

        ## Gets the indexing of each title
        $rgex = $IndexTitles -join "|"
        for ($Offset=0; $Offset -lt $WinGetSourceListRaw.Length; $Offset++) {
            if($WinGetSourceListRaw[$Offset].Split(" ")[0].Trim() -match $rgex) {
                $Found = $true
                break
            }
        }
        if(!$Found) {
            Write-Error -Message "No results were found." -TargetObject $WinGetSourceListRaw
            return
        }
        
        foreach ($IndexTitle in $IndexTitles) {
            ## Creates an array of titles and their string location
            $IndexStart = $WinGetSourceListRaw[$Offset].IndexOf($IndexTitle)
            $IndexEnds  = ""

            IF($IndexStart -ne "-1") {
                $Index += [pscustomobject]@{
                    Title = $IndexTitle
                    Start = $IndexStart
                    Ends = $IndexEnds
                    }
            }
        }

        ## Orders the Object based on Index value
        $Index = $Index | Sort-Object Start

        ## Sets the end of string value
        while ($i -lt $IndexTitlesCount) {
            $i ++

            ## Sets the End of string value (if not null)
            if($Index[$i].Start) {
                $Index[$i-1].Ends = ($Index[$i].Start -1) - $Index[$i-1].Start 
            }
        }

        ## Builds the WinGetSource Object with contents
        $i = $Offset + 2
        while($i -lt $WinGetSourceListRaw.Length) {
            $row = $WinGetSourceListRaw[$i]
            try {
                [bool] $TestNotTitles     = $WinGetSourceListRaw[0] -ne $row
                [bool] $TestNotHyphenLine = $WinGetSourceListRaw[1] -ne $row -and !$Row.Contains("---")
                [bool] $TestNotNoResults  = $row -ne "No package found matching input criteria."
            }
            catch {Wait-Debugger}

            if(!$TestNotNoResults) {
                Write-LogEntry -LogEntry "No package found matching input criteria." -Severity 1
            }

            ## If this is the first pass containing titles or the table line, skip.
            if($TestNotTitles -and $TestNotHyphenLine -and $TestNotNoResults) {
                $List = @{}

                foreach($item in $Index) {
                    if($Item.Ends) {
                            $List[$Item.Title] = $row.SubString($item.Start,$Item.Ends)
                    }
                    else {
                        $List[$item.Title] = $row.SubString($item.Start, $row.Length - $Item.Start)
                    }
                }

                $result += [pscustomobject]$list
            }
            $i++
        }
    }
    END
    {
        return $Result
    }
}


Function Uninstall-WinGetPackage{
    <#
        .SYNOPSIS
        Uninstalls a package from the local system. 
        Additional options can be provided to filter the output, much like the search command.
        
        .DESCRIPTION
        By running this cmdlet with the required inputs, it will uninstall a package installed on the local system.

        .PARAMETER Filter
        Used to search across multiple fields of the package.
        
        .PARAMETER Id
        Used to specify the Id of the package

        .PARAMETER Name
        Used to specify the Name of the package

        .PARAMETER Moniker
        Used to specify the Moniker of the package

        .PARAMETER Version
        Used to specify the Version of the package
        
        .PARAMETER Exact
        Used to specify an exact match for any parameters provided. Many of the other parameters may be used for case insensitive substring matches if Exact is not specified.

        .PARAMETER Source
        Name of the Windows Package Manager private source. Can be identified by running: "Get-WinGetSource" and using the source Name

        .PARAMETER Interactive
        Used to specify the uninstaller should be run in interactive mode.

        .PARAMETER Silent
        Used to specify the uninstaller should be run in silent mode with no user input.

        .PARAMETER Log
        Used to specify the location for the log location if it is supported by the package uninstaller.

        .PARAMETER VerboseLog
        Used to provide verbose logging for the Windows Package Manager.

        .PARAMETER Header
        Used to specify the value to pass as the "Windows-Package-Manager" HTTP header for a REST source.
        
        .PARAMETER AcceptSourceAgreement
        Used to explicitly accept any agreement required by the source.

        .PARAMETER Local
        Used to uninstall from a local manifest

        .EXAMPLE
        Uninstall-WinGetPackage -id "Publisher.Package"

        This example expects only a single configured REST source with a package containing "Publisher.Package" as a valid identifier.

        .EXAMPLE
        Uninstall-WinGetPackage -id "Publisher.Package" -source "Private"

        This example expects the REST source named "Private" with a package containing "Publisher.Package" as a valid identifier.

        .EXAMPLE
        Uninstall-WinGetPackage -Name "Package"

        This example expects a configured source contains a package with "Package" as a valid name.
    #>

    PARAM(
        [Parameter(Position=0)] $Filter,
        [Parameter()]           $Name,
        [Parameter()]           $Id,
        [Parameter()]           $Moniker,
        [Parameter()]           $Source,
        [Parameter()] [switch]  $Interactive,
        [Parameter()] [switch]  $Silent,
        [Parameter()] [string]  $Version,
        [Parameter()] [switch]  $Exact,
        [Parameter()] [switch]  $Override,
        [Parameter()] [System.IO.FileInfo]  $Location,
        [Parameter()] [switch]  $Force,
        [Parameter()] [System.IO.FileInfo]  $Log, ## This is a path of where to create a log.
        [Parameter()] [switch]  $AcceptSourceAgreements,
        [Parameter()] [switch]  $Local # This is for installing local manifests
    )
    BEGIN
    {
        [string[]] $WinGetArgs  = "Uninstall"
        IF($PSBoundParameters.ContainsKey('Filter')){
            IF($Local) {
                $WinGetArgs += "--Manifest"
            }
            $WinGetArgs += $Filter
        }
        IF($PSBoundParameters.ContainsKey('Name')){
            $WinGetArgs += "--Name", $Name
        }
        IF($PSBoundParameters.ContainsKey('Id')){
            $WinGetArgs += "--Id", $Id
        }
        IF($PSBoundParameters.ContainsKey('Moniker')){
            $WinGetArgs += "--Moniker", $Moniker
        }
        IF($PSBoundParameters.ContainsKey('Source')){
            $WinGetArgs += "--Source", $Source
        }
        IF($Interactive){
            $WinGetArgs += "--Interactive"
        }
        IF($Silent){
            $WinGetArgs += "--Silent"
        }
        if($PSBoundParameters.ContainsKey('Version')){
            $WinGetArgs += "--Version", $Version
        }
        if($Exact){
            $WinGetArgs += "--Exact"
        }
        if($PSBoundParameters.ContainsKey('Log')){
            $WinGetArgs += "--Log", $Log
        }
        if($PSBoundParameters.ContainsKey('Location')){
            $WinGetArgs += "--Location", $Location
        }
        if($Force){
            $WinGetArgs += "--Force"
        }
    }
    PROCESS
    {
        ## Exact, ID and Source - Talk with tomorrow to better understand this.
        IF(!$Local) {
            $Result = Find-WinGetPackage -Filter $Filter -Name $Name -Id $Id -Moniker $Moniker -Tag $Tag -Command $Command -Source $Source
        }

        if($Result.count -eq 1 -or $Local) {
            & "WinGet" $WingetArgs
            $Result = ""
        }
        elseif($Result.count -lt 1){
            Write-Host "Unable to locate package for uninstallation"
            $Result = ""
        }
        else {
            Write-Host "Multiple packages found matching input criteria. Please refine the input."
        }
    }
    END
    {
        return $Result
    }
}


Function Upgrade-WinGetPackage
{
    <#
        .SYNOPSIS
        Upgrades a package on the local system. 
        Additional options can be provided to filter the output, much like the search command.
        
        .DESCRIPTION
        By running this cmdlet with the required inputs, it will retrieve the packages installed on the local system.

        .PARAMETER Filter
        Used to search across multiple fields of the package.
        
        .PARAMETER Id
        Used to specify the Id of the package

        .PARAMETER Name
        Used to specify the Name of the package

        .PARAMETER Moniker
        Used to specify the Moniker of the package

        .PARAMETER Tag
        Used to specify the Tag of the package
        
        .PARAMETER Command
        Used to specify the Command of the package

        .PARAMETER Channel
        Used to specify the channel of the package. Note this is not yet implemented in Windows Package Manager as of version 1.1.0.

        .PARAMETER Scope
        Used to specify install scope (user or machine)
        
        .PARAMETER Exact
        Used to specify an exact match for any parameters provided. Many of the other parameters may be used for case insensitive substring matches if Exact is not specified.

        .PARAMETER Source
        Name of the Windows Package Manager private source. Can be identified by running: "Get-WinGetSource" and using the source Name

        .PARAMETER Manifest
        Path to the manifest on the local file system. Requires local manifest setting to be enabled.

        .PARAMETER Interactive
        Used to specify the installer should be run in interactive mode.

        .PARAMETER Silent
        Used to specify the installer should be run in silent mode with no user input.

        .PARAMETER Locale
        Used to specify the locale for localized package installer.

        .PARAMETER Log
        Used to specify the location for the log location if it is supported by the package installer.

        .PARAMETER Override
        Used to override switches passed to installer.

        .PARAMETER Force
        Used to force the upgrade when the Windows Package Manager would ordinarily not upgrade the package.

        .PARAMETER Location
        Used to specify the location for the package to be upgraded.

        .PARAMETER Header
        Used to specify the value to pass as the "Windows-Package-Manager" HTTP header for a REST source.

        .PARAMETER Version
        Used to specify the Version of the package

        .PARAMETER VerboseLog
        Used to provide verbose logging for the Windows Package Manager.
        
        .PARAMETER AcceptPackageAgreement
        Used to accept any source package required for the package.

        .PARAMETER AcceptSourceAgreement

        .EXAMPLE
        Upgrade-WinGetPackage -id "Publisher.Package"

        This example expects only a single package containing "Publisher.Package" as a valid identifier.

        .EXAMPLE
        Upgrade-WinGetPackage -id "Publisher.Package" -source "Private"

        This example expects the source named "Private" contains a package with "Publisher.Package" as a valid identifier.

        .EXAMPLE
        Upgrade-WinGetPackage -Name "Package"

        This example expects the source named "Private" contains a package with "Package" as a valid name.
    #>

    PARAM(
        [Parameter(Position=0)] $Filter,
        [Parameter()]           $Name,
        [Parameter()]           $Id,
        [Parameter()]           $Moniker,
        [Parameter()]           $Source,
        [Parameter()] [ValidateSet("User", "Machine")] $Scope,
        [Parameter()] [switch]  $Interactive,
        [Parameter()] [switch]  $Silent,
        [Parameter()] [string]  $Version,
        [Parameter()] [switch]  $Exact,
        [Parameter()] [switch]  $Override,
        [Parameter()] [System.IO.FileInfo]  $Location,
        [Parameter()] [switch]  $Force,
        [Parameter()] [ValidatePattern("^([a-zA-Z]{2,3}|[iI]-[a-zA-Z]+|[xX]-[a-zA-Z]{1,8})(-[a-zA-Z]{1,8})*$")] [string] $Locale,
        [Parameter()] [System.IO.FileInfo]  $Log, ## This is a path of where to create a log.
        [Parameter()] [switch]  $AcceptSourceAgreements
    )
    BEGIN
    {
        [string[]] $WinGetArgs  = "Install"
        IF($PSBoundParameters.ContainsKey('Filter')){
            $WinGetArgs += $Filter
        }
        IF($PSBoundParameters.ContainsKey('Name')){
            $WinGetArgs += "--Name", $Name
        }
        IF($PSBoundParameters.ContainsKey('Id')){
            $WinGetArgs += "--Id", $Id
        }
        IF($PSBoundParameters.ContainsKey('Moniker')){
            $WinGetArgs += "--Moniker", $Moniker
        }
        IF($PSBoundParameters.ContainsKey('Source')){
            $WinGetArgs += "--Source", $Source
        }
        IF($PSBoundParameters.ContainsKey('Scope')){
            $WinGetArgs += "--Scope", $Scope
        }
        IF($Interactive){
            $WinGetArgs += "--Interactive"
        }
        IF($Silent){
            $WinGetArgs += "--Silent"
        }
        IF($PSBoundParameters.ContainsKey('Locale')){
            $WinGetArgs += "--locale", $Locale
        }
        if($PSBoundParameters.ContainsKey('Version')){
            $WinGetArgs += "--Version", $Version
        }
        if($Exact){
            $WinGetArgs += "--Exact"
        }
        if($PSBoundParameters.ContainsKey('Log')){
            $WinGetArgs += "--Log", $Log
        }
        if($PSBoundParameters.ContainsKey('Override')){
            $WinGetArgs += "--override", $Override
        }
        if($PSBoundParameters.ContainsKey('Location')){
            $WinGetArgs += "--Location", $Location
        }
        if($Force){
            $WinGetArgs += "--Force"
        }
    }
    PROCESS
    {
        ## Exact, ID and Source - Talk with Demitrius tomorrow to better understand this.
        $Result = Find-WinGetPackage -Filter $Filter -Name $Name -Id $Id -Moniker $Moniker -Tag $Tag -Command $Command -Source $Source

        if($Result.count -eq 1) {
            & "WinGet" $WingetArgs
            $Result = ""
        }
        elseif($Result.count -lt 1){
            Write-Host "Unable to locate package for installation"
            $Result = ""
        }
        else {
            Write-Host "Multiple packages found matching input criteria. Please refine the input."
        }
    }
    END
    {
        return $Result
    }
}

Function Get-WinGetPackage{
    <#
        .SYNOPSIS
        Gets installed packages on the local system. displays the packages installed on the system, as well as whether an update is available. 
        Additional options can be provided to filter the output, much like the search command.
        
        .DESCRIPTION
        By running this cmdlet with the required inputs, it will retrieve the packages installed on the local system.

        .PARAMETER Filter
        Used to search across multiple fields of the package.
        
        .PARAMETER Id
        Used to specify the Id of the package

        .PARAMETER Name
        Used to specify the Name of the package

        .PARAMETER Moniker
        Used to specify the Moniker of the package

        .PARAMETER Tag
        Used to specify the Tag of the package
        
        .PARAMETER Command
        Used to specify the Command of the package

        .PARAMETER Count
        Used to specify the maximum number of packages to return
        
        .PARAMETER Exact
        Used to specify an exact match for any parameters provided. Many of the other parameters may be used for case insensitive substring matches if Exact is not specified.

        .PARAMETER Source
        Name of the Windows Package Manager private source. Can be identified by running: "Get-WinGetSource" and using the source Name

        .PARAMETER Header
        Used to specify the value to pass as the "Windows-Package-Manager" HTTP header for a REST source.
        
        .PARAMETER AcceptSourceAgreement
        Used to accept any source agreements required by a REST source.

        .EXAMPLE
        Get-WinGetPackage -id "Publisher.Package"

        This example expects only a single configured REST source with a package containing "Publisher.Package" as a valid identifier.

        .EXAMPLE
        Get-WinGetPackage -id "Publisher.Package" -source "Private"

        This example expects the REST source named "Private" with a package containing "Publisher.Package" as a valid identifier.

        .EXAMPLE
        Get-WinGetPackage -Name "Package"

        This example expects the REST source named "Private" with a package containing "Package" as a valid name.
    #>

    PARAM(
        [Parameter(Position=0)] $Filter,
        [Parameter()]           $Name,
        [Parameter()]           $Id,
        [Parameter()]           $Moniker,
        [Parameter()]           $Tag,
        [Parameter()]           $Source,
        [Parameter()]           $Command,
        [Parameter()]           [ValidateRange(1, [int]::maxvalue)][int]$Count,
        [Parameter()]           [switch]$Exact,
        [Parameter()]           [ValidateLength(1, 1024)]$Header,
        [Parameter()]           [switch]$AcceptSourceAgreement
    )
    BEGIN
    {
        [string[]]       $WinGetArgs  = @("List")
        [WinGetPackage[]]$Result      = @()
        [string[]]       $IndexTitles = @("Name", "Id", "Version", "Available", "Source")

        if($Filter){
            ## Search across Name, ID, moniker, and tags
            $WinGetArgs += $Filter
        }
        if($PSBoundParameters.ContainsKey('Name')){
            ## Search for the Name
            $WinGetArgs += "--Name", $Name.Replace("…", "")
        }
        if($PSBoundParameters.ContainsKey('Id')){
            ## Search for the ID
            $WinGetArgs += "--Id", $Id.Replace("…", "")
        }
        if($PSBoundParameters.ContainsKey('Moniker')){
            ## Search for the Moniker
            $WinGetArgs += "--Moniker", $Moniker.Replace("…", "")
        }
        if($PSBoundParameters.ContainsKey('Tag')){
            ## Search for the Tag
            $WinGetArgs += "--Tag", $Tag.Replace("…", "")
        }
        if($PSBoundParameters.ContainsKey('Source')){
            ## Search for the Source
            $WinGetArgs += "--Source", $Source.Replace("…", "")
        }
        if($PSBoundParameters.ContainsKey('Count')){
            ## Specify the number of results to return
            $WinGetArgs += "--Count", $Count
        }
        if($Exact){
            ## Search using exact values specified (case sensitive)
            $WinGetArgs += "--Exact"
        }
        if($PSBoundParameters.ContainsKey('Header')){
            ## Pass the value specified as the Windows-Package-Manager HTTP header
            $WinGetArgs += "--header", $Header
        }
        if($AcceptSourceAgreement){
            ## Accept source agreements
            $WinGetArgs += "--accept-source-agreements"
        }
    }
    PROCESS
    {
        $List = Invoke-WinGetCommand -WinGetArgs $WinGetArgs -IndexTitles $IndexTitles
    
        foreach ($Obj in $List) {
            $Result += [WinGetPackage]::New($Obj) 
        }
    }
    END
    {
        return $Result
    }
}

