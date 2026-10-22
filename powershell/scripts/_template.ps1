#Requires -Version 7.2
#Requires -Modules Az.Accounts

<#
.SYNOPSIS
    One-line description of what this script checks or does.
.PARAMETER SubscriptionId
    One or more subscription IDs to scan. Defaults to all enabled subscriptions in the tenant.
.PARAMETER OutputPath
    Folder for the report. Defaults to ./reports.
.PARAMETER Format
    Csv or Json.
.EXAMPLE
    ./_template.ps1 -SubscriptionId 00000000-0000-0000-0000-000000000000 -Format Json
.NOTES
    Exit codes: 0 = clean, 1 = findings, 2 = error.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string[]]$SubscriptionId,
    [string]$OutputPath = './reports',
    [ValidateSet('Csv', 'Json')]
    [string]$Format = 'Csv'
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..' 'modules' 'Common' 'Common.psd1') -Force

try {
    Assert-AzContext

    $findings = [System.Collections.Generic.List[object]]::new()

    foreach ($sub in Get-TargetSubscription -SubscriptionId $SubscriptionId) {
        Write-Log "Scanning $($sub.Name) ($($sub.Id))"
        Set-AzContext -SubscriptionId $sub.Id | Out-Null

        # --- script logic goes here ---
        # $findings.Add([pscustomobject]@{ Subscription = $sub.Name; ResourceId = '...'; Issue = '...' })

        # For anything that changes state:
        # if ($PSCmdlet.ShouldProcess($resourceId, 'Delete orphaned disk')) { ... }
    }

    Export-Report -Data $findings -Name 'template' -OutputPath $OutputPath -Format $Format | Out-Null

    if ($findings.Count -gt 0) {
        Write-Log -Level WARN "$($findings.Count) finding(s)"
        exit (Get-ExitCode Findings)
    }

    Write-Log 'No findings'
    exit (Get-ExitCode Ok)
}
catch {
    Write-Log -Level ERROR $_.Exception.Message
    exit (Get-ExitCode Error)
}