function Start-Parsing
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
        Purpose:	
    .FUNCTIONALITY
        Files
    #>

    [CmdletBinding()] 
    param (
        [Parameter(Mandatory=$true)][string]$PathtoLogfile,
        [Parameter(Mandatory=$true)][string]$ProcessName,
        [Parameter(Mandatory=$true)][string]$Pattern,
        [Parameter(Mandatory=$false)][switch]$Outlog
    )

    Process
    {
        $DebugPreference = "Continue"
        $DebugPreference = "SilentlyContinue"
        Write-Debug -Message "Path to Log = ${PathtoLogfile}"
        Write-Debug -Message "Pattern = ${Pattern}"
        Write-Debug -Message "Outlog = ${Outlog}"

        $timestamp = Get-Date
        $curdate = Get-Date -Format "yyyy-MM-dd_H_mm_ss"

        while ([System.IO.File]::Exists($PathtoLogfile) -eq $false)
        {
            $PathtoLogfile = Read-Host "Sorry, the provided file '${$PathtoLogfile}' does not exists. Please try again"
        }

        if ($Outlog)
        {   
            $logroot = "${PSScriptRoot}\pp_output"
            $metalogname = "${curdate}_parse_errors_${ProcessName}"
            $metalogpath = "${logroot}\${metalogname}.log"
            #Write-Debug -Message "$metalogname`r`n"
            #Write-Debug -Message "$metalogpath`r`n"
            if([System.IO.Directory]::Exists($logroot) -eq $false)
            {
                New-Item -Path $PSScriptRoot -Name "pp_output" -ItemType Directory
                New-Item -Path $logroot -Name "\${metalogname}.log" -ItemType File
            }
            elseif ([System.IO.File]::Exists($metalogpath) -eq $false) 
            {
                New-Item -Path $logroot -Name "\${metalogname}.log" -ItemType File
            }
            else
            {
                Clear-Content -Path $metalogpath
            }
            Add-Content -Path $metalogpath -Value "Timestamp Start: ${timestamp}`r`n"
            Read-Logfile 
            $curdate = Get-Date -Format "yyyy-MM-dd H:mm:ss"
            Add-Content -Path $metalogpath -Value "Timestamp End: ${timestamp}"
        }
        else 
        {
            Write-Host -ForegroundColor Green "Timestamp Start: $(Get-Date -Format "yyyy-MM-dd H:mm:ss")"
            if (Read-Logfile -gt 0)
            {
                Write-Host -ForegroundColor Red "Error lines found`r`n"
            }
            else 
            {
                Write-Host -ForegroundColor Green "No error lines found`r`n"
            }
            Write-Host -ForegroundColor Green "Timestamp End: $(Get-Date -Format "yyyy-MM-dd H:mm:ss")"
        }
    }
}

function Read-Logfile 
{
$content = [System.IO.File]::ReadLines($PathtoLogfile)
$count = 0
$countlines = 0

foreach($line in $content)
{
    $countlines+=1
    if($line -match $Pattern)
    {       
        switch -regex ($line)
        {
            "0x00000002" 
            {
                $count02+=1
                $line02+="${countlines} ${line}`r`n"
            }
            "0x00000003" 
            {
                $count03+=1
                $line03+="${countlines} ${line}`r`n"
            }
            "0x00000005" 
            {
                $count05+=1
                $line05+="${countlines} ${line}`r`n"
            }
            "0x00000006" 
            {
                $count06+=1
                $line06+="${countlines} ${line}`r`n"
            }
            "0x00000020" 
            {
                $count20+=1
                $line20+="${countlines} ${line}`r`n"
            }
            "0x00000035" 
            {
                $count35+=1
                $line35+="${countlines} ${line}`r`n"
            }
            "0x00000040" 
            {
                $count40+=1
                $line40+="${countlines} ${line}`r`n"
            }
            "0x00000070" 
            {
                $count70+=1
                $line70+="${countlines} ${line}`r`n"
            }
            "0x00000079" 
            {
                $count79+=1
                $line79+="${countlines} ${line}`r`n"
            }
            "0x00000033" 
            {
                $count33+=1
                $line33+="${countlines} ${line}`r`n"
            }
            "0x0000003a" 
            {
                $count3a+=1
                $line3a+="${countlines} ${line}`r`n"
            }
            "0x0000054f"
            {
                $count54f+=1
                $line54f+="${countlines} ${line}`r`n"
            }
        }
        Write-Host -ForegroundColor Yellow $line
        $count+=1
    }
}

$errsum = "

File not found errors: $count02
${line02}
Path not found errors: $count03
${line03}
Access denied errors: $count05
${line05}
Invalid handle errors: $count06
${line06}
File locked errors: $count20
${line20}
Network path not found errors: $count35
${line35}
Network name unavailable errors: $count40
${line40}
Disk full errors: $count70
${line70}
Semaphore timeout errors: $count79
${line79}
General Network path errors: $count33
${line33}
NTFS security errors: $count3a
${line3a}
Internal errors: $count54f
${line54f}
_____________________________
Errors total: $count
=============================

"

write-host ""
write-host "File not found errors: ${count02}`r`n${line02}"
write-host "Path not found errors: ${count03}`r`n${line03}"
write-host "Access denied errors: ${count05} `r`n${line05}"
write-host "Invalid handle errors: ${count06}`r`n${line06}"
write-host "File locked errors: ${count20}`r`n${line20}"
write-host "Network path not found errors: ${count35}`r`n${line35}"
write-host "Network name unavailable errors: ${count40}`r`n${line40}"
write-host "Disk full errors: ${count70}`r`n${line70}"
write-host "Semaphore timeout errors: ${count79}`r`n${line79}"
write-host "Network path errors: ${count33}`r`n${line33}"
write-host "NTFS security errors: ${count3a}`r`n${line3a}"
write-host "_____________________________"
write-host "Errors total: "$count
write-host "=============================" 

if ($Outlog)
{
    Write-Log -logpath $metalogpath -text $errsum
}
    return $count
}

function Write-Log
{
    [CmdletBinding()] 
    Param
    (
        [string]$logpath,
        [string]$text
    )

    #$currts = Get-Date -format "yyyy-mm-dd H:mm:ss"
    #"${currts}`r: $($text)" | Out-File $logpath -Append
    # $text | Out-File $logpath -Append
    Add-Content -Path $logpath -Value $text
}
