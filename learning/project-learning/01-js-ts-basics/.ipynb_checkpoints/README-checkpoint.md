# 01 JavaScript/TypeScript 基础

本目录包含 JavaScript 和 TypeScript 语言基础的学习内容。

## 章节列表（每个文件独立）

按顺序学习：

| 序号 | 文件 | 内容 | 预计时间 |
|------|------|------|----------|
| 1.1 | [01-01-why-typescript.ipynb](./01-01-why-typescript.ipynb) | 为什么需要 TypeScript | 5 分钟 |
| 1.2 | [01-02-basic-types.ipynb](./01-02-basic-types.ipynb) | 基础类型注解 | 10 分钟 |
| 1.3 | [01-03-type-aliases.ipynb](./01-03-type-aliases.ipynb) | 类型别名 type | 15 分钟 |
| 1.4 | [01-04-interfaces.ipynb](./01-04-interfaces.ipynb) | 接口 interface | 10 分钟 |
| 1.5 | [01-05-function-types.ipynb](./01-05-function-types.ipynb) | 函数类型 | 10 分钟 |
| 1.6 | [01-06-generics.ipynb](./01-06-generics.ipynb) | 泛型基础 | 10 分钟 |
| 1.7 | [01-07-cheatsheet.ipynb](./01-07-cheatsheet.ipynb) | 快速参考卡片 | 5 分钟 |

## 核心概念（刚好够用）

### 1. 基础类型
```typescript
const port: number = 8080;
const name: string = "OpenClaw";
const channels: string[] = ["telegram", "discord"];
```

### 2. 类型别名（项目中大量使用）
```typescript
type MessagingTargetKind = "user" | "channel";

type MessagingTarget = {
  kind: MessagingTargetKind;
  id: string;
  raw: string;
  normalized: string;
};
```

### 3. 接口
```typescript
interface GatewayConfig {
  port: number;
  host: string;
  verbose?: boolean;  // ? 表示可选
}
```

### 4. 函数类型
```typescript
function normalizeTargetId(kind: string, id: string): string {
  return `${kind}:${id}`.toLowerCase();
}
```

## 关键要点

- `type` 用于创建类型别名（项目中更常见）
- `interface` 用于定义对象结构（需要扩展时用）
- `?:` 表示可选属性
- `|` 表示联合类型（如 `"a" | "b"`）
- 简单对象用 `type`，需要扩展用 `interface`

## 学习方法

1. 按顺序阅读每个 `.ipynb` 文件
2. 在 Jupyter 中运行代码块
3. 参考项目中的真实代码（如 `src/channels/targets.ts`）
4. 最后看 [01-07-cheatsheet.ipynb](./01-07-cheatsheet.ipynb) 复习

## 下一步

完成本章节后，请继续学习 [02-nodejs-core/](../02-nodejs-core/)
