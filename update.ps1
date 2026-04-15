# Stock Socratic 一键更新脚本 (Windows)
# 用法: ./update.ps1

param(
    [string]$InstallDir = ""
)

$ErrorActionPreference = "Stop"

# 颜色输出
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

Write-ColorOutput Green "=== Stock Socratic 更新脚本 ==="
Write-Output ""

# 检测平台并确定安装目录
$PlatformDirs = @{
    "WorkBuddy" = "$env:USERPROFILE\.workbuddy\skills\stock-socratic"
    "ClaudeCode" = ".claude\skills\stock-socratic"
    "OpenCode" = ".opencodeskills\stock-socratic"
    "OpenClaw" = ".openclaw\skills\stock-socratic"
    "Trae" = ".trae\skills\stock-socratic"
}

if ($InstallDir -eq "") {
    # 自动检测当前目录属于哪个平台
    $CurrentDir = Get-Location
    $DetectedPlatform = $null
    
    foreach ($Platform in $PlatformDirs.Keys) {
        if ($CurrentDir.Path -like "*$Platform*") {
            $DetectedPlatform = $Platform
            break
        }
    }
    
    if ($DetectedPlatform) {
        $InstallDir = $PlatformDirs[$DetectedPlatform]
        Write-ColorOutput Cyan "检测到平台: $DetectedPlatform"
    } else {
        # 尝试检测常见的 skills 目录
        foreach ($Platform in $PlatformDirs.Keys) {
            $TestPath = $PlatformDirs[$Platform]
            if (Test-Path $TestPath) {
                $InstallDir = $TestPath
                Write-ColorOutput Cyan "检测到安装目录: $TestPath"
                break
            }
        }
    }
}

if ($InstallDir -eq "" -or -not (Test-Path $InstallDir)) {
    Write-ColorOutput Red "错误: 无法检测到 Stock Socratic 的安装目录"
    Write-Output ""
    Write-Output "请手动指定安装目录:"
    Write-Output "  .\update.ps1 -InstallDir \"C:\\path\\to\\stock-socratic\""
    Write-Output ""
    Write-Output "或从安装目录运行此脚本"
    exit 1
}

Write-Output "安装目录: $InstallDir"
Write-Output ""

# GitHub 仓库地址
$RepoUrl = "https://github.com/fatliuwei/stock-socratic.git"
$RawUrl = "https://raw.githubusercontent.com/{your-username}/stock-socratic/main"

# 检查是否为 git 仓库
$GitDir = Join-Path $InstallDir ".git"
if (Test-Path $GitDir) {
    Write-ColorOutput Cyan "检测到 Git 仓库，使用 git pull 更新..."
    try {
        Set-Location $InstallDir
        git pull origin main
        Write-ColorOutput Green "✓ 更新成功!"
    } catch {
        Write-ColorOutput Red "✗ Git 更新失败: $_"
        Write-Output "尝试使用直接下载方式..."
        $UseDirectDownload = $true
    }
} else {
    $UseDirectDownload = $true
}

# 直接下载方式
if ($UseDirectDownload) {
    Write-ColorOutput Cyan "使用直接下载方式更新..."
    
    # 创建临时目录
    $TempDir = Join-Path $env:TEMP "stock-socratic-update-$(Get-Random)"
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
    
    try {
        # 下载最新版本
        Write-Output "下载最新版本..."
        $ZipUrl = "https://github.com/{your-username}/stock-socratic/archive/refs/heads/main.zip"
        $ZipPath = Join-Path $TempDir "stock-socratic.zip"
        
        Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -UseBasicParsing
        
        # 解压
        Write-Output "解压文件..."
        Expand-Archive -Path $ZipPath -DestinationPath $TempDir -Force
        
        # 复制文件
        $ExtractedDir = Join-Path $TempDir "stock-socratic-main"
        Write-Output "更新文件..."
        
        # 备份旧版本
        $BackupDir = "$InstallDir.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Copy-Item -Path $InstallDir -Destination $BackupDir -Recurse -Force
        Write-Output "已备份旧版本到: $BackupDir"
        
        # 复制新文件（排除 .git 等）
        $ExcludeItems = @('.git', '.gitignore', '*.backup.*')
        Get-ChildItem -Path $ExtractedDir -Exclude $ExcludeItems | ForEach-Object {
            $DestPath = Join-Path $InstallDir $_.Name
            if ($_.PSIsContainer) {
                Copy-Item -Path $_.FullName -Destination $DestPath -Recurse -Force
            } else {
                Copy-Item -Path $_.FullName -Destination $DestPath -Force
            }
        }
        
        Write-ColorOutput Green "✓ 更新成功!"
        
    } catch {
        Write-ColorOutput Red "✗ 更新失败: $_"
        exit 1
    } finally {
        # 清理临时文件
        if (Test-Path $TempDir) {
            Remove-Item -Path $TempDir -Recurse -Force
        }
    }
}

# 显示版本信息
$SkillFile = Join-Path $InstallDir "SKILL.md"
if (Test-Path $SkillFile) {
    $VersionLine = Get-Content $SkillFile | Select-String "version:" | Select-Object -First 1
    if ($VersionLine) {
        Write-Output ""
        Write-ColorOutput Green "当前版本: $($VersionLine.Line.Trim())"
    }
}

Write-Output ""
Write-ColorOutput Green "=== 更新完成 ==="
Write-Output ""
Write-Output "提示: 请重启您的 AI 助手以加载最新版本"
