# OpenClaw 开发环境配置指南

## 1. Fork 和 Clone

```bash
# 1. 访问 https://github.com/openclaw/openclaw
# 2. 点击 Fork 按钮，将仓库 Fork 到你的账号

# 3. Clone 你的 Fork
git clone https://github.com/YOUR_USERNAME/openclaw.git
cd openclaw

# 4. 添加上游仓库
git remote add upstream https://github.com/openclaw/openclaw.git
git remote -v
# 应该显示：
# origin    https://github.com/YOUR_USERNAME/openclaw.git (fetch)
# origin    https://github.com/YOUR_USERNAME/openclaw.git (push)
# upstream  https://github.com/openclaw/openclaw.git (fetch)
# upstream  https://github.com/openclaw/openclaw.git (push)

# 5. 创建新分支
git checkout -b feature/my-first-change
```

## 2. 安装依赖

```bash
# 使用 pnpm（推荐）
pnpm install

# 或使用 npm
npm install

# 或使用 yarn
yarn install
```

## 3. 环境配置

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑 .env 文件，填入必要的配置
# 至少配置以下项：
# - OPENAI_API_KEY（用于AI功能）
# - TELEGRAM_BOT_TOKEN（如需测试Telegram）
```

## 4. 验证环境

```bash
# 1. 运行测试
pnpm test

# 2. 构建项目
pnpm build

# 3. 类型检查
pnpm type-check

# 4. 代码检查
pnpm lint
```

如果以上都通过，说明环境配置成功！

## 5. 项目结构速览

```
openclaw/
├── src/
│   ├── commands/          # CLI 命令
│   ├── telegram/          # Telegram 通道
│   ├── discord/           # Discord 通道
│   ├── routing/           # 消息路由
│   ├── agents/            # AI 代理
│   ├── channels/          # 通道抽象
│   └── infra/             # 基础设施
├── extensions/            # 扩展插件
├── test/                  # 测试文件
├── docs/                  # 文档
└── package.json
```

## 6. 常用开发命令

```bash
# 开发模式（热重载）
pnpm dev

# 运行特定测试
pnpm test routing

# 运行测试并显示覆盖率
pnpm test:coverage

# 格式化代码
pnpm format

# 自动修复代码问题
pnpm lint:fix
```

## 7. 提交代码流程

```bash
# 1. 查看修改
git status
git diff

# 2. 添加修改
git add .

# 3. 提交（遵循提交规范）
git commit -m "feat(routing): add logging to message routing

- Log message type and user on receive
- Log selected handler on route
- Helps debugging and monitoring"

# 4. 推送到你的 Fork
git push origin feature/my-first-change

# 5. 在 GitHub 上创建 PR
# 访问 https://github.com/openclaw/openclaw
# 点击 "Compare & pull request"
```

## 8. 常见问题

### Q: 安装依赖失败？
A: 确保 Node.js 版本 >= 18，建议使用 nvm 管理版本

### Q: 测试失败？
A: 检查 .env 配置是否正确，某些测试需要真实 API key

### Q: 构建失败？
A: 运行 `pnpm clean` 然后重新 `pnpm install`

### Q: 不知道如何开始？
A: 查看 `test/` 目录中的示例测试，了解代码风格
