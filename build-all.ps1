# SillyTavern 世界书管理器 - 完整打包脚本
# 生成 bundle.json 和 bundle_cdn.json 两个版本
# 使用方法: 在项目根目录执行 .\build-all.ps1

param(
    [switch]$Minify = $false
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SillyTavern 世界书管理器 - 完整打包  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. 先运行原有的 build.ps1 生成 bundle.json
Write-Host "步骤 1: 生成 bundle.json..." -ForegroundColor Yellow
.\build.ps1 -Minify:$Minify

if (-not (Test-Path "dist/bundle.json")) {
    Write-Host "✗ 生成 bundle.json 失败！" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "步骤 2: 生成 bundle_cdn.json (CDN 自动更新版本)..." -ForegroundColor Yellow

# 2. 读取 bundle.json
$bundleContent = Get-Content "dist/bundle.json" -Raw -Encoding UTF8 | ConvertFrom-Json

# 3. 创建 CDN 加载脚本
$cdnScript = @'
(async function() {
    const REPO = 'acsunt/SillyTavern_WI_Optimizer';
    const RELEASE_API = 'https://api.github.com/repos/' + REPO + '/releases/latest';
    const PLUGIN_ID = '0266db8e-add9-49c0-bfca-3b237bbb1eaf';
    const PLUGIN_NAME = '世界书&正则管理器';
    
    console.log('[世界书管理器] 开始加载...');
    
    try {
        // 获取最新 Release 信息
        const releaseResp = await fetch(RELEASE_API);
        if (!releaseResp.ok) throw new Error('获取版本信息失败: ' + releaseResp.status);
        
        const releaseData = await releaseResp.json();
        const latestVersion = releaseData.tag_name || 'unknown';
        
        console.log('[世界书管理器] 最新版本:', latestVersion);
        
        // 从 Release 资源中找到 bundle.js
        const asset = releaseData.assets.find(a => a.name === 'bundle.js');
        if (!asset) throw new Error('未找到 bundle.js 文件');
        
        // 从 jsDelivr CDN 加载（使用版本号，永久缓存但确保是正确版本）
        const cdnUrl = 'https://cdn.jsdelivr.net/gh/' + REPO + '@' + latestVersion + '/dist/bundle.js';
        
        console.log('[世界书管理器] 加载地址:', cdnUrl);
        
        const response = await fetch(cdnUrl);
        if (!response.ok) {
            // CDN 失败则尝试从 GitHub Release 直接下载
            console.warn('[世界书管理器] CDN 加载失败，尝试直接下载');
            const directResp = await fetch(asset.browser_download_url);
            if (!directResp.ok) throw new Error('加载失败: ' + directResp.status);
            const code = await directResp.text();
            eval(code);
        } else {
            const code = await response.text();
            eval(code);
        }
        
        console.log('[世界书管理器] 加载成功');
        
        toastr.success('版本: ' + latestVersion, PLUGIN_NAME + ' 已加载', {
            timeOut: 3000,
            positionClass: 'toast-top-right'
        });
        
    } catch (error) {
        console.error('[世界书管理器] 加载失败:', error);
        toastr.error('加载失败: ' + error.message, PLUGIN_NAME, {
            timeOut: 5000,
            positionClass: 'toast-top-right'
        });
    }
})();
'@

# 4. 创建 bundle_cdn.json
$cdnBundle = @{
    id = $bundleContent.id
    name = $bundleContent.name + " (自动更新)"
    content = $cdnScript
} | ConvertTo-Json -Depth 10

# 5. 写入 bundle_cdn.json
$cdnPath = Join-Path $PSScriptRoot "dist\bundle_cdn.json"
[System.IO.File]::WriteAllText($cdnPath, $cdnBundle, [System.Text.Encoding]::UTF8)

# 6. 提取 bundle.js (从 bundle.json 中解包)
Write-Host "步骤 3: 提取 bundle.js..." -ForegroundColor Yellow

$jsContent = $bundleContent.content
# 将转义的换行符还原
$jsContent = $jsContent -replace '\\n', "`n"
$jsContent = $jsContent -replace '\\t', "`t"
$jsContent = $jsContent -replace '\\"', '"'
$jsContent = $jsContent -replace '\\\\', '\'

$jsPath = Join-Path $PSScriptRoot "dist\bundle.js"
[System.IO.File]::WriteAllText($jsPath, $jsContent, [System.Text.Encoding]::UTF8)

# 7. 显示结果
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✓ 完整打包成功！" -ForegroundColor Green
Write-Host ""

$file1 = Get-Item "dist/bundle.json"
$file2 = Get-Item "dist/bundle_cdn.json"
$file3 = Get-Item "dist/bundle.js"

Write-Host "  已生成文件:" -ForegroundColor White
Write-Host "    1. bundle.json        - $([math]::Round($file1.Length / 1KB, 2)) KB (标准版本)" -ForegroundColor Cyan
Write-Host "    2. bundle_cdn.json    - $([math]::Round($file2.Length / 1KB, 2)) KB (CDN 自动更新版本)" -ForegroundColor Cyan
Write-Host "    3. bundle.js          - $([math]::Round($file3.Length / 1KB, 2)) KB (纯 JS 源码)" -ForegroundColor Cyan
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "使用说明:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  📦 标准版本 (bundle.json):" -ForegroundColor White
Write-Host "     - 包含完整代码，直接在 SillyTavern 中运行" -ForegroundColor Gray
Write-Host "     - 适合离线使用或自定义修改" -ForegroundColor Gray
Write-Host ""
Write-Host "  🌐 CDN 自动更新版本 (bundle_cdn.json):" -ForegroundColor White
Write-Host "     - 启动时自动从 GitHub 加载最新版本" -ForegroundColor Gray
Write-Host "     - 适合想要自动更新的用户" -ForegroundColor Gray
Write-Host "     - ⚠️  需要能访问 GitHub 和 jsDelivr CDN" -ForegroundColor Gray
Write-Host ""
Write-Host "  📝 纯 JS 源码 (bundle.js):" -ForegroundColor White
Write-Host "     - 供开发者查看和调试使用" -ForegroundColor Gray
Write-Host ""
Write-Host "导入步骤:" -ForegroundColor Yellow
Write-Host "  1. 在 SillyTavern 中打开 JS-Slash-Runner 扩展" -ForegroundColor White
Write-Host "  2. 导入 dist/bundle.json 或 dist/bundle_cdn.json" -ForegroundColor White
Write-Host "  3. 激活脚本并刷新页面测试" -ForegroundColor White
Write-Host ""
