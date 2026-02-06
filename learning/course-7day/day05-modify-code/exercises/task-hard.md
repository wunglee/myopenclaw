# Day 5 练习（困难）：添加新命令

## 任务目标

为OpenClaw实现一个新的斜杠命令。

---

## 难度

⭐⭐⭐ 困难

预计时间：60-90分钟

---

## 任务描述

实现 `/stats` 命令，允许用户查看自己的使用统计：

- 今日消息数
- 本周消息数
- 本月消息数
- 最常用的代理

---

## 前置要求

- 完成简单和中等任务
- 理解OpenClaw的命令系统

---

## 步骤指南

### 步骤1：了解命令系统

**查找现有命令实现：**

```bash
# 搜索命令相关代码
grep -r "command" src/ --include="*.ts" | head -20

# 查找斜杠命令处理
grep -r "/" src/ --include="*.ts" | grep "command"
```

**关键文件：**
- `src/commands/` - 命令定义
- `src/routing/command-handler.ts` - 命令处理

### 步骤2：设计数据模型

需要存储哪些数据？

```typescript
// 用户统计实体
interface UserStats {
  userId: string;
  daily: { date: string; count: number }[];
  weekly: { week: string; count: number }[];
  monthly: { month: string; count: number }[];
  agentUsage: { agentId: string; count: number }[];
}
```

### 步骤3：实现统计收集

**方案：** 在消息处理时收集统计

```typescript
// src/statistics/stats-collector.ts
class StatsCollector {
  constructor(private statsRepo: StatsRepository) {}
  
  async recordMessage(message: Message, agentId: string): Promise<void> {
    const today = new Date().toISOString().split('T')[0];
    
    await this.statsRepo.incrementDaily(message.userId, today);
    await this.statsRepo.incrementAgentUsage(message.userId, agentId);
  }
}
```

### 步骤4：实现命令处理器

```typescript
// src/commands/stats-command.ts
@Command('/stats')
export class StatsCommand implements CommandHandler {
  constructor(
    private statsRepo: StatsRepository,
    private formatter: StatsFormatter
  ) {}
  
  async execute(context: CommandContext): Promise<Response> {
    const userId = context.userId;
    const stats = await this.statsRepo.getStats(userId);
    
    const message = this.formatter.format(stats);
    
    return { content: message };
  }
}

// 格式化器
class StatsFormatter {
  format(stats: UserStats): string {
    return `
📊 你的使用统计

📅 今日：${stats.daily[0]?.count || 0} 条消息
📆 本周：${this.getWeeklyTotal(stats)} 条消息
📈 本月：${this.getMonthlyTotal(stats)} 条消息

🤖 最常用代理：${this.getTopAgent(stats)}
    `.trim();
  }
  
  private getWeeklyTotal(stats: UserStats): number {
    return stats.daily.slice(0, 7).reduce((sum, d) => sum + d.count, 0);
  }
  
  private getMonthlyTotal(stats: UserStats): number {
    return stats.daily.reduce((sum, d) => sum + d.count, 0);
  }
  
  private getTopAgent(stats: UserStats): string {
    const top = stats.agentUsage.sort((a, b) => b.count - a.count)[0];
    return top ? `${top.agentId} (${top.count}次)` : '暂无';
  }
}
```

### 步骤5：注册命令

```typescript
// src/commands/index.ts
export const commands = [
  // ... 现有命令
  new StatsCommand(statsRepo, formatter)
];
```

### 步骤6：集成统计收集

```typescript
// src/routing/message-handler.ts
class MessageHandler {
  constructor(
    // ... 其他依赖
    private statsCollector: StatsCollector
  ) {}
  
  async handle(message: Message): Promise<Response> {
    // ... 其他处理
    
    const response = await this.processMessage(message);
    
    // 记录统计
    await this.statsCollector.recordMessage(
      message,
      response.agentId
    );
    
    return response;
  }
}
```

---

## 数据持久化方案

### 方案A：内存存储（简单）

```typescript
class InMemoryStatsRepository implements StatsRepository {
  private stats = new Map<string, UserStats>();
  
  async incrementDaily(userId: string, date: string): Promise<void> {
    const stats = this.getOrCreateStats(userId);
    const day = stats.daily.find(d => d.date === date);
    if (day) {
      day.count++;
    } else {
      stats.daily.push({ date, count: 1 });
    }
  }
  
  // ... 其他方法
}
```

### 方案B：文件存储（中等）

```typescript
class FileStatsRepository implements StatsRepository {
  constructor(private filePath: string) {}
  
  async incrementDaily(userId: string, date: string): Promise<void> {
    const stats = await this.loadStats();
    // 修改并保存
    await this.saveStats(stats);
  }
  
  private async loadStats(): Promise<Map<string, UserStats>> {
    const data = await fs.readFile(this.filePath, 'utf8');
    return new Map(JSON.parse(data));
  }
  
  private async saveStats(stats: Map<string, UserStats>): Promise<void> {
    await fs.writeFile(
      this.filePath,
      JSON.stringify(Array.from(stats.entries()))
    );
  }
}
```

### 方案C：数据库存储（困难）

```typescript
class DatabaseStatsRepository implements StatsRepository {
  constructor(private db: Database) {}
  
  async incrementDaily(userId: string, date: string): Promise<void> {
    await this.db.query(`
      INSERT INTO daily_stats (user_id, date, count)
      VALUES (?, ?, 1)
      ON CONFLICT (user_id, date)
      DO UPDATE SET count = count + 1
    `, [userId, date]);
  }
  
  // ... 其他方法
}
```

---

## 检查清单

- [ ] 理解了命令系统架构
- [ ] 设计了数据模型
- [ ] 实现了统计收集
- [ ] 实现了命令处理器
- [ ] 实现了格式化器
- [ ] 注册了命令
- [ ] 集成了统计收集
- [ ] 选择了持久化方案
- [ ] 添加了测试
- [ ] 测试通过

---

## 进阶挑战

1. **添加时间范围参数**
   ```
   /stats today
   /stats week
   /stats month
   /stats 2025-01
   ```

2. **添加排行榜**
   ```
   /stats leaderboard
   ```

3. **添加图表**
   - 生成ASCII图表
   - 或生成图片图表

4. **添加导出功能**
   ```
   /stats export
   ```

---

## 参考实现

如果需要参考，可以查看OpenClaw现有的命令实现：
- `/help` 命令
- `/status` 命令

---

*完成此困难任务，你已经具备了为OpenClaw贡献功能的能力！*
