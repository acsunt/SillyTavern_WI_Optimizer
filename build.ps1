# SillyTavern 世界书管理器 - 自动打包脚本
# 使用方法: 在项目根目录执行 .\build.ps1

param(
    [string]$OutputFile = "dist/bundle.json",
    [switch]$Minify = $false
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SillyTavern 世界书管理器 - 打包工具  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查必要的目录
if (-not (Test-Path "src")) {
    Write-Host "错误: 找不到 src 目录！" -ForegroundColor Red
    exit 1
}

# 创建 dist 目录（如果不存在）
if (-not (Test-Path "dist")) {
    New-Item -ItemType Directory -Path "dist" | Out-Null
    Write-Host "✓ 创建 dist 目录" -ForegroundColor Green
}

Write-Host "开始打包..." -ForegroundColor Yellow
Write-Host ""

# 按照正确的顺序读取所有 JS 文件
$files = @(
    # 样式（如果存在）
    "src/styles/generated.js"
    
    # 核心功能
    "src/core.js"
    "src/dataLayer.js"
    
    # 渲染层
    "src/ui/render/shared.js"
    "src/ui/render/lorebook.js"
    "src/ui/render/regex.js"
    "src/ui/render/index.js"
    
    # 事件处理层
    "src/ui/handlers/worldbook/selectUnboundBooks.js"
    "src/ui/handlers/item.js"
    "src/ui/handlers/lorebook.js"
    "src/ui/handlers/ui.js"
    "src/ui/handlers/index.js"
    
    # UI 外壳
    "src/ui/shell.js"
    
    # 启动代码
    "src/appBootstrap.js"
    "src/index.js"
)

# 合并所有 JavaScript 文件
$combinedJS = ""
$fileCount = 0

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "  [+] $file" -ForegroundColor Gray
        $content = Get-Content $file -Raw -Encoding UTF8
        
        # 移除 import 语句（因为我们手动合并了）
        $content = $content -replace "import\s+.*?from\s+['""].*?['""];?\s*", ""
        $content = $content -replace "import\s+['""].*?['""];?\s*", ""
        
        $combinedJS += "`n// ========== $file ==========`n"
        $combinedJS += $content
        $combinedJS += "`n"
        $fileCount++
    } else {
        Write-Host "  [!] 跳过不存在的文件: $file" -ForegroundColor DarkYellow
    }
}

Write-Host ""
Write-Host "✓ 已合并 $fileCount 个文件" -ForegroundColor Green

# 如果需要压缩（简单的空白符压缩）
if ($Minify) {
    Write-Host "正在压缩代码..." -ForegroundColor Yellow
    $combinedJS = $combinedJS -replace "(?m)^\s+", ""  # 移除行首空白
    $combinedJS = $combinedJS -replace "(?m)\s+$", ""  # 移除行尾空白
    $combinedJS = $combinedJS -replace "`n`n+", "`n"   # 合并多个空行
    Write-Host "✓ 代码已压缩" -ForegroundColor Green
}

# 转义 JSON 字符串中的特殊字符
$escapedJS = $combinedJS `
    -replace '\\', '\\' `
    -replace '"', '\"' `
    -replace "`n", '\n' `
    -replace "`r", '' `
    -replace "`t", '\t'

# 创建 bundle.json
$bundleJson = @{
    id = "0266db8e-add9-49c0-bfca-3b237bbb1eaf"
    name = "世界书&正则管理器"
    content = $escapedJS
} | ConvertTo-Json -Depth 10 -Compress:$false

# 写入文件
[System.IO.File]::WriteAllText((Resolve-Path $OutputFile -ErrorAction SilentlyContinue -ErrorVariable _err), $bundleJson, [System.Text.Encoding]::UTF8)

if ($LASTEXITCODE -eq 0 -or -not $_err) {
    $fileSize = (Get-Item $OutputFile).Length
    $fileSizeKB = [math]::Round($fileSize / 1KB, 2)
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "✓ 打包成功！" -ForegroundColor Green
    Write-Host "  输出文件: $OutputFile" -ForegroundColor White
    Write-Host "  文件大小: $fileSizeKB KB" -ForegroundColor White
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "下一步操作:" -ForegroundColor Yellow
    Write-Host "  1. 在 SillyTavern 中打开 JS-Slash-Runner 扩展" -ForegroundColor White
    Write-Host "  2. 导入 $OutputFile" -ForegroundColor White
    Write-Host "  3. 激活脚本并刷新页面测试" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "✗ 打包失败！" -ForegroundColor Red
    exit 1
}
