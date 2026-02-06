# Commander.js 学习示例

可运行的 Node.js 示例项目，演示 Commander.js 的核心功能。

## 快速开始

```bash
cd learning/commander-demo
npm install
node demo.js --help
```

## 测试命令

### 1. 查看帮助
```bash
node demo.js --help
node demo.js start --help
```

### 2. 全局选项测试
```bash
# 带全局选项
node demo.js -v start
node demo.js --config /path/to/config.json start
```

### 3. start 命令
```bash
# 使用默认值
node demo.js start

# 自定义参数
node demo.js start -p 8080
node demo.js start --port 8080 --host 0.0.0.0
node demo.js start -p 3001 -f
node demo.js start -v -p 9000 --force
```

### 4. stop 命令
```bash
node demo.js stop
node demo.js stop -f
node demo.js stop --timeout 60
```

### 5. list 命令（带参数）
```bash
node demo.js list '*.js'
node demo.js list '*.js' -l
node demo.js list '*' -la --sort size
```

### 6. config 子命令
```bash
node demo.js config get port
node demo.js config set port 8080
```

## 核心概念验证

验证 `option()` 到 `options` 的映射关系：

| 定义代码 | 命令行输入 | options 对象 | 输出值 |
|----------|-----------|--------------|--------|
| `.option('-p, --port <number>', '', '3000')` | `--port 8080` | `options.port` | `"8080"` |
| `.option('-v, --verbose')` | `-v` | `options.verbose` | `true` |
| `.option('-f, --force')` | `--force` | `options.force` | `true` |

## 项目结构

```
commander-demo/
├── package.json    # 项目配置，依赖 commander
├── demo.js         # 主程序代码
└── README.md       # 本文件
```

## 关键代码解析

### 选项定义
```javascript
program
  .option('-p, --port <number>', '端口号', '3000')  // → options.port
  .option('-v, --verbose')                           // → options.verbose
  .option('-f, --force');                            // → options.force
```

### 获取选项值
```javascript
.action((options) => {
  console.log(options.port);     // 访问选项值
  console.log(options.verbose);  // true 或 undefined
});
```

### 属性名映射规则
```
-p, --port <number>  →  --port  →  options.port
-v, --verbose        →  --verbose → options.verbose
```
