# Day 5 练习（中等）：修改响应格式

## 任务目标

修改OpenClaw的响应格式化方式，支持多种格式。

---

## 难度

⭐⭐ 中等

预计时间：45-60分钟

---

## 任务描述

当前OpenClaw的响应格式是固定的，现在需要支持：

1. **Markdown格式**（默认）
2. **纯文本格式**
3. **HTML格式**（用于Web渠道）

根据消息来源的渠道自动选择合适的格式。

---

## 步骤指南

### 步骤1：找到相关代码

需要修改的文件：

1. **查找响应生成代码**
   - 提示：查看 `src/agents/` 目录
   - 文件：`agent.ts` 或 `agent-runner.ts`

2. **查找渠道适配代码**
   - 提示：查看 `src/channels/` 或具体渠道目录
   - 文件：`telegram-formatter.ts`, `discord-formatter.ts`

### 步骤2：设计实现方案

**方案A：在Agent层添加格式选择**

```typescript
// src/agents/agent.ts
interface Response {
  content: string;
  format: 'markdown' | 'text' | 'html';
}

class Agent {
  async process(message: Message): Promise<Response> {
    // 生成内容
    const content = await this.generateContent(message);
    
    // 根据渠道选择格式
    const format = this.determineFormat(message.channelType);
    
    return { content, format };
  }
  
  private determineFormat(channelType: string): ResponseFormat {
    switch (channelType) {
      case 'telegram': return 'markdown';
      case 'web': return 'html';
      default: return 'text';
    }
  }
}
```

**方案B：在Formatter层处理转换**

```typescript
// src/channels/formatter.ts
class ResponseFormatter {
  format(response: Response, targetFormat: string): string {
    switch (targetFormat) {
      case 'html':
        return this.markdownToHtml(response.content);
      case 'text':
        return this.markdownToText(response.content);
      default:
        return response.content;
    }
  }
  
  private markdownToHtml(markdown: string): string {
    // 实现转换
  }
  
  private markdownToText(markdown: string): string {
    // 实现转换
  }
}
```

### 步骤3：实现代码

选择方案A或方案B，或者结合两者，实现多格式支持。

### 步骤4：添加测试

```typescript
// test/channels/formatter.test.ts
describe('ResponseFormatter', () => {
  it('should convert markdown to HTML', () => {
    const formatter = new ResponseFormatter();
    const html = formatter.format(
      { content: '**bold**', format: 'markdown' },
      'html'
    );
    expect(html).toContain('<strong>bold</strong>');
  });
  
  it('should convert markdown to plain text', () => {
    // 你的测试
  });
});
```

---

## 预期结果

**输入：**
```markdown
Hello **World**
- Item 1
- Item 2
```

**输出（HTML）：**
```html
Hello <strong>World</strong>
<ul>
  <li>Item 1</li>
  <li>Item 2</li>
</ul>
```

**输出（纯文本）：**
```
Hello World
- Item 1
- Item 2
```

---

## 检查清单

- [ ] 找到响应生成代码
- [ ] 找到渠道格式化代码
- [ ] 设计并实现格式转换
- [ ] 支持Markdown→HTML
- [ ] 支持Markdown→纯文本
- [ ] 根据渠道自动选择格式
- [ ] 添加单元测试
- [ ] 测试通过

---

## 提示

### Markdown转HTML参考

```typescript
function markdownToHtml(markdown: string): string {
  return markdown
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.+?)\*/g, '<em>$1</em>')
    .replace(/^- (.+)$/gm, '<li>$1</li>')
    .replace(/(<li>.+<\/li>\n?)+/g, '<ul>$&</ul>');
}
```

### Markdown转纯文本参考

```typescript
function markdownToText(markdown: string): string {
  return markdown
    .replace(/\*\*(.+?)\*\*/g, '$1')
    .replace(/\*(.+?)\*/g, '$1')
    .replace(/^- /gm, '• ');
}
```

---

## 进阶挑战（可选）

1. **支持更多格式**
   - JSON格式（API响应）
   - XML格式（旧系统集成）

2. **支持格式配置**
   - 用户可自定义格式
   - 按消息类型设置格式

3. **优化转换性能**
   - 缓存转换结果
   - 使用专门的Markdown解析库

---

*完成此练习后，你已经掌握了修改OpenClaw核心功能的能力！*
