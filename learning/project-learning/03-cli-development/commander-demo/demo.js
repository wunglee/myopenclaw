#!/usr/bin/env node

/**
 * Commander.js 完整示例
 * 
 * 演示内容：
 * 1. 全局选项定义和获取
 * 2. 子命令定义
 * 3. 子命令选项
 * 4. 参数处理
 * 5. action 回调执行
 */

const { Command } = require('commander');

// ========== 创建程序实例 ==========
const program = new Command();

// ========== 全局配置 ==========
program
  .name('myapp')
  .description('Commander.js 学习示例程序')
  .version('1.0.0');

// ========== 全局选项（对所有子命令有效）==========
program
  .option('-v, --verbose', '显示详细日志')
  .option('-c, --config <path>', '配置文件路径', './config.json');

// ========== 子命令: start ==========
program
  .command('start')
  .description('启动服务')
  .option('-p, --port <number>', '服务端口号', '3000')
  .option('--host <string>', '绑定主机', 'localhost')
  .option('-f, --force', '强制启动（跳过检查）')
  .action(function() {
    // 在子命令中，通过 this.opts() 获取当前命令选项
    // 通过 program.opts() 获取全局选项
    const cmdOptions = this.opts();
    const globalOptions = program.opts();
    
    console.log('\n🚀 执行 start 命令');
    console.log('─────────────────────────');
    console.log('全局选项:');
    console.log(`  verbose: ${globalOptions.verbose || false}`);
    console.log(`  config:  ${globalOptions.config}`);
    console.log('命令选项:');
    console.log(`  port:    ${cmdOptions.port}`);
    console.log(`  host:    ${cmdOptions.host}`);
    console.log(`  force:   ${cmdOptions.force || false}`);
    console.log('─────────────────────────');
    console.log(`服务即将启动: http://${cmdOptions.host}:${cmdOptions.port}\n`);
  });

// ========== 子命令: stop ==========
program
  .command('stop')
  .description('停止服务')
  .option('-f, --force', '强制停止')
  .option('-t, --timeout <seconds>', '超时时间（秒）', '30')
  .action(function() {
    const cmdOptions = this.opts();
    const globalOptions = program.opts();
    
    console.log('\n🛑 执行 stop 命令');
    console.log('─────────────────────────');
    console.log('全局选项:');
    console.log(`  verbose: ${globalOptions.verbose || false}`);
    console.log('命令选项:');
    console.log(`  force:   ${cmdOptions.force || false}`);
    console.log(`  timeout: ${cmdOptions.timeout}秒`);
    console.log('─────────────────────────\n');
  });

// ========== 子命令: list ==========
program
  .command('list <pattern>')
  .description('列出匹配的文件')
  .option('-l, --long', '显示详细信息')
  .option('-a, --all', '包含隐藏文件')
  .option('--sort <type>', '排序方式(name|size|time)', 'name')
  .action(function(pattern) {
    const cmdOptions = this.opts();
    const globalOptions = program.opts();
    
    console.log('\n📋 执行 list 命令');
    console.log('─────────────────────────');
    console.log('全局选项:');
    console.log(`  verbose: ${globalOptions.verbose || false}`);
    console.log('参数:');
    console.log(`  pattern: ${pattern}`);
    console.log('命令选项:');
    console.log(`  long:    ${cmdOptions.long || false}`);
    console.log(`  all:     ${cmdOptions.all || false}`);
    console.log(`  sort:    ${cmdOptions.sort}`);
    console.log('─────────────────────────\n');
  });

// ========== 子命令: config ==========
program
  .command('config')
  .description('配置管理')
  .addCommand(
    new Command('get')
      .description('获取配置项')
      .argument('<key>', '配置键名')
      .action((key) => {
        console.log(`\n获取配置: ${key} = 示例值\n`);
      })
  )
  .addCommand(
    new Command('set')
      .description('设置配置项')
      .argument('<key>', '配置键名')
      .argument('<value>', '配置值')
      .action((key, value) => {
        console.log(`\n设置配置: ${key} = ${value}\n`);
      })
  );

// ========== 解析命令行参数 ==========
program.parse();

// 如果没有提供任何参数，显示帮助信息
if (process.argv.slice(2).length === 0) {
  console.log('\n⚠️  未提供命令，显示帮助信息:\n');
  program.outputHelp();
}
