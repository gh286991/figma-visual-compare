$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/gh286991/figma-visual-compare.git"
$ZipUrl = "https://github.com/gh286991/figma-visual-compare/archive/refs/heads/main.zip"
$SkillRelativePath = "skills/figma-visual-compare"
$DestDir = Join-Path $HOME ".codex\skills"
$DestSkillDir = Join-Path $DestDir "figma-visual-compare"
$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("figma-visual-compare-" + [System.Guid]::NewGuid().ToString())

New-Item -ItemType Directory -Path $TempDir | Out-Null

try {
    New-Item -ItemType Directory -Force -Path $DestDir | Out-Null

    if (Test-Path $DestSkillDir) {
        Remove-Item -Recurse -Force $DestSkillDir
    }

    Write-Host "Installing figma-visual-compare into $DestSkillDir"

    $GitCommand = Get-Command git -ErrorAction SilentlyContinue
    if ($null -ne $GitCommand) {
        & git clone --depth 1 $RepoUrl (Join-Path $TempDir "repo") | Out-Null
        $RepoPath = Join-Path $TempDir "repo"
    }
    else {
        $ArchivePath = Join-Path $TempDir "repo.zip"
        $ExtractedPath = Join-Path $TempDir "extracted"

        Invoke-WebRequest -Uri $ZipUrl -OutFile $ArchivePath
        Expand-Archive -LiteralPath $ArchivePath -DestinationPath $ExtractedPath -Force

        $RepoPath = Get-ChildItem -Path $ExtractedPath -Directory | Select-Object -First 1 -ExpandProperty FullName
    }

    Copy-Item -Recurse -Force (Join-Path $RepoPath $SkillRelativePath) $DestDir

    Write-Host "Installed successfully."
    Write-Host "Restart Codex to pick up new skills."
}
finally {
    if (Test-Path $TempDir) {
        Remove-Item -Recurse -Force $TempDir
    }
}
