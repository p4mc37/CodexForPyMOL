param(
    [string]$PyMolRoot = "$env:LOCALAPPDATA\Schrodinger\PyMOL2",
    [switch]$Uninstall
)
$ErrorActionPreference = 'Stop'
$target = Join-Path $PyMolRoot 'share\pymol\data\startup\cx_pymol'
if ($Uninstall) {
    $resolved = [System.IO.Path]::GetFullPath($target)
    $expected = [System.IO.Path]::GetFullPath((Join-Path $PyMolRoot 'share\pymol\data\startup'))
    if ([System.IO.Path]::GetDirectoryName($resolved) -ne $expected -or [System.IO.Path]::GetFileName($resolved) -ne 'cx_pymol') {
        throw 'Unexpected uninstall target'
    }
    if (Test-Path -LiteralPath $resolved) { Remove-Item -LiteralPath $resolved -Recurse -Force }
    Write-Output 'CX removed. Restart PyMOL.'
    exit
}
if (-not (Test-Path -LiteralPath (Join-Path $PyMolRoot 'python.exe'))) { throw 'PyMOL Python not found' }
$source = Join-Path $PSScriptRoot 'cx_pymol.py'
if (-not (Test-Path -LiteralPath $source)) { throw 'cx_pymol.py not found' }
New-Item -ItemType Directory -Force -Path $target | Out-Null
$destination = Join-Path $target '__init__.py'
if (Test-Path -LiteralPath $destination) {
    Copy-Item -LiteralPath $destination -Destination ($destination + '.' + (Get-Date -Format 'yyyyMMddHHmmss') + '.bak')
}
Copy-Item -LiteralPath $source -Destination $destination
$manifest = @{ workspace = $PSScriptRoot } | ConvertTo-Json
[System.IO.File]::WriteAllText((Join-Path $target 'cx_workspace.json'), $manifest, (New-Object System.Text.UTF8Encoding($false)))
Write-Output "CX installed: $destination"
Write-Output 'Restart PyMOL and enter: cx'
