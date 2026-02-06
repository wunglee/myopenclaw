// 基于模型思维重构的消息处理系统
// 特点：清晰的领域边界，易于维护和扩展

// ==================== 领域模型 ====================

/**
 * 值对象：消息
 * 不可变，通过构造函数创建
 */
class Message {
  constructor({ id, userId, type, content, timestamp }) {
    this.id = id;
    this.userId = userId;
    this.type = type;
    this.content = content;
    this.timestamp = timestamp || Date.now();
  }

  isType(type) {
    return this.type === type;
  }
}

/**
 * 实体：用户配额
 * 有状态变化，通过ID标识
 */
class UserQuota {
  constructor(userId) {
    this.userId = userId;
    this.messageCount = 0;
    this.windowStart = Date.now();
  }

  /**
   * 检查是否可以发送消息
   * @param {number} limit - 限制次数
   * @param {number} windowMs - 时间窗口（毫秒）
   * @returns {boolean}
   */
  canSendMessage(limit = 10, windowMs = 60000) {
    const now = Date.now();
    
    // 窗口过期，重置计数
    if (now - this.windowStart > windowMs) {
      this.messageCount = 0;
      this.windowStart = now;
    }
    
    return this.messageCount < limit;
  }

  /**
   * 记录一条消息
   */
  recordMessage() {
    this.messageCount++;
  }

  /**
   * 获取下次重置时间
   * @param {number} windowMs
   * @returns {number} 剩余毫秒数
   */
  getRetryAfter(windowMs = 60000) {
    return Math.max(0, this.windowStart + windowMs - Date.now());
  }
}

// ==================== 仓储接口 ====================

/**
 * 配额仓储
 * 负责用户配额的持久化（当前使用内存，可替换为Redis/DB）
 */
class QuotaRepository {
  constructor() {
    this.quotas = new Map();
  }

  getQuota(userId) {
    if (!this.quotas.has(userId)) {
      this.quotas.set(userId, new UserQuota(userId));
    }
    return this.quotas.get(userId);
  }

  clear() {
    this.quotas.clear();
  }
}

// ==================== 限界上下文：消息路由 ====================

/**
 * 消息路由器
 * 职责：根据消息类型找到对应的处理器
 */
class MessageRouter {
  constructor() {
    this.routes = new Map();
  }

  register(messageType, handler) {
    if (typeof handler !== 'function') {
      throw new Error('Handler must be a function');
    }
    this.routes.set(messageType, handler);
  }

  route(message) {
    const handler = this.routes.get(message.type);
    if (!handler) {
      throw new Error(`No handler for type: ${message.type}`);
    }
    return handler;
  }

  unregister(messageType) {
    this.routes.delete(messageType);
  }

  listRoutes() {
    return Array.from(this.routes.keys());
  }
}

// ==================== 限界上下文：频率限制 ====================

/**
 * 频率限制器
 * 职责：控制用户发送频率
 */
class RateLimiter {
  constructor(quotaRepository, limit = 10, windowMs = 60000) {
    this.quotaRepo = quotaRepository;
    this.limit = limit;
    this.windowMs = windowMs;
  }

  /**
   * 检查发送限制
   * @param {string} userId
   * @returns {Object} { allowed: boolean, error?: string, retryAfter?: number }
   */
  checkLimit(userId) {
    const quota = this.quotaRepo.getQuota(userId);

    if (!quota.canSendMessage(this.limit, this.windowMs)) {
      return {
        allowed: false,
        error: '发送太频繁，请稍后再试',
        retryAfter: quota.getRetryAfter(this.windowMs)
      };
    }

    quota.recordMessage();
    return { allowed: true };
  }

  /**
   * 更新限制配置
   */
  updateConfig(limit, windowMs) {
    this.limit = limit;
    this.windowMs = windowMs;
  }
}

// ==================== 应用服务 ====================

/**
 * 消息服务
 * 职责：协调各领域完成消息处理
 */
class MessageService {
  constructor(router, rateLimiter) {
    this.router = router;
    this.rateLimiter = rateLimiter;
    this.stats = {
      received: 0,
      processed: 0,
      rejected: 0
    };
  }

  async handleMessage(messageData) {
    this.stats.received++;

    // 1. 创建消息对象
    const message = new Message(messageData);

    // 2. 检查频率限制（领域规则）
    const limitCheck = this.rateLimiter.checkLimit(message.userId);
    if (!limitCheck.allowed) {
      this.stats.rejected++;
      return {
        success: false,
        error: limitCheck.error,
        retryAfter: limitCheck.retryAfter
      };
    }

    // 3. 路由到对应处理器
    const handler = this.router.route(message);
    
    // 4. 执行处理
    try {
      const result = await handler(message);
      this.stats.processed++;
      return { success: true, data: result };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  getStats() {
    return { ...this.stats };
  }
}

// ==================== 领域事件（扩展）====================

/**
 * 消息处理事件
 * 可用于日志、监控、扩展
 */
class MessageProcessedEvent {
  constructor(message, result, timestamp = Date.now()) {
    this.message = message;
    this.result = result;
    this.timestamp = timestamp;
  }
}

// ==================== 工厂方法 ====================

/**
 * 创建默认配置的服务
 */
function createDefaultService(options = {}) {
  const quotaRepo = new QuotaRepository();
  const router = new MessageRouter();
  const rateLimiter = new RateLimiter(
    quotaRepo,
    options.limit || 10,
    options.windowMs || 60000
  );
  const service = new MessageService(router, rateLimiter);

  return { service, router, quotaRepo };
}

// ==================== 使用示例 ====================

async function demo() {
  console.log('=== 基于模型思维的消息处理器 ===\n');

  const { service, router } = createDefaultService({
    limit: 3,  // 每分钟3条，方便测试
    windowMs: 60000
  });

  // 注册处理器
  router.register('text', async (message) => {
    return { reply: `You said: ${message.content}` };
  });

  router.register('image', async (message) => {
    return { reply: `Received image: ${message.content}` };
  });

  router.register('command', async (message) => {
    if (message.content === '/help') {
      return { reply: 'Available commands: /help, /status' };
    }
    return { reply: 'Unknown command' };
  });

  // 测试1: 正常消息
  console.log('--- 测试1: 正常消息 ---');
  const result1 = await service.handleMessage({
    id: 'msg-001',
    type: 'text',
    userId: 'user123',
    content: 'Hello!'
  });
  console.log('Result:', result1);

  // 测试2: 频率限制
  console.log('\n--- 测试2: 频率限制（连续发送5条） ---');
  for (let i = 0; i < 5; i++) {
    const result = await service.handleMessage({
      id: `msg-${i + 2}`,
      type: 'text',
      userId: 'user123',
      content: `Message ${i + 2}`
    });
    console.log(`Message ${i + 2}:`, result.success ? '成功' : `被拒绝 - ${result.error}`);
  }

  // 测试3: 不同用户（应该不受影响）
  console.log('\n--- 测试3: 不同用户 ---');
  const result3 = await service.handleMessage({
    id: 'msg-other',
    type: 'text',
    userId: 'user456',
    content: 'I am different user'
  });
  console.log('Other user result:', result3);

  console.log('\n=== 最终统计 ===');
  console.log(service.getStats());
}

// 如果直接运行此文件，执行测试
if (require.main === module) {
  demo().catch(console.error);
}

// ==================== 导出 ====================

module.exports = {
  // 领域模型
  Message,
  UserQuota,
  MessageProcessedEvent,
  
  // 仓储
  QuotaRepository,
  
  // 限界上下文
  MessageRouter,
  RateLimiter,
  
  // 应用服务
  MessageService,
  
  // 工厂
  createDefaultService
};
