# 配置 Gist 自动发布

由于私密仓库的 Release 无法公开访问，我们需要使用 GitHub Gist 来托管文件。

## 步骤 1：创建 Gist

1. 访问：https://gist.github.com/
2. 点击右上角 **+** 或访问 https://gist.github.com/new
3. **Gist description**：`世界书&正则管理器 - SillyTavern 插件`
4. **Filename**：`bundle.js`
5. **内容**：随便写点什么，比如 `// 占位符`
6. 选择 **Create public gist**（必须是公开的）
7. 创建后，记录 Gist ID（在 URL 中）
   - 例如：`https://gist.github.com/acsunt/abc123def456`
   - Gist ID 就是：`abc123def456`

## 步骤 2：创建 GitHub Token

1. 访问：https://github.com/settings/tokens/new
2. **Note**：`SillyTavern Plugin Gist Access`
3. **Expiration**：选择 `No expiration`（永不过期）
4. **Select scopes**：只勾选 `gist`
5. 点击 **Generate token**
6. **立即复制 token**（只显示一次！）

## 步骤 3：配置仓库 Secrets

1. 访问你的仓库设置：
   ```
   https://github.com/acsunt/SillyTavern_WI_Optimizer/settings/secrets/actions
   ```

2. 点击 **New repository secret**，添加两个 secret：

   **第一个 Secret：**
   - Name: `GIST_ID`
   - Value: 你的 Gist ID（步骤 1 记录的）
   
   **第二个 Secret：**
   - Name: `GIST_TOKEN`
   - Value: 你的 GitHub Token（步骤 2 复制的）

## 步骤 4：更新 CDN 加载逻辑

配置完成后告诉我，我会更新 CDN 版本的加载地址为 Gist。

## Gist vs Release 对比

| 特性 | Release（私密仓库） | Gist |
|------|---------------------|------|
| 公开访问 | ❌ 不行 | ✅ 可以 |
| 版本管理 | ✅ 完善 | ⚠️ 基础 |
| CDN 支持 | ❌ 不行 | ✅ jsDelivr |
| 自动更新 | ❌ | ✅ |

---

**完成这 3 个步骤后告诉我，我会继续配置！**
