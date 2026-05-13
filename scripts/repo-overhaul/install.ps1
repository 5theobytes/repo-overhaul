<#
.SYNOPSIS
  Orchestrator for the repo-overhaul toolkit (Windows / PowerShell 5.1+).

.DESCRIPTION
  Detects the project stack, prompts for metadata, copies templates with
  placeholder substitution, and prints a punch-list of follow-ups.

.EXAMPLE
  pwsh scripts/repo-overhaul/install.ps1
  pwsh scripts/repo-overhaul/install.ps1 -Target C:\path\to\repo
#>

param(
  [string]$Target = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ToolkitRoot = (Resolve-Path "$ScriptDir\..\..").Path
$TemplatesDir = Join-Path $ToolkitRoot 'templates\repo-overhaul'

if (-not (Test-Path $TemplatesDir)) {
  Write-Host "Templates directory not found: $TemplatesDir" -ForegroundColor Red
  exit 1
}

# Refuse to run if the user accidentally targets the quarantine directory.
# Excluded paths come from SPEC §5.
$Resolved = (Resolve-Path $Target).Path
if ($Resolved -match '[\\/]\.trash([\\/]|$)') {
  Write-Host "Refusing to scaffold inside .trash/ (SPEC section 5 excluded path)." -ForegroundColor Red
  exit 1
}

Set-Location $Target

function Get-Stack {
  if (Test-Path 'package.json')     { return 'node' }
  if (Test-Path 'pyproject.toml')   { return 'python' }
  if (Test-Path 'requirements.txt') { return 'python' }
  if (Test-Path 'Cargo.toml')       { return 'rust' }
  if (Test-Path 'go.mod')           { return 'go' }
  return 'unknown'
}

$Stack = Get-Stack
Write-Host "Detected stack: $Stack" -ForegroundColor Cyan

$DefaultName = Split-Path -Leaf $Target
$ProjectName = Read-Host "Project name [$DefaultName]"
if (-not $ProjectName) { $ProjectName = $DefaultName }

$DefaultAuthor = (git config user.name 2>$null)
if (-not $DefaultAuthor) { $DefaultAuthor = 'unknown' }
$Author = Read-Host "Author / org name [$DefaultAuthor]"
if (-not $Author) { $Author = $DefaultAuthor }

$License = Read-Host 'License [MIT]'
if (-not $License) { $License = 'MIT' }

$Year = (Get-Date -AsUTC).Year
$Date = (Get-Date -AsUTC).ToString('yyyy-MM-dd')

function Copy-Template {
  param([string]$Src, [string]$Dst)

  if (Test-Path $Dst) {
    Write-Host "  skip (exists): $Dst" -ForegroundColor Yellow
    return
  }
  $parent = Split-Path -Parent $Dst
  if ($parent -and -not (Test-Path $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
  $content = Get-Content -Raw -Path $Src
  $content = $content `
    -replace '\{\{PROJECT_NAME\}\}', [regex]::Escape($ProjectName).Replace('\','') `
    -replace '\{\{AUTHOR\}\}',       [regex]::Escape($Author).Replace('\','') `
    -replace '\{\{LICENSE\}\}',      $License `
    -replace '\{\{YEAR\}\}',         $Year `
    -replace '\{\{DATE\}\}',         $Date
  Set-Content -Path $Dst -Value $content -Encoding utf8 -NoNewline
  Write-Host "  created: $Dst" -ForegroundColor Green
}

Write-Host ""
Write-Host "Copying templates..." -ForegroundColor Cyan

switch ($License) {
  'MIT'        { Copy-Template "$TemplatesDir\LICENSE-mit.txt"        'LICENSE' }
  'Apache-2.0' { Copy-Template "$TemplatesDir\LICENSE-apache-2.0.txt" 'LICENSE' }
  default      { Write-Host "  unknown license $License — skipping LICENSE" -ForegroundColor Yellow }
}

Copy-Template "$TemplatesDir\CONTRIBUTING.md"    'CONTRIBUTING.md'
Copy-Template "$TemplatesDir\CODE_OF_CONDUCT.md" 'CODE_OF_CONDUCT.md'
Copy-Template "$TemplatesDir\SECURITY.md"        'SECURITY.md'
Copy-Template "$TemplatesDir\CHANGELOG.md"       'CHANGELOG.md'

Copy-Template "$TemplatesDir\.editorconfig"  '.editorconfig'
Copy-Template "$TemplatesDir\.gitattributes" '.gitattributes'

if ($Stack -eq 'node') {
  Copy-Template "$TemplatesDir\.nvmrc"          '.nvmrc'
  Copy-Template "$TemplatesDir\.prettierrc.json" '.prettierrc.json'
}

Copy-Template "$TemplatesDir\.github\ISSUE_TEMPLATE\bug_report.yml"      '.github\ISSUE_TEMPLATE\bug_report.yml'
Copy-Template "$TemplatesDir\.github\ISSUE_TEMPLATE\feature_request.yml" '.github\ISSUE_TEMPLATE\feature_request.yml'
Copy-Template "$TemplatesDir\.github\ISSUE_TEMPLATE\config.yml"          '.github\ISSUE_TEMPLATE\config.yml'
Copy-Template "$TemplatesDir\.github\PULL_REQUEST_TEMPLATE.md"           '.github\PULL_REQUEST_TEMPLATE.md'
Copy-Template "$TemplatesDir\.github\dependabot.yml"                     '.github\dependabot.yml'
Copy-Template "$TemplatesDir\.github\FUNDING.yml"                        '.github\FUNDING.yml'
Copy-Template "$TemplatesDir\.github\CODEOWNERS"                         '.github\CODEOWNERS'

switch ($Stack) {
  'node'   { Copy-Template "$TemplatesDir\.github\workflows\ci-node.yml"   '.github\workflows\ci.yml' }
  'python' { Copy-Template "$TemplatesDir\.github\workflows\ci-python.yml" '.github\workflows\ci.yml' }
  default  { Write-Host "  no CI template for stack: $Stack" -ForegroundColor Yellow }
}
Copy-Template "$TemplatesDir\.github\workflows\release-please.yml" '.github\workflows\release-please.yml'

if (-not (Test-Path 'README.md')) {
  Copy-Template "$TemplatesDir\README.template.md" 'README.md'
}

Write-Host ""
Write-Host '-------------------------------------------------------'
Write-Host '  Repo overhaul scaffolding complete.' -ForegroundColor Green
Write-Host ''
Write-Host '  Manual follow-ups:'
Write-Host '    1. Fill placeholders ({{...}}) — search for `{{`.'
Write-Host '    2. Replace .github\CODEOWNERS with your team.'
Write-Host '    3. Configure repo secrets (NPM_TOKEN, CODECOV_TOKEN).'
Write-Host '    4. Enable Dependabot security alerts.'
Write-Host '    5. Adopt Conventional Commits.'
Write-Host '    6. Use .claude/agents/repo-overhaul/ sub-agents for deeper rewrites.'
Write-Host '-------------------------------------------------------'
