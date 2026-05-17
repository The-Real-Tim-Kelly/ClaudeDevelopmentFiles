<#
.SYNOPSIS
    Sets up GitHub Copilot instruction files for a target project by symlinking
    them back to this repository. No file copying — changes to this repo are
    immediately reflected in every linked project.

.DESCRIPTION
    Creates a .github/instructions/ folder in the target project and adds NTFS
    junction points (symlinks) for each selected instruction file. Also optionally
    copies the lean copilot-instructions.md baseline.

    Run once per new project. Re-run with -Force to overwrite existing links.

.PARAMETER ProjectPath
    Absolute path to the target project root.

.PARAMETER Languages
    Language instruction files to include.
    Accepted values: csharp, aspnetcore, entityframework, fluentvalidation,
                     python, react, go, java

.PARAMETER Databases
    Database instruction files to include.
    Accepted values: sqlserver, postgres, sqlite, mongodb, dynamodb

.PARAMETER Infrastructure
    Infrastructure instruction files to include.
    Accepted values: aws

.PARAMETER ObserveFirst
    Include the observe-first meta-instruction. Default: $true.

.PARAMETER All
    Symlink every instruction file regardless of other parameters.

.PARAMETER Force
    Overwrite existing symlinks.

.EXAMPLE
    # C# / ASP.NET Core project on SQL Server
    .\setup-copilot.ps1 -ProjectPath "C:\repos\MyApi" -Languages csharp,aspnetcore,entityframework,fluentvalidation -Databases sqlserver

.EXAMPLE
    # Python / FastAPI project on Postgres
    .\setup-copilot.ps1 -ProjectPath "C:\repos\MyService" -Languages python -Databases postgres

.EXAMPLE
    # Full stack React + C# project
    .\setup-copilot.ps1 -ProjectPath "C:\repos\MyApp" -Languages csharp,aspnetcore,entityframework,react -Databases sqlserver

.EXAMPLE
    # Symlink everything (useful for polyglot projects)
    .\setup-copilot.ps1 -ProjectPath "C:\repos\MyApp" -All
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [string] $ProjectPath,

    [ValidateSet("csharp", "aspnetcore", "entityframework", "fluentvalidation", "python", "react", "go", "java")]
    [string[]] $Languages = @(),

    [ValidateSet("sqlserver", "postgres", "sqlite", "mongodb", "dynamodb")]
    [string[]] $Databases = @(),

    [ValidateSet("aws")]
    [string[]] $Infrastructure = @(),

    [bool] $ObserveFirst = $true,

    [switch] $All,

    [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Resolve paths ────────────────────────────────────────────────────────────
$repoRoot        = $PSScriptRoot | Split-Path -Parent
$sourceDir       = Join-Path $repoRoot "instructions"
$targetGitHub    = Join-Path $ProjectPath ".github"
$targetInstructions = Join-Path $targetGitHub "instructions"

if (-not (Test-Path $ProjectPath)) {
    throw "ProjectPath '$ProjectPath' does not exist."
}

# ── Build file list ───────────────────────────────────────────────────────────
$languageMap = @{
    csharp            = "csharp.instructions.md"
    aspnetcore        = "aspnetcore.instructions.md"
    entityframework   = "entityframework.instructions.md"
    fluentvalidation  = "fluentvalidation.instructions.md"
    python            = "python.instructions.md"
    react             = "react.instructions.md"
    go                = "go.instructions.md"
    java              = "java.instructions.md"
}

$databaseMap = @{
    sqlserver = "sqlserver.instructions.md"
    postgres  = "postgres.instructions.md"
    sqlite    = "sqlite.instructions.md"
    mongodb   = "mongodb.instructions.md"
    dynamodb  = "dynamodb.instructions.md"
}

$infraMap = @{
    aws = "aws.instructions.md"
}

$filesToLink = [System.Collections.Generic.List[string]]::new()

if ($All) {
    Get-ChildItem "$sourceDir\*.instructions.md" | ForEach-Object { $filesToLink.Add($_.Name) }
} else {
    if ($ObserveFirst) { $filesToLink.Add("observe-first.instructions.md") }
    foreach ($lang in $Languages)   { $filesToLink.Add($languageMap[$lang]) }
    foreach ($db   in $Databases)   { $filesToLink.Add($databaseMap[$db]) }
    foreach ($infra in $Infrastructure) { $filesToLink.Add($infraMap[$infra]) }
}

if ($filesToLink.Count -eq 0 -and -not $All) {
    Write-Warning "No instruction files selected. Use -Languages, -Databases, -Infrastructure, or -All."
    return
}

# ── Create target directory ───────────────────────────────────────────────────
if (-not (Test-Path $targetInstructions)) {
    if ($PSCmdlet.ShouldProcess($targetInstructions, "Create directory")) {
        New-Item -ItemType Directory -Path $targetInstructions -Force | Out-Null
        Write-Host "Created $targetInstructions" -ForegroundColor Green
    }
}

# ── Create symlinks ───────────────────────────────────────────────────────────
foreach ($fileName in ($filesToLink | Select-Object -Unique)) {
    $source = Join-Path $sourceDir $fileName
    $target = Join-Path $targetInstructions $fileName

    if (-not (Test-Path $source)) {
        Write-Warning "Source file not found, skipping: $source"
        continue
    }

    if (Test-Path $target) {
        if ($Force) {
            Remove-Item $target -Force
        } else {
            Write-Host "  [skip] $fileName (already exists — use -Force to overwrite)" -ForegroundColor Yellow
            continue
        }
    }

    if ($PSCmdlet.ShouldProcess($target, "Create symlink → $source")) {
        New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
        Write-Host "  [link] $fileName" -ForegroundColor Cyan
    }
}

# ── Copy baseline copilot-instructions.md if not present ─────────────────────
$baselineSrc = Join-Path $repoRoot ".github\copilot-instructions.md"
$baselineDst = Join-Path $targetGitHub "copilot-instructions.md"

if (-not (Test-Path $baselineDst)) {
    if ($PSCmdlet.ShouldProcess($baselineDst, "Copy baseline copilot-instructions.md")) {
        Copy-Item $baselineSrc $baselineDst
        Write-Host "  [copy] copilot-instructions.md → $baselineDst" -ForegroundColor Cyan
    }
} else {
    Write-Host "  [skip] copilot-instructions.md already exists in target" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done. Copilot will now use the linked instruction files in:" -ForegroundColor Green
Write-Host "  $targetInstructions" -ForegroundColor White
Write-Host ""
Write-Host "Tip: instruction files without applyTo (aws, dynamodb, mongodb) must be" -ForegroundColor DarkGray
Write-Host "     referenced manually: attach them via the paperclip icon or #file: in chat." -ForegroundColor DarkGray
