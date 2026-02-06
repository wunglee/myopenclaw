// AI生成的消息处理系统
// 场景：一个"能工作"但难以维护的代码示例

class MessageHandler {
  constructor() {
    this.handlers = {};
    this.middlewares = [];
    this.config = {
      maxRetries: 3,
      timeout: 5000,
      enableLog: true
    };
    this.stats = {
      received: 0,
      processed: 0,
      failed: 0
    };
  }

  use(middleware) {
    this.middlewares.push(middleware);
  }

  on(type, handler) {
    if (!this.handlers[type]) {
      this.handlers[type] = [];
    }
    this.handlers[type].push(handler);
  }

  async process(msg) {
    this.stats.received++;
    
    if (this.config.enableLog) {
      console.log(`[${new Date().toISOString()}] Received: ${msg.type}`);
    }

    // 执行中间件
    let context = { msg, user: msg.userId, timestamp: Date.now() };
    for (const mw of this.middlewares) {
      try {
        context = await mw(context) || context;
      } catch (e) {
        console.error('Middleware error:', e);
      }
    }

    // 判断消息类型
    const handlers = this.handlers[msg.type] || this.handlers['default'];
    if (!handlers) {
      this.stats.failed++;
      return { error: 'No handler found' };
    }

    // 执行处理器
    let result;
    let retries = 0;
    while (retries < this.config.maxRetries) {
      try {
        for (const handler of handlers) {
          result = await handler(context);
          if (result && result.stop) break;
        }
        this.stats.processed++;
        break;
      } catch (e) {
        retries++;
        if (retries >= this.config.maxRetries) {
          this.stats.failed++;
          result = { error: e.message };
        }
      }
    }

    return result;
  }

  getStats() {
    return { ...this.stats };
  }
}

// ====== 使用示例 ======

const handler = new MessageHandler();

// 添加中间件
handler.use(async (ctx) => {
  console.log('Auth check:', ctx.user);
  return ctx;
});

// 注册处理器
handler.on('text', async (ctx) => {
  return { reply: `You said: ${ctx.msg.content}` };
});

handler.on('image', async (ctx) => {
  return { reply: `Received image: ${ctx.msg.content}` };
});

handler.on('command', async (ctx) => {
  if (ctx.msg.content === '/help') {
    return { reply: 'Available commands: /help, /status' };
  }
  if (ctx.msg.content === '/status') {
    return { reply: `Stats: ${JSON.stringify(handler.getStats())}` };
  }
  return { reply: 'Unknown command' };
});

// 默认处理器
handler.on('default', async (ctx) => {
  return { reply: 'Unknown message type' };
});

// ====== 测试代码 ======

async function test() {
  console.log('=== 测试 AI 生成的消息处理器 ===\n');

  // 测试1: 普通消息
  const result1 = await handler.process({
    type: 'text',
    userId: 'user123',
    content: 'Hello AI!'
  });
  console.log('Test 1 - Text message:', result1);

  // 测试2: 命令
  const result2 = await handler.process({
    type: 'command',
    userId: 'user123',
    content: '/help'
  });
  console.log('Test 2 - Command:', result2);

  // 测试3: 图片
  const result3 = await handler.process({
    type: 'image',
    userId: 'user456',
    content: 'photo.jpg'
  });
  console.log('Test 3 - Image:', result3);

  console.log('\n=== 最终统计 ===');
  console.log(handler.getStats());
}

// 如果直接运行此文件，执行测试
if (require.main === module) {
  test().catch(console.error);
}

module.exports = { MessageHandler };
