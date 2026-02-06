# Day 4 练习：Prompt 2.0 实践

## 练习目标

通过编写Prompt 2.0，掌握用模型指导AI生成代码的方法。

---

## 任务一：分析Prompt 1.0的问题（10分钟）

以下是一个典型的Prompt 1.0，分析它的问题。

### Prompt 1.0

```
帮我写一个用户认证系统，要有登录和注册功能。
```

### 问题分析

| 问题类型 | 具体表现 |
|----------|----------|
| 需求模糊 | ________________________________ |
| 缺乏约束 | ________________________________ |
| 缺少验收 | ________________________________ |
| 其他 | ________________________________ |

### AI可能的误解

1. ________________________________
2. ________________________________
3. ________________________________

---

## 任务二：改写为Prompt 2.0（20分钟）

将上述Prompt改写为Prompt 2.0。

### 你的Prompt 2.0

```markdown
## 任务描述


## 领域模型

### 实体

**[实体名称]**
- 属性：
- 行为：

### 关系


## 架构要求


## 接口定义

```typescript

```

## 代码要求


## 测试要求

```

---

## 任务三：为OpenClaw功能编写Prompt 2.0（20分钟）

选择以下功能之一，编写完整的Prompt 2.0。

### 功能选择

| 功能 | 描述 | 难度 |
|------|------|------|
| A | 用户配额管理 | ⭐⭐ |
| B | 消息统计报表 | ⭐⭐⭐ |
| C | 多渠道消息同步 | ⭐⭐⭐ |

### 功能A：用户配额管理

**需求：**
- 限制每个用户每天的消息数量
- 支持不同类型的配额（普通用户/VIP用户）
- 配额用完后提示用户升级

**你的Prompt 2.0：**

```markdown

```

### 功能B：消息统计报表

**需求：**
- 统计每个用户的消息数量
- 按时间段生成报表（日/周/月）
- 支持导出CSV

**你的Prompt 2.0：**

```markdown

```

### 功能C：多渠道消息同步

**需求：**
- 将消息同步到多个渠道
- 如果一个渠道失败，重试其他渠道
- 记录同步状态

**你的Prompt 2.0：**

```markdown

```

---

## 任务四：Prompt评估（10分钟）

与同学交换Prompt，互相评估。

### 评估清单

- [ ] 是否有清晰的任务描述？
- [ ] 是否有领域模型？
- [ ] 模型是否MECE？
- [ ] 是否有架构要求？
- [ ] 是否有接口定义？
- [ ] 是否有验收标准？

### 反馈

**对方的优点：**

________________________

**可以改进的地方：**

________________________

---

## 参考答案（完成后对照）

<details>
<summary>点击查看功能A的参考答案</summary>

```markdown
## 任务描述
实现用户消息配额管理系统，限制用户每日消息数量。

## 领域模型

### 实体

**UserQuota（用户配额）- 实体**
- 属性：
  - userId: string - 用户ID
  - dailyLimit: number - 每日限额
  - usedCount: number - 已使用数量
  - resetTime: Date - 重置时间
  - quotaType: 'free' | 'basic' | 'premium' - 配额类型
- 行为：
  - canSend(): boolean - 检查是否可以发送
  - recordMessage(): void - 记录发送
  - getRemaining(): number - 获取剩余数量
  - reset(): void - 重置计数

**QuotaManager（配额管理器）- 领域服务**
- 行为：
  - checkAndRecord(userId): QuotaCheckResult
  - upgradeQuota(userId, type): void
  - getQuotaInfo(userId): QuotaInfo

**QuotaRepository（配额仓储）- 接口**
- 行为：
  - findByUserId(userId): UserQuota
  - save(quota): void

### 值对象

**QuotaCheckResult**
- allowed: boolean
- remaining: number
- message?: string

### 关系
UserQuota ← QuotaRepository ← QuotaManager

## 架构要求
- TypeScript实现
- 仓储模式隔离持久化
- 支持内存和Redis两种实现
- 定时任务每日重置配额

## 接口定义

```typescript
interface QuotaManager {
  checkAndRecord(userId: string): Promise<QuotaCheckResult>;
  upgradeQuota(userId: string, type: QuotaType): Promise<void>;
  getQuotaInfo(userId: string): Promise<QuotaInfo>;
}

interface QuotaRepository {
  findByUserId(userId: string): Promise<UserQuota | null>;
  save(quota: UserQuota): Promise<void>;
  delete(userId: string): Promise<void>;
}
```

## 代码要求
- 类名使用PascalCase
- 方法名使用camelCase
- 每个类单独文件
- 包含JSDoc注释
- 异常使用自定义错误类

## 测试要求
- 单元测试覆盖率 > 90%
- 测试边界情况（刚好用完、跨天重置）
- 模拟定时器测试重置逻辑

## 验收标准
- 用户超过配额时返回友好提示
- 支持动态升级配额（立即生效）
- 重置时间可配置（默认UTC 00:00）
- 性能：检查延迟 < 5ms
```

</details>

---

## 总结

### Prompt 2.0的核心要素

1. ________________________________
2. ________________________________
3. ________________________________
4. ________________________________

### 我的收获

使用Prompt 2.0后，AI生成代码的质量：
- 结构清晰度：从 ⭐⭐ 提升到 ⭐⭐⭐⭐⭐
- 可维护性：从 ⭐⭐ 提升到 ⭐⭐⭐⭐⭐
- 符合预期：从 ⭐⭐ 提升到 ⭐⭐⭐⭐⭐

---

*完成此练习后，你已经掌握了与AI协作的核心技能。*
