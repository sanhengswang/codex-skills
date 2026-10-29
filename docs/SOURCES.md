# 来源与再分发说明

核对日期：2026-10-29。

| 技能 | 上游 | 版本 / Commit | 许可证 | 是否镜像 | 说明 |
|---|---|---|---|---|---|
| Superpowers | https://github.com/obra/superpowers | `main`（安装时取最新） | MIT | 否 | 15 个子技能；`install.ps1 -WithSuperpowers` 从上游克隆 |
| PDF | Codex 内置 `pdf:pdf` | 随客户端 | 随 Codex 提供 | 否 | 不复制客户端内置资源 |
| humanizer-zh | https://github.com/op7418/Humanizer-zh | `f4518a8`（2026-09-23） | MIT | 是 | 完整技能，保留原始 `LICENSE` |
| planning-with-files | https://github.com/OthmanAdi/planning-with-files | `5d29800`（2026-10-28） | MIT | 部分 | 只镜像 `.codex/skills/planning-with-files` 技能主体，不含 hooks |
| frontend-design | Anthropic 技能包 | 本地副本 | Apache-2.0 | 否 | 本机已内置，保留原 `LICENSE.txt` |
| code-review | 未标注上游 | 本地副本 | 未标注 | 否 | 来源与许可证不清，不复制源码 |
| skill-creator | Codex 内置 `.system` | 随客户端 | 随 Codex 提供 | 否 | 不复制客户端内置资源 |

## 再分发原则

1. 只镜像明确允许再分发的 MIT 技能，并保留原始版权与许可证文本。
2. 随 Codex 提供的内置技能、许可证不明或未标注上游的技能，只登记来源，不复制源码。
3. 上游更新后，`skills/` 中的副本可能滞后；以 `skills.manifest.json` 的 commit 为准，或用 `install.ps1 -WithSuperpowers` 直接取上游。
4. 技能是给代理的指令，不是可信代码审计的替代品；使用前阅读 `SKILL.md`。

## 本机验证

- 7 个技能均可被 Codex 识别：Superpowers、PDF、humanizer-zh、planning-with-files、frontend-design、code-review、skill-creator。
- `humanizer-zh`、`planning-with-files` 安装于 `%USERPROFILE%\.codex\skills`。
- `planning-with-files` 的自动注入 hooks 未启用；仅技能主体可用。
