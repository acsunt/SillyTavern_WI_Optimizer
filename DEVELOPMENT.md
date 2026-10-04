# SillyTavern 世界书管理器 - 开发指南

## 快速开始

### 1. 克隆仓库
```bash
git clone https://github.com/acsunt/SillyTavern_World_Info_Optimizer.git
cd SillyTavern_World_Info_Optimizer
```

### 2. 本地开发
直接修改 `src/` 目录下的源代码文件。

### 3. 构建打包
```powershell
.\build.ps1
```
这将生成 `dist/bundle.json` 文件。

### 4. 测试
1. 在 SillyTavern 的 JS-Slash-Runner 扩展中导入 `dist/bundle.json`
2. 激活脚本并刷新页面测试

## 推送到你的仓库

### 首次推送
```bash
# 查看当前状态
git status

# 添加修改的文件
git add .

# 提交更改
git commit -m "描述你的修改"

# 推送到你的仓库
git push origin main
```

### 后续修改
每次修改后重复上述步骤即可。

## 发布新版本

有两种方式创建 Release：

### 方式 1：通过 Git Tag（自动触发）

```bash
# 创建版本标签
git tag v3.3.1

# 推送标签（这会自动触发 GitHub Actions 构建和发布）
git push origin v3.3.1
```

推送标签后，GitHub Actions 会自动：
1. 运行 build.ps1 构建
2. 创建 bundle.json、bundle_cdn.json 和 bundle.js
3. 创建 GitHub Release 并上传文件

### 方式 2：手动触发（推荐用于调试）

1. 访问你的 GitHub 仓库
2. 点击 "Actions" 标签
3. 选择 "Manual Build and Release"
4. 点击 "Run workflow"
5. 输入版本号（如 v3.3.1）
6. 选择是否创建 Release
7. 点击 "Run workflow" 开始

这种方式可以先构建测试，确认无误后再创建 Release。

## 项目结构

```
SillyTavern_World_Info_Optimizer/
├── .github/
│   └── workflows/
│       ├── release.yml          # 标签触发的自动发布
│       └── manual-release.yml   # 手动触发的发布
├── src/                         # 源代码目录
│   ├── core.js                  # 核心功能
│   ├── dataLayer.js             # 数据层
│   ├── ui/                      # UI 相关
│   └── ...
├── dist/                        # 构建输出目录
│   ├── bundle.json              # 标准版本
│   ├── bundle_cdn.json          # CDN 自动更新版本
│   └── bundle.js                # JavaScript 源码
├── build.ps1                    # 构建脚本
└── README.md                    # 项目说明
```

## 开发工作流

1. **修改代码** → 编辑 `src/` 下的文件
2. **本地测试** → 运行 `.\build.ps1` 并在 SillyTavern 中测试
3. **提交更改** → `git add . && git commit -m "说明"`
4. **推送代码** → `git push origin main`
5. **发布版本** → 推送 tag 或手动触发 workflow

## 注意事项

- 远程仓库已配置为你的 fork：`https://github.com/acsunt/SillyTavern_World_Info_Optimizer.git`
- 每次发布会生成三个文件：
  - `bundle.json` - 完整版本（推荐用户使用）
  - `bundle_cdn.json` - 自动更新版本
  - `bundle.js` - 纯 JS 源码（供开发者参考）
- GitHub Actions 需要仓库的 Actions 权限已启用
- Release 文件会自动附加版本说明和安装指南

## 常见问题

### Q: 如何只构建不发布？
A: 使用手动触发方式，取消勾选"是否创建 Release"。

### Q: 构建失败怎么办？
A: 检查 GitHub Actions 的日志，通常是 PowerShell 脚本执行问题。

### Q: 如何撤销错误的 Release？
A: 在 GitHub 仓库的 Releases 页面手动删除，然后删除对应的 tag。

```bash
# 删除本地 tag
git tag -d v3.3.1

# 删除远程 tag
git push origin :refs/tags/v3.3.1
```
