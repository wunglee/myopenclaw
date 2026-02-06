# 04 异步编程 (Async Programming)

> Node.js的核心：从事件循环到 Async/Await 的完整掌握

---

## 本单元内容

| 章节 | 文件 | 内容 | 预计时间 |
|------|------|------|----------|
| 04-01 | [04-01-event-loop.ipynb](./04-01-event-loop.ipynb) | 事件循环机制 | 45分钟 |
| 04-02 | [04-02-callbacks.ipynb](./04-02-callbacks.ipynb) | 回调函数与回调地狱 | 45分钟 |
| 04-03 | [04-03-promises.ipynb](./04-03-promises.ipynb) | Promise 与链式调用 | 60分钟 |
| 04-04 | [04-04-async-await.ipynb](./04-04-async-await.ipynb) | Async/Await 现代写法 | 60分钟 |

**总学习时间：** 约3.5小时

---

## 为什么重要？

异步编程是理解 OpenClaw 源码的关键：

1. **消息处理** - OpenClaw 的消息路由使用事件驱动架构
2. **AI调用** - LLM API 调用都是异步的
3. **并发控制** - 管理多个同时进行的对话
4. **错误处理** - 异步链中的错误传播

---

## 学习路径

```
事件循环 → 回调 → Promise → Async/Await
  (理解)    (历史)   (过渡)    (现代写法)
```

---

## Java开发者注意

| Java概念 | Node.js等价 |
|----------|-------------|
| ThreadPoolExecutor | 事件循环 + 线程池 |
| CompletableFuture | Promise / async-await |
| Future.get() | await |
| thenApply/thenCompose | .then() / await |

---

## 实践项目

完成本单元后，尝试：

1. **重写文件处理工具** - 用 async/await 重写之前用回调写的文件处理代码
2. **实现并发下载器** - 下载多个URL，限制并发数为3
3. **分析 OpenClaw 源码** - 找到其中的异步模式

---

## 下一步

- [05-web-development](../05-web-development/) - Web开发基础
- 或回到 [03-cli-development](../03-cli-development/) 巩固CLI知识
