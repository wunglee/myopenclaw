# OpenClaw 知识图谱大纲

> 本文件列出 OpenClaw 项目中涉及的所有技术知识点，作为学习路径参考。

---

## 一、JavaScript/TypeScript 基础

### 1.1 语言核心
- [ ] ES Modules (import/export)
- [ ] CommonJS vs ESM 差异
- [ ] TypeScript 类型系统（接口、泛型、类型推断）
- [ ] 异步编程（Promise、async/await）
- [ ] 事件循环机制
- [ ] 流（Stream）处理
- [ ] Buffer 和二进制数据处理

### 1.2 Node.js 核心模块
- [ ] `process` 全局对象
- [ ] `child_process` (spawn/exec/fork)
- [ ] `path` 路径处理
- [ ] `fs` 文件系统
- [ ] `events` (EventEmitter)
- [ ] `stream` 流模块
- [ ] `http/https` 内置 HTTP 服务
- [ ] `os` 操作系统信息
- [ ] `util` 工具函数

### 1.3 现代 JS/TS 特性
- [ ] 装饰器（Decorators）
- [ ] 可选链操作符 `?.`
- [ ] 空值合并运算符 `??`
- [ ] 顶层 await
- [ ] 私有字段 `#private`
- [ ] AbortController 取消异步操作

---

## 二、CLI 开发

### 2.1 Commander.js
- [ ] Program 实例创建
- [ ] 选项定义（Options）
- [ ] 子命令（Subcommands）
- [ ] 参数解析（Arguments）
- [ ] 帮助信息生成
- [ ] Action 回调

### 2.2 交互式 CLI
- [ ] @clack/prompts（交互式提示）
- [ ] chalk（终端颜色）
- [ ] 进度条和加载动画
- [ ] 表格输出格式化

### 2.3 CLI 架构模式
- [ ] 依赖注入（createDefaultDeps）
- [ ] 命令注册模式
- [ ] 钩子系统（Hooks）

---

## 三、Web 开发

### 3.1 Web 框架
- [ ] Hono（轻量级 Web 框架）
- [ ] Express.js
- [ ] 中间件概念
- [ ] 路由系统
- [ ] 请求/响应处理

### 3.2 WebSocket
- [ ] ws 库使用
- [ ] WebSocket 协议基础
- [ ] 实时双向通信
- [ ] 连接管理和心跳

### 3.3 HTTP 客户端
- [ ] undici（Node.js 官方 HTTP 客户端）
- [ ] fetch API
- [ ] 请求拦截和重试
- [ ] 流式响应处理

---

## 四、即时通讯平台集成

### 4.1 平台 SDK
- [ ] **Telegram**: Grammy 框架
- [ ] **Discord**: Carbon 库
- [ ] **Slack**: Bolt 框架
- [ ] **WhatsApp**: Baileys (WhatsApp Web)
- [ ] **LINE**: LINE Bot SDK
- [ ] **Signal**: Signal 协议
- [ ] **iMessage**: AppleScript/Private API

### 4.2 消息处理
- [ ] Webhook 处理
- [ ] 长轮询（Long Polling）
- [ ] 消息格式解析
- [ ] 富媒体消息（图片、文件、语音）
- [ ] 消息路由系统

---

## 五、AI/LLM 集成

### 5.1 AI 提供商 SDK
- [ ] **OpenAI**: GPT、TTS、Embeddings
- [ ] **Anthropic**: Claude API
- [ ] **Google**: Gemini API
- [ ] **AWS Bedrock**: 多模型托管
- [ ] **Ollama**: 本地模型部署

### 5.2 Agent 框架
- [ ] Pi Agent Core (@mariozechner/pi-agent)
- [ ] 工具调用（Tool Calling）
- [ ] 函数调用模式
- [ ] 多轮对话管理
- [ ] 上下文窗口管理

### 5.3 提示工程
- [ ] 系统提示词设计
- [ ] 少样本提示（Few-shot）
- [ ] 思维链（Chain-of-Thought）
- [ ] 结构化输出（JSON Mode）

---

## 六、数据验证与类型安全

### 6.1 Schema 验证
- [ ] **Zod**: 运行时类型验证
- [ ] **TypeBox**: JSON Schema 生成
- [ ] **Ajv**: JSON Schema 验证器

### 6.2 TypeScript 高级
- [ ] 条件类型
- [ ] 映射类型
- [ ] 类型守卫
- [ ]  branded types
- [ ] 类型编程

---

## 七、数据存储

### 7.1 SQLite
- [ ] sqlite-vec（向量扩展）
- [ ] 向量搜索和相似度计算
- [ ] 嵌入式数据库

### 7.2 内存管理
- [ ] 向量内存系统
- [ ] RAG（检索增强生成）
- [ ] 会话状态管理

---

## 八、浏览器自动化

### 8.1 Playwright
- [ ] 浏览器控制
- [ ] 页面导航和交互
- [ ] 截图和 PDF 生成
- [ ] CDP (Chrome DevTools Protocol)

### 8.2 网页解析
- [ ] DOM 操作
- [ ] 元素选择器
- [ ] 页面内容提取

---

## 九、语音技术

### 9.1 TTS（文本转语音）
- [ ] ElevenLabs API
- [ ] OpenAI TTS
- [ ] Microsoft Edge TTS
- [ ] 音频流处理

### 9.2 音频处理
- [ ] 音频格式转换
- [ ] 流式音频播放

---

## 十、架构设计模式

### 10.1 设计模式
- [ ] 依赖注入（DI）
- [ ] 工厂模式
- [ ] 观察者模式（Pub/Sub）
- [ ] 策略模式
- [ ] 适配器模式

### 10.2 架构风格
- [ ] 微内核架构（插件系统）
- [ ] 网关模式（Gateway）
- [ ] 事件驱动架构
- [ ] 管道/过滤器模式

---

## 十一、安全与权限

### 11.1 安全机制
- [ ] 执行审批系统
- [ ] 审计日志
- [ ] 沙箱隔离（Docker）
- [ ] 设备配对认证

### 11.2 凭证管理
- [ ] 环境变量
- [ ] 密钥存储
- [ ] OAuth 流程

---

## 十二、DevOps 与部署

### 12.1 容器化
- [ ] Dockerfile 编写
- [ ] Docker Compose
- [ ] 多阶段构建

### 12.2 进程管理
- [ ] 守护进程（Daemon）
- [ ] systemd/launchd 服务
- [ ] 进程间通信（IPC）

### 12.3 云服务
- [ ] Fly.io 部署
- [ ] Cloudflare Workers
- [ ] Tailscale 组网

---

## 十三、移动与桌面开发

### 13.1 跨平台框架
- [ ] **iOS**: Swift/SwiftUI
- [ ] **Android**: Kotlin
- [ ] **macOS**: SwiftUI/AppKit

### 13.2 本地服务发现
- [ ] Bonjour/mDNS
- [ ] 局域网通信

---

## 十四、测试与质量

### 14.1 测试框架
- [ ] Vitest
- [ ] 单元测试
- [ ] 集成测试
- [ ] E2E 测试

### 14.2 代码质量
- [ ] ESLint/Oxlint
- [ ] TypeScript 严格模式
- [ ] 代码覆盖率

---

## 十五、学习路径建议

### 初学者路径（按顺序）
1. JavaScript/TypeScript 基础
2. Node.js 核心模块
3. CLI 开发（Commander.js）
4. 异步编程与事件循环
5. Web 框架基础

### 进阶路径
1. AI/LLM 集成
2. 即时通讯平台集成
3. 架构设计模式
4. 浏览器自动化
5. 安全与权限

### 专家路径
1. 插件系统设计
2. 多 Agent 架构
3. 向量内存/RAG
4. 跨平台开发

---

## 十六、相关学习资源

- `01-nodejs-basics.ipynb` - Node.js 基础
- `02-cli-commanderjs.ipynb` - CLI 开发
- `03-pipe-concept.ipynb` - 进程间通信
- `commander-demo/` - 可运行示例

---

*注：本知识图谱基于 OpenClaw 项目扫描生成，涵盖约 100+ 个知识点。建议根据实际工作需要选择性深入学习。*
