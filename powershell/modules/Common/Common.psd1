@{
    RootModule        = 'Common.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '6f3c2a1e-9b4d-4e7a-8c15-2d0f7b9e4a31'
    Author            = 'Veronica Luceriano'
    Description       = 'Shared helpers for azure-automation-scripts: logging, auth checks, subscription targeting, report export.'
    PowerShellVersion = '7.2'
    RequiredModules   = @('Az.Accounts')
    FunctionsToExport = @('Get-ExitCode', 'Write-Log', 'Assert-AzContext', 'Get-TargetSubscription', 'Export-Report')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}