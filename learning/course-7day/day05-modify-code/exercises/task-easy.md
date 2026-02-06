# Day 5 练习（简单）：添加日志功能

## 任务目标

在OpenClaw的消息处理流程中添加日志输出，帮助调试和监控。

---

## 难度

⭐ 简单

预计时间：30-45分钟

---

## 任务描述

在以下关键节点添加日志输出：

1. **接收消息时**
   - 记录：消息类型、用户ID、时间戳

2. **路由决策时**
   - 记录：目标代理、路由规则ID

3. **处理完成时**
   - 记录：处理耗时、响应长度

---

## 步骤指南

### 步骤1：找到文件

日志应该添加在哪个文件？

**提示：** 查看 `src/routing/message-handler.ts`

### 步骤2：了解日志工具

OpenClaw使用什么日志工具？

```typescript
// 查看 src/infra/logger.ts
import { logger } from '../infra/logger';

// 使用
logger.info('消息', { userId: 'xxx', type: 'text' });
logger.warn('警告', { reason: 'xxx' });
logger.error('错误', { error: err });
```

### 步骤3：添加日志

在 `handle()` 方法中添加日志：

```typescript
async handle(message: Message): Promise<Response> {
  // 1. 记录接收消息
  logger.info('Message received', {
    messageId: message.id,
    userId: message.userId,
    type: message.type,
    timestamp: Date.now()
  });
  
  // ... 原有代码
  
  // 2. 记录路由决策
  // 你的代码
  
  // ... 原有代码
  
  // 3. 记录处理完成
  // 你的代码
  
  return response;
}
```

### 步骤4：测试

```bash
# 运行测试
pnpm test

# 启动开发模式
pnpm dev

# 发送测试消息，观察日志输出
```

---

## 预期输出

```
[2025-01-15T10:30:00Z] INFO: Message received
  messageId: "msg-001"
  userId: "user123"
  type: "text"
  timestamp: 1705312200000

[2025-01-15T10:30:01Z] INFO: Message routed
  messageId: "msg-001"
  targetAgent: "assistant"
  ruleId: "rule-001"

[2025-01-15T10:30:02Z] INFO: Message processed
  messageId: "msg-001"
  duration: 1200
  responseLength: 256
```

---

## 检查清单

- [ ] 找到了正确的文件
- [ ] 导入logger成功
- [ ] 在接收时添加日志
- [ ] 在路由时添加日志
- [ ] 在完成时添加日志
- [ ] 测试通过
- [ ] 代码通过 lint 检查

---

## 提交代码

```bash
git add .
git commit -m "feat(routing): add logging to message handling

- Log message reception with id, userId, type
- Log routing decision with target agent
- Log processing completion with duration

Closes #[issue number]"

git push origin feature/add-logging
```

---

## 进阶挑战（可选）

如果你完成了简单任务，可以尝试：

1. **添加性能指标日志**
   - 记录每个步骤的耗时
   - 识别性能瓶颈

2. **添加结构化日志**
   - 使用JSON格式
   - 方便日志分析

3. **添加日志级别配置**
   - 根据环境设置不同级别
   - 生产环境减少日志

---

## 需要帮助？

1. 查看 `src/infra/logger.ts` 了解日志API
2. 参考其他文件中的日志用法
3. 在社群提问

---

*完成此练习后，你已经成功修改了OpenClaw代码！*
