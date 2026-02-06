# OpenClaw 实体分析示例

## 核心实体

### 1. Message（消息）

**属性：**
- id: string - 消息唯一标识
- channelId: string - 来自哪个通道
- userId: string - 发送者ID
- type: 'text' | 'image' | 'command' | 'audio' - 消息类型
- content: string - 消息内容
- timestamp: number - 发送时间戳
- metadata: object - 附加信息

**行为：**
- isCommand(): boolean - 是否是命令
- getTargetAgent(): string - 应该发给哪个代理
- extractMentions(): string[] - 提取@提及的用户

---

### 2. Channel（通道）

**属性：**
- id: string - 通道ID
- type: 'telegram' | 'discord' | 'slack' | 'imessage' | 'web' - 通道类型
- name: string - 通道名称
- config: object - 配置信息（token, webhook等）
- status: 'active' | 'inactive' | 'error' - 状态

**行为：**
- connect(): Promise<void> - 连接通道
- disconnect(): Promise<void> - 断开连接
- send(message: Message): Promise<void> - 发送消息
- onMessage(handler: Function): void - 接收消息回调

---

### 3. Agent（代理）

**属性：**
- id: string - 代理ID
- name: string - 代理名称
- description: string - 描述
- type: 'assistant' | 'autonomous' | 'workflow' - 代理类型
- config: {
  - model: string - AI模型（gpt-4, claude等）
  - temperature: number - 温度参数
  - systemPrompt: string - 系统提示词
  - maxTokens: number - 最大token数
- status: string - 状态
- capabilities: string[] - 能力列表

**行为：**
- process(message: Message): Promise<Response> - 处理消息
- callTool(toolName: string, params: object): Promise<any> - 调用工具
- getCapabilities(): string[] - 获取能力列表
- updateConfig(config: object): void - 更新配置

---

### 4. User（用户）

**属性：**
- id: string - 用户ID
- name: string - 用户名
- email: string - 邮箱
- role: 'admin' | 'user' | 'guest' - 角色
- permissions: string[] - 权限列表
- preferences: object - 偏好设置
- createdAt: Date - 创建时间

**行为：**
- hasPermission(permission: string): boolean - 检查权限
- canUseAgent(agentId: string): boolean - 能否使用某代理
- updatePreferences(prefs: object): void - 更新偏好

---

### 5. RoutingRule（路由规则）

**属性：**
- id: string - 规则ID
- name: string - 规则名称
- pattern: string | RegExp - 匹配模式
- targetAgentId: string - 目标代理ID
- priority: number - 优先级（数字越小优先级越高）
- conditions: object - 附加条件
- isActive: boolean - 是否启用

**行为：**
- matches(message: Message): boolean - 是否匹配消息
- apply(message: Message): string - 应用规则，返回目标代理ID

---

## 实体关系图

```
┌─────────┐     发送      ┌─────────┐
│  User   │──────────────→│ Message │
└─────────┘               └────┬────┘
                               │
                               │ 属于
                               ↓
┌─────────┐     来自      ┌─────────┐
│ Channel │←──────────────┤ Message │
└────┬────┘               └─────────┘
     │
     │ 路由到
     ↓
┌─────────┐     匹配      ┌─────────┐
│ Routing │←──────────────┤ Message │
│  Rule   │               └─────────┘
└────┬────┘
     │ 决定
     ↓
┌─────────┐     处理      ┌─────────┐
│  Agent  │←──────────────┤ Message │
└────┬────┘               └─────────┘
     │
     │ 生成
     ↓
┌─────────┐
│ Response│
└─────────┘
```

---

## 值对象示例

### Target（目标）

```typescript
class Target {
  constructor(
    public channelId: string,
    public userId: string,
    public threadId?: string
  ) {}
  
  toString(): string {
    return `${this.channelId}:${this.userId}`;
  }
}
```

### Config（配置）

```typescript
class AgentConfig {
  constructor(
    public model: string,
    public temperature: number = 0.7,
    public maxTokens: number = 2000,
    public systemPrompt: string = ''
  ) {}
}
```
