# GitHub Actions 权限配置说明

## 🔴 当前问题

GitHub Actions 报错：`Resource not accessible by integration`

这是因为 GitHub Actions 没有权限创建 Release。

## ✅ 解决方法

### 步骤 1：配置仓库权限

访问你的仓库设置页面：
```
https://github.com/acsunt/SillyTavern_World_Info_Optimizer/settings/actions
```

或者按照以下路径操作：
1. 打开你的仓库：https://github.com/acsunt/SillyTavern_World_Info_Optimizer
2. 点击顶部的 **Settings** 标签
3. 在左侧菜单找到 **Actions** → **General**

### 步骤 2：设置 Workflow 权限

在 Settings → Actions → General 页面，滚动到底部找到 **Workflow permissions** 部分：

**必须设置以下选项：**

1. ✅ 选择 **Read and write permissions**
   - 默认可能是 "Read repository contents and packages permissions"
   - 必须改为 "Read and write permissions"

2. ✅ 勾选 **Allow GitHub Actions to create and approve pull requests**

### 步骤 3：保存设置

点击页面底部的 **Save** 按钮保存设置。

### 步骤 4：重新触发构建

设置完成后，在本地执行：

```bash
cd D:\vs\cursor\chajian\SillyTavern_World_Info_Optimizer

# 删除旧标签
git tag -d v3.4.0
git push origin :refs/tags/v3.4.0

# 重新创建并推送标签
git tag v3.4.0
git push origin v3.4.0
```

或者使用手动触发方式：
1. 访问：https://github.com/acsunt/SillyTavern_World_Info_Optimizer/actions
2. 点击 "Manual Build and Release"
3. 点击 "Run workflow"
4. 输入版本号 `v3.4.0`
5. 确保勾选 "是否创建 Release"
6. 点击 "Run workflow"

## 📸 配置截图参考

**Workflow permissions 应该设置为：**

```
● Read and write permissions
  Workflows have read and write permissions in the repository for all scopes.

☑ Allow GitHub Actions to create and approve pull requests
```

## 🔍 验证配置是否成功

配置完成并重新触发后：
1. 访问 Actions 页面：https://github.com/acsunt/SillyTavern_World_Info_Optimizer/actions
2. 查看最新的运行记录
3. 如果成功，Releases 页面会出现新版本：https://github.com/acsunt/SillyTavern_World_Info_Optimizer/releases

## ⚠️ 关于 Node.js 警告

警告信息：
```
Node.js 20 is deprecated. The following actions target Node.js 20...
```

这只是一个警告，不影响功能。GitHub Actions 会自动使用 Node.js 24 运行。

如果想消除警告，可以等待 `actions/checkout` 和 `softprops/action-gh-release` 发布新版本。

## 📝 后续使用

权限配置完成后，以后发布新版本就很简单了：

```bash
# 创建并推送标签
git tag v3.4.1
git push origin v3.4.1
```

GitHub Actions 会自动：
- 构建项目
- 创建 Release
- 上传 bundle.json、bundle_cdn.json、bundle.js

---

**现在请按照上述步骤配置仓库权限，然后告诉我，我会帮你重新触发构建！**
