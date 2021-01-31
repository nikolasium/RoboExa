# Copyright (c) Nikolas Beier.
# Licensed under the MIT License.

<#
PSScriptInfo

.VERSION 1.0

.AUTHOR Nikolas Beier

.COPYRIGHT
Copyright (c) Nikolas Beier.
Licensed under the MIT License.
#>

<#

.SYNOPSIS
    Powershell script for determine Error lines in (a) specified robocopy logfile(s)
.DESCRIPTION
    Determine errors in robocopy logfiles
.PARAMETER logFileslocation
    The provided Path is used to scan for ".log" files. 
.PARAMETER Outlog
    If specified, the result will be written to a logfile.
    It creates a folder in current execution folder named "pp_output". 
    In that folder every examined logfile get a separte logfile with the results.
.EXAMPLE
    .\main.ps1 -logFileslocation "C:\logs" -Outlog 
        -> Scan entire directory for logfiles, examine and produce a logfile
    .\main.ps1 -logFileslocation "C:\logs\logfile1.log" 
        -> Scan only specified file and create output on Terminal 
.NOTES
    Author:     Nikolas Beier <nikolas.beier@outlook.com>
    Purpose:	Manage RoboExa application 
.FUNCTIONALITY
    general
#>

[CmdletBinding()] 
param (
[Parameter(Mandatory=$true)][string]$logFileslocation,
[Parameter(Mandatory=$false)][switch]$Outlog 
)

Import-Module "${PSScriptRoot}\FUNC-GET-LOGFILES\get-logfiles.ps1"
Import-Module "${PSScriptRoot}\FUNC-PERFORM-PARSING\start-parsing.ps1"

function Start-ModeOne
{
    $logpaths = $logFiles[0] -split ' '
    $logprocessnames = $logFiles[1] -split ' '
    $shift = 0
    
    foreach ($logpath in $logpaths) 
    {
        $currentProcess = $logprocessnames[$shift]
        if ($Outlog)
        {
            Write-Host "Process: $currentProcess`r`n"
            Start-Parsing -PathtoLogfile $logpath -ProcessName $currentProcess -Pattern $pattern -Outlog 
        }
        else 
        {
            Write-Host "Process: $currentProcess`r`n"
            Start-Parsing -PathtoLogfile $logpath -ProcessName $currentProcess -Pattern $pattern
        }
        $shift+=1
    }
}

function Start-ModeTwo
{
    if ($Outlog)
    {
        Write-Host "Process: ${logprocessname}"
        Start-Parsing -PathtoLogfile $logFileslocation -ProcessName $logprocessname -Pattern $pattern -Outlog
    }
    else 
    {
        Start-Parsing -PathtoLogfile $logFileslocation -ProcessName $logprocessname -Pattern $pattern
    }
}

$pattern = "([A-Z]{3,}).([0-9]{1,}).([(])+([0-9])+([x])+([0-9]{3,}).([)]).([A-Za-z]{3,}).([A-Za-z]{3,})." # Regex statement to find error lines in robocopy logfiles

if ((Test-Path -Path $logFileslocation -PathType leaf) -eq $false)
{
    $logFiles = Get-Logfiles -logFileslocation $logFileslocation -recurse
    Start-ModeOne
} 
elseif ((Test-Path -Path $logFileslocation -PathType leaf) -eq $true)
{   
    try 
    {
        #$rootpath = $logFileslocation | Split-Path
        $rootfile = Split-Path -Path $logFileslocation -Leaf -Resolve
        $logprocessname = $rootfile.ToString().Split("\")[-1].TrimEnd(".log")
        Start-ModeTwo
    }
    catch 
    {
        Write-Error -Message "The specified file does not exists."
        Exit
    }
}
