# Codex Skills 工具箱

把 7 个常用 Codex 技能整理成可复现的安装清单：5 个本机已有，2 个随仓库附带，一条命令补齐。

> 适用环境：Windows + Codex（Desktop / CLI）。技能目录：`%USERPROFILE%\.codex\skills`，部分社区技能在 `%USERPROFILE%\.agents\skills`。

## 技能清单

| 技能 | 作用 | 本机状态 | 来源 | 许可证 |
|---|---|---|---|---|
| Superpowers | 需求梳理、计划、实现、调试、评审的完整流程（15 个子技能） | 已安装 | [obra/superpowers](https://github.com/obra/superpowers) | MIT |
| PDF | 读取、创建、检查、渲染 PDF，含扫描件处理 | 内置 | Codex 内置 `pdf:pdf` | 随 Codex 提供，不镜像 |
| humanizer-zh | 去掉中文里的“此外 / 综上所述”等 AI 腔 | 已安装 | [op7418/Humanizer-zh](https://github.com/op7418/Humanizer-zh) | MIT |
| planning-with-files | 用 `task_plan.md` / `findings.md` / `progress.md` 把计划落到磁盘，跨会话恢复 | 已安装 | [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) | MIT |
| frontend-design | 前端设计规范，避免“后端味”界面 | 内置 | Anthropic 技能包 | Apache-2.0 |
| code-review | 以 Standards / Spec 两轴并行审查改动 | 已安装 | 本地社区技能（未标注上游） | 未标注，不镜像 |
| skill-creator | 把重复工作流封装成新技能 | 内置 | Codex 内置 `.system` | 随 Codex 提供，不镜像 |

## 一键安装

```powershell
git clone https://github.com/sanhengswang/codex-skills.git
cd codex-skills
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

只补缺失项，不覆盖已有技能；需要覆盖时加 `-Force`。

想把 Superpowers 也从上游补齐：

```powershell
.\install.ps1 -WithSuperpowers
```

## 目录结构

```text
codex-skills/
├─ install.ps1              # 一键安装 / 体检
├─ skills.manifest.json     # 7 个技能的来源、许可证、安装方式
├─ skills/
│  ├─ humanizer-zh/         # MIT，完整技能
│  └─ planning-with-files/  # MIT，技能主体（不含 Codex hooks）
├─ custom/
│  └─ wangtao-workflow/     # 原创：把本机协作约定封装成技能
└─ docs/SOURCES.md          # 版本钉住、许可证与再分发说明
```

## 为什么只镜像两个技能

- `humanizer-zh`、`planning-with-files` 是 MIT，允许再分发，仓库内保留原始 `LICENSE`。
- Superpowers 是 MIT，但包含 15 个子技能且更新较快，安装脚本按上游最新版拉取，避免仓库变成过期镜像。
- `pdf`、`skill-creator` 随 Codex 提供；`frontend-design` 为 Apache-2.0 内置技能；`code-review` 未标注许可证。这四类不复制源码，只做检测和来源说明。

## 使用提示

- `planning-with-files` 的“每轮自动注入”依赖 hooks；本仓库只安装技能主体，hooks 需要在 Codex 插件 / 配置层自行启用。
- 第三方技能本质上是给代理的指令，运行前先读 `SKILL.md`；不要把密钥写进计划文件。
- 默认安装位置为 `%USERPROFILE%\.codex\skills`；`code-review` 若只在 `%USERPROFILE%\.agents\skills`，脚本只做检测，不迁移。
- 本机验证日期：2026-10-29；Codex Desktop 26.1007.2314.0 / CLI 0.161.0，Node v24.22.1。

## 许可证

本仓库原创部分（`install.ps1`、`README.md`、`custom/`）采用 MIT。`skills/` 下内容归各自上游所有，以对应 `LICENSE` 为准。
