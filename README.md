# Stock Socratic - 股票认知评价 Skill

> 买股票就是买公司，买公司必须买自己懂的公司。

## 简介

Stock Socratic 是一个跨平台通用 Skill，通过苏格拉底式对话最大化采集用户对公司的认知，用户说结束后一次性全网交叉验证认知准确性，给出认知评分，产出认知评价报告。

**核心哲学**：不评价股票好不好，而是评价**你对这家公司懂不懂**。

## 适用平台

- WorkBuddy
- Trae
- Claude Code
- OpenCode
- OpenClaw

## 安装方法

### WorkBuddy

```bash
# 方法1：通过 Git 克隆
cd ~/.workbuddy/skills
git clone https://github.com/{your-username}/stock-socratic.git

# 方法2：手动复制
# 将本目录复制到 ~/.workbuddy/skills/stock-socratic/
```

### Claude Code

```bash
cd .claude/skills
git clone https://github.com/{your-username}/stock-socratic.git
```

### 其他平台

将本目录复制到对应平台的 skills 目录即可。

## 使用方法

### 触发 Skill

在对话中说出以下任意一种表达：

- "分析一下贵州茅台"
- "帮我看看腾讯控股"
- "评价一下我对宁德时代的理解"
- "用三问法分析比亚迪"
- "苏格拉底式分析一下中芯国际"

### 对话流程

1. **采集期**：AI 通过三问法深挖你的认知
   - 你为什么觉得这个公司好？
   - 你为什么觉得这个公司便宜？
   - 你为什么觉得这个公司现在买？

2. **结束信号**：当你觉得说完了，告诉 AI "结束"或"出报告"

3. **验证期**：AI 自动调用金融数据工具批量验证你的认知

4. **报告期**：AI 生成认知评价报告（Markdown 文件）

### 报告内容

- 认知深度雷达图（四维度评分）
- 三问认知采集记录
- 数据验证对照表
- 认知盲区清单
- 按认知定级的投资建议

## 文件结构

```
stock-socratic/
├── SKILL.md                    # 核心指令文件
├── README.md                   # 本文件
├── CHANGELOG.md                # 版本记录
├── update.ps1 / update.sh      # 一键更新脚本
├── references/
│   ├── three-questions-guide.md    # 三问法深度指南
│   ├── data-validation-guide.md    # 数据验证操作手册
│   └── report-template.md          # 报告模板
└── examples/
    ├── example-bull-case.md        # 看多案例
    └── example-skeptic-case.md     # 存疑案例
```

## 更新方法

### 方法1：一键脚本

```bash
# Windows
./update.ps1

# Mac/Linux
./update.sh
```

### 方法2：Git 拉取

```bash
cd ~/.workbuddy/skills/stock-socratic  # 或对应平台目录
git pull origin main
```

### 方法3：检查更新

在对话中对 AI 说："检查更新"

## 依赖说明

本 Skill 依赖以下数据工具（可选，但强烈建议安装）：

- **neodata-financial-search**：自然语言金融数据搜索（优先）
- **tushare-finance**：结构化金融数据查询（补充）

如果当前环境没有这些数据工具，Skill 会降级为使用 web_search 或纯逻辑推演。

## 版本记录

参见 [CHANGELOG.md](./CHANGELOG.md)

## 免责声明

本 Skill 仅用于辅助投资分析，不构成任何投资建议。所有输出内容仅供参考，投资者应独立判断并承担投资风险。

## 许可证

MIT License
