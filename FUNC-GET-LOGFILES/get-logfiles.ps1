function Get-Logfiles 
{
<#  
    .SYNOPSIS
        Find logfiles and return an arrylist 
    .DESCRIPTION
        Find every logfile in specified directory and return an arrylist holding paths to discovered logfiles
    .PARAMETER logFileslocation
        Path to logfiles directory
    .PARAMETER logfile
        If specified, only that logfile will be selected
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
[Parameter(Mandatory=$false)][String]$logfile,
[Parameter(Mandatory=$false)][switch]$recurse
)

Process
{

$DebugPreference = "Continue"
$DebugPreference = "SilentlyContinue"
Write-Debug -Message "logFileslocation = ${logFileslocation}"
Write-Debug -Message "logfile = ${logfile}"
Write-Debug -Message "Recurse = ${recurse}"

while ([System.IO.Directory]::Exists($logFileslocation) -eq $false)
{
    $logFileslocation = Read-Host "Sorry, the provided path '${logFileslocation}' does not exists. Please try again"
}

if ([string]::IsNullOrEmpty($logfile) -eq $true)
{
    Search-Logfiles
}
elseif ([string]::IsNullOrEmpty($logfile) -eq $false)
{
    try {
        if ($logfile -notmatch '.log$')
        {
            $logfile = "${logfile}.log"
        }
        $pathlogFile = Join-Path -Path $logFileslocation -ChildPath $logfile
        while([System.IO.File]::Exists($pathlogFile) -eq $false)
        {
            $logfile = Read-Host "Sorry, the provided file '${pathlogFile}' does not exists. Please try again"
            $pathlogFile = Join-Path -Path $logFileslocation -ChildPath $logfile
        }
        $logFilename = $logFile.ToString().Split("\")[-1].TrimEnd(".log")
    }
    catch {
    }
    Write-Host $logFilename
    Write-Host "Path: ${pathlogFile}"
}
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