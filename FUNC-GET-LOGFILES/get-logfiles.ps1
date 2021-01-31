function Get-Logfiles 
{
<#  
    .SYNOPSIS
        Find logfiles and return an arrylist 
    .DESCRIPTION
        Find every logfile in specified directory and return an arrylist holding paths to discovered logfiles
    .PARAMETER logFileslocation
        Path to logfiles directory
    .PARAMETER recurse
        If specified, existing logfiles in subfolders are included
    .EXAMPLE
        Searching for every logfile in parent folder "logs" (excluding logfiles in subfolders)
            .\get-logfiles.ps1 C:\logs 
        
        Searching for every logfile in directory "logs" (including logfiles in subfolders)
             .\get-logfiles.ps1 C:\logs -recurse
        
        Searching for specified logfile robocopy.log
            .\get-logfiles.ps1 C:\logs robocopy.log
    .NOTES
        Author: 	Nikolas Beier <nikolas.beier@outlook.com>
        Purpose:	Finding every ".log" file in a specified directory
    .FUNCTIONALITY
        Directory
#>

[CmdletBinding()] 
param (
[Parameter(Mandatory=$true)][String]$logFileslocation,
[Parameter(Mandatory=$false)][switch]$recurse
)

Process
{
$DebugPreference = "Continue"
Write-Debug -Message "logFileslocation = ${logFileslocation}"
Write-Debug -Message "logfile = ${logfile}"
Write-Debug -Message "Recurse = ${recurse}"

while ([System.IO.Directory]::Exists($logFileslocation) -eq $false)
{
    $logFileslocation = Read-Host "Sorry, the provided path '${logFileslocation}' does not exists. Please try again"
}
Search-Logfiles
}
}

function Search-Logfiles 
{
    <#  
        .SYNOPSIS
            Subroutine of Get-Logfiles
        .DESCRIPTION
            Find logfiles and print path and logfile name
        .NOTES
            Author: 	Nikolas Beier <nikolas.beier@outlook.com>
            Purpose:	Search directory or folder for ".log" file(s)
        .FUNCTIONALITY
            Files
    #>
    [System.Collections.ArrayList]$logfilespaths = @()
    [System.Collections.ArrayList]$logprocessnames = @()
    $counter = 0
    if ($recurse)
    {
        Get-ChildItem -Path $logFileslocation -Recurse | Where-Object {$_.extension -eq ".log"} | ForEach-Object { $logfilespaths.Add($_.FullName) } | Out-Null
        $logFiles = Get-ChildItem -Path $logFileslocation -Recurse | Where-Object {$_.extension -eq ".log"}
    }
    else 
    {
        Get-ChildItem -Path $logFileslocation | Where-Object {$_.extension -eq ".log"} | ForEach-Object { $logfilespaths.Add($_.FullName) } | Out-Null
        $logFiles = Get-ChildItem -Path $logFileslocation | Where-Object {$_.extension -eq ".log"}
    }

    foreach ($logFile in $logFiles) 
    {
        $counter+=1
        $logprocessname = $logFile.ToString().Split("\")[-1].TrimEnd(".log")
        $logprocessnames+=$logprocessname
        Write-Host "Process name(${counter}): ${logprocessname}"
        Write-Host "Logfile = ${logFile}`r`n"
    }

    Write-Host -ForegroundColor Yellow "${counter} logfile(s) found in ${logFileslocation}`r`n"

    $return = get-returnvalues
    $return[0]
    $return[1]
}

function 
get-returnvalues 
{
    <#  
        .SYNOPSIS
            Subroutine of Search-Logfiles 
        .DESCRIPTION
            Returns two Arrays  
        .NOTES
            Author: 	Nikolas Beier <nikolas.beier@outlook.com>
            Purpose:	Retrun multiple values
        .FUNCTIONALITY
            general
    #>
    "$logfilespaths"
    "$logprocessnames"
}