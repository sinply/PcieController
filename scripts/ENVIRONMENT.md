# WSL 开发环境配置指南

## 环境问题分析

### 问题现象

在 WSL (Windows Subsystem for Linux) 中直接运行 `sbt` 命令时出现以下错误：

```
Error: Unable to access jarfile /mnt/c/Program Files (x86)/sbt/bin/sbt-launch.jar
copying runtime jar...
mkdir: cannot create directory '': No such file or directory
```

### 问题原因

1. **路径格式不兼容**：Windows 安装的 sbt 是一个 bash 脚本，其内部路径处理逻辑在 WSL 和 Windows 之间转换时出现问题
2. **jar 文件路径硬编码**：sbt-launch.jar 的路径在脚本中以 Windows 格式硬编码，WSL 无法正确解析
3. **环境变量冲突**：Windows 和 WSL 的环境变量混合导致脚本执行异常

### 当前解决方案

通过 `cmd.exe /c "sbt"` 调用 Windows 版本的 sbt 可以正常工作，因为这样是在原生 Windows 环境中执行。

## 统一脚本 (sbtw.sh)

项目提供统一的 `sbtw.sh` 脚本，整合所有常用操作。

> 注：以下命令需从项目根目录执行，脚本位于 `scripts/` 目录。

```bash
# 查看帮助
./scripts/sbtw.sh --help

# 生成 Verilog
./scripts/sbtw.sh gen

# 运行测试
./scripts/sbtw.sh test

# 清理构建
./scripts/sbtw.sh clean

# 运行任意 sbt 命令
./scripts/sbtw.sh run "compile"

# 检查环境状态
./scripts/sbtw.sh check

# 配置环境
./scripts/sbtw.sh setup --coursier  # 安装 Coursier（推荐）
./scripts/sbtw.sh setup --alias     # 设置别名
```

## 配置方案

### 方案一：使用项目脚本（推荐，开箱即用）

直接使用 `sbtw.sh`，无需额外配置：

```bash
./scripts/sbtw.sh gen    # 生成 Verilog
./scripts/sbtw.sh test   # 运行测试
```

### 方案二：安装 Coursier（原生 Linux 方案）

Coursier 是 Scala 生态的依赖管理工具，可以在 WSL 中安装原生版本的 sbt：

```bash
./scripts/sbtw.sh setup --coursier
source ~/.bashrc

# 之后可以直接使用
sbt "runMain UartCtrl"
```

### 方案三：设置 Bash 别名

```bash
./scripts/sbtw.sh setup --alias
source ~/.bashrc

# 之后可以直接使用
sbt "runMain UartCtrl"
```

### 方案四：使用 IntelliJ IDEA

如果使用 IntelliJ IDEA 开发，可以直接在 IDE 中运行 sbt 任务，无需配置命令行环境。

## 验证环境

运行以下命令验证环境是否配置正确：

```bash
# 检查环境
./scripts/sbtw.sh check

# 生成 Verilog
./scripts/sbtw.sh gen

# 运行测试
./scripts/sbtw.sh test
```

## 常见问题

### Q: 为什么不直接在 WSL 中安装 sbt？

A: 可以，但需要通过 Coursier 安装。Windows 安装版 sbt 在 WSL 中存在路径问题。

### Q: Mill 能用吗？

A: Mill 未安装，如需使用需要先安装：

```bash
curl -L https://github.com/com-lihaoyi/mill/releases/download/0.11.0/0.11.0 > ~/bin/mill && chmod +x ~/bin/mill
```

### Q: 项目路径有要求吗？

A: 项目位于 `/mnt/d/Exercise/Spinalhdl/UartController`，对应的 Windows 路径是 `D:\Exercise\Spinalhdl\UartController`。使用 sbtw.sh 时无需关心路径转换。
