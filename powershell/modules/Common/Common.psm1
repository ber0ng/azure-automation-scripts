Set-StrictMode -Version Latest

# Exit code convention used by every script in this repo
$script:ExitCodes = @{
    Ok       = 0   # ran cleanly, nothing found
    Findings = 1   # ran cleanly, but found issues worth reporting
    Error    = 2   # script failed (auth, bad params, API error)
}

function Get-ExitCode {
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Ok', 'Findings', 'Error')]
        [string]$Outcome
    )
    $script:ExitCodes[$Outcome]
}

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Message,

        [ValidateSet('DEBUG', 'INFO', 'WARN', 'ERROR')]
        [string]$Level = 'INFO'
    )

    $timestamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    $line = "[$timestamp] [$Level] $Message"

    switch ($Level) {
        'DEBUG' { Write-Verbose $line }
        'INFO'  { Write-Information $line -InformationAction Continue }
        'WARN'  { Write-Warning $line }
        'ERROR' { [Console]::Error.WriteLine($line) }
    }
}

function Assert-AzContext {
    [CmdletBinding()]
    param()

    $context = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $context -or -not $context.Account) {
        throw 'No Azure context found. Run Connect-AzAccount (local) or azure/login with enable-AzPSSession (CI).'
    }
    Write-Log "Authenticated as $($context.Account.Id) in tenant $($context.Tenant.Id)"
}

function Get-TargetSubscription {
    [CmdletBinding()]
    param(
        [string[]]$SubscriptionId
    )

    $tenantId = (Get-AzContext).Tenant.Id

    if ($SubscriptionId) {
        foreach ($id in $SubscriptionId) {
            Get-AzSubscription -SubscriptionId $id -TenantId $tenantId
        }
    }
    else {
        Get-AzSubscription -TenantId $tenantId | Where-Object State -EQ 'Enabled'
    }
}

function Export-Report {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Data,

        [Parameter(Mandatory)]
        [string]$Name,

        [string]$OutputPath = './reports',

        [ValidateSet('Csv', 'Json')]
        [string]$Format = 'Csv'
    )

    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }

    $stamp = (Get-Date).ToUniversalTime().ToString('yyyyMMdd-HHmmss')
    $file = Join-Path $OutputPath "$Name-$stamp.$($Format.ToLower())"

    switch ($Format) {
        'Csv'  { $Data | Export-Csv -Path $file -NoTypeInformation -Encoding utf8 }
        'Json' { ConvertTo-Json -InputObject @($Data) -Depth 6 | Set-Content -Path $file -Encoding utf8 }
    }

    Write-Log "Report written: $file ($($Data.Count) rows)"
    $file
}

Export-ModuleMember -Function Get-ExitCode, Write-Log, Assert-AzContext, Get-TargetSubscription, Export-Report