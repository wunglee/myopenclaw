# Prompt 2.0 示例（正面教材）

## 示例1：消息路由系统

### ✅ Prompt

````markdown
## 任务描述
实现一个消息路由系统，根据消息内容决定由哪个处理器处理。

## 领域模型

```
┌─────────────────────────────────────┐
│           MessageRouter             │
│  ┌─────────┐      ┌──────────────┐  │
│  │ Message │─────→│ RoutingRule  │  │
│  └─────────┘      └──────┬───────┘  │
│                          │          │
│                          ↓          │
│                    ┌──────────┐     │
│                    │ Handler  │     │
│                    └──────────┘     │
└─────────────────────────────────────┘
```

### 实体

**Message（消息）**
- 属性：id, type, content, userId, timestamp
- 行为：isCommand(), getTargetAgent()

**RoutingRule（路由规则）**
- 属性：id, pattern, targetHandler, priority
- 行为：matches(message): boolean, apply(message): Handler

**MessageRouter（路由器）**
- 属性：rules: RoutingRule[]
- 行为：register(rule), route(message): Handler

**Handler（处理器）**
- 属性：name, type
- 行为：handle(message): Response

### 关系
- Message → MessageRouter → RoutingRule → Handler

## 架构要求
- 使用TypeScript
- 分层架构：领域层（模型）+ 应用层（服务）
- 遵循SOLID原则

## 接口定义
```typescript
interface MessageRouter {
  register(rule: RoutingRule): void;
  route(message: Message): Handler;
}
```

## 代码要求
- 类名使用PascalCase
- 方法名使用camelCase
- 每个类单独文件
- 包含基本单元测试
````

### 结果

- 结构清晰，符合模型
- 命名规范一致
- 易于理解和维护
- 可独立测试每个组件

---

## 示例2：频率限制功能

### ✅ Prompt

````markdown
## 任务描述
实现用户消息频率限制功能，防止滥用。

## 领域模型

**UserQuota（用户配额）- 实体**
- 属性：userId, messageCount, windowStart
- 行为：
  - canSendMessage(limit, windowMs): boolean
  - recordMessage(): void
  - getRetryAfter(windowMs): number

**RateLimiter（频率限制器）- 领域服务**
- 依赖：QuotaRepository
- 行为：
  - checkLimit(userId): FilterResult

**QuotaRepository（配额仓储）- 接口**
- 行为：
  - getQuota(userId): UserQuota
  - saveQuota(quota): void

## 算法
使用滑动窗口计数：
1. 获取用户配额
2. 检查窗口是否过期，过期则重置
3. 检查是否超过限制
4. 记录本次消息

## 边界情况
- 新用户：允许发送，初始化配额
- 窗口过期：重置计数
- 并发请求：确保原子性

## 代码要求
- TypeScript实现
- 内存仓储实现（后续可替换为Redis）
- 完整的单元测试
- 包含性能基准测试
````

### 结果

- 领域模型清晰
- 职责分离明确
- 易于扩展（更换存储）
- 可测试性强

---

## 示例3：完整功能模块

### ✅ Prompt

````markdown
## 任务描述
为OpenClaw实现消息过滤器模块。

## 领域模型

### 限界上下文：消息过滤

**实体：**
- FilterRule: id, name, pattern, type, action, isActive
- FilterResult: matched, rule, action, reason

**领域服务：**
- FilterEngine: filter(), addRule(), removeRule()

**策略：**
- FilterStrategy（接口）
  - KeywordFilterStrategy
  - RegexFilterStrategy

**仓储：**
- FilterRuleRepository（接口）
  - InMemoryFilterRuleRepository

### 集成点
在MessageHandler.handle()中添加过滤检查：
```typescript
const result = this.filterEngine.filter(message);
if (result.matched) {
  return this.handleFiltered(message, result);
}
```

## 架构要求
- 策略模式实现多种过滤方式
- 仓储接口隔离持久化
- 异步处理支持

## 测试要求
- 单元测试：策略、引擎、仓储
- 集成测试：与MessageHandler集成
- 边界情况：空规则、并发、性能

## 性能要求
- 过滤延迟 < 1ms
- 支持1000条规则
````

### 结果

- 完整的功能实现
- 符合MECE原则
- 可独立测试
- 易于集成

---

## Prompt 2.0 核心要素

| 要素 | 作用 | 示例 |
|------|------|------|
| 任务描述 | 明确做什么 | "实现消息路由系统" |
| 领域模型 | 定义结构 | 实体、关系图 |
| 架构要求 | 技术约束 | "使用TypeScript" |
| 接口定义 | 明确契约 | "interface MessageRouter" |
| 边界情况 | 处理异常 | "并发请求" |
| 验收标准 | 验证成功 | "延迟<1ms" |

**核心原则：先给模型，再要代码**
