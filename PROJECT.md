# 长城关隘 Great Wall Pass — 项目总档案

> 本文件是接续工作的唯一入口：文件位置、环境、当前进度、全部实验结论、回退点、待办，都在这里。
> 更新时间：**2026-10-13** ｜ 当前版本：**1.10** ｜ 当前 HEAD：见 `git log --oneline -1`

> **编号说明**：对外统一用 `主版本.次版本`。历史提交里的 `v1.x / v2.x` 是开发期内部编号，
> 对应关系：**旧 v1.9 = 1.00**，**本次 = 1.10**。详见 `CHANGELOG.md`。

---

## 一、位置速查

| 东西 | 路径 |
|---|---|
| **Mod 真身（工作目录，git 仓库）** | `E:\CivMods\GreatWallPass\` |
| 游戏读取入口（目录联接→真身） | `文档\My Games\Sid Meier's Civilization VI\Mods\GreatWallPass` |
| 游戏安装目录 | `E:\SteamLibrary\steamapps\common\Sid Meier's Civilization VI` |
| SDK（AssetModTools / ModUploader） | `...\Sid Meier's Civilization VI SDK\` |
| 物理备份（墙实验前） | `E:\CivMods\_backup\GreatWallPass_v2.0_pre-wall-experiment`（无 .git） |
| **完整实验档案（本轮全部排查过程）** | `E:\CivMods\_walllink_实验档案.md`（§1–42，含每轮根因与回退命令） |
| **游戏内测试用例** | `E:\CivMods\_GreatWallPass_测试用例.md` |
| **版本快照（1.01 – 1.18 + 1.19-check）** | `E:\CivMods\_snapshots\GreatWallPass_*\`（各带 `_SNAPSHOT_MANIFEST.txt` 与 `_RESTORE.ps1`） |
| 更新日志 | `CHANGELOG.md`（仓库内） |
| 工坊上传器 | `...\Civilization VI SDK\ModUploader\Firaxis.SteamWorkshop.exe`（需 Steam 在运行） |
| 工坊预览图 | `E:\CivMods\workshop_preview.jpg`（v1.9 用过，仍在） |
| GitHub 仓库 | `shuilin233/great-wall-pass`（repo-local proxy `http://127.0.0.1:7897`） |
| 创意工坊 | 物品 ID **3813320696**（在架 **v1.9 = 1.00**；1.10 尚未上传） |

## 二、环境要点（CTP 整合版）

- 安装根有 `2kLauncherRemoved.txt`、`CTP` 目录；贴图/模型**全封在 .blp**，0 个松散 .dds
- **日志在 `C:\Users\26792\AppData\Local\Firaxis Games\Sid Meier's Civilization VI\Logs\`**（不在文档目录下）。
  关键：`Lua.log`（游戏脚本日志，**每次启动会覆盖**）、`ArtDef.log`、`Modding.log`、`Database.log`。
  用户目录仍**没有 config.ini**——别硬造（怕覆盖打包版默认）。
- **Civ6 只在进程启动时加载 mod 数据库/artdef/Lua**：改完必须退到桌面重开，读档/开新局都不重载
- mod 散装 `.dds` **读不进** → 图标走原版打包贴图
- mod 自带 **`.blp` 能读**（弯刀战士 canary 实测✅）
- **DLC 的 blp 不一定挂载**：黑死病情景 DLC 已安装但其 `Districts.blp` 里的资产实机红柱

## 三、当前状态（1.10）

- 中国独特防御区域「长城关隘」：前置砌石 / 40 锤（递进）/ **100 血 / ZOC / 每城多建 / 不吃人口名额** / 魅力 -1 / 无掠夺收益
- 邻近收益（自定义行，实测通过）：
  - 每相邻 1 段长城：**+2 金**（砌石后）/ **+2 文化**（城堡后）
  - 每相邻 1 座关隘：**+1 金** / **+1 文化**（同门控，`AdjacentDistrict` 机制）
- 外观：**长城关门造型**（1.10 换掉原来的要塞模型）
- **关隘与长城视觉联动：已做成**（见第五节第 9 条）——关隘一格会生成一段长城墙体，
  动态长城把它当节点，墙真正穿过去
- 配套齐：中英文本、选屏 5 领袖、原版长城图标、百科词条、AI 倾向数据

**发布状态**：工坊在架 **v1.9 = 1.00**；**1.10 未上传工坊**。
用户明确指示：**发布搁置**（"不要惦记着发布了"）。

## 四、文件结构（每个文件干什么）

```
E:\CivMods\GreatWallPass\
├── GreatWallPass.modinfo     Mod 清单：id 7ae2e0ba-…、双分区动作、Files 清单
├── GreatWallPass.dep         美术依赖：6 个 SystemDependencies 消费者（Audio/Landmarks/Features/
│                             StrategicView_Sprite/WorldView_Translate/Resources，v1.1 教训：
│                             消费者为空→渲染子系统不加载我们的 artdef）；
│                             ArtDefDependencies：Districts / Landmarks / Improvements 三组
├── ArtDefs/
│   ├── Districts.artdef      区域条目 DISTRICT_GREAT_WALL_PASS（军营深拷贝改名），
│   │                         Landmark Xref → 我们自己的 Landmarks 条目
│   ├── Landmarks.artdef      地标条目：1.10 起指向原版**长城关门**资产
│   └── Improvements.artdef   ★ 联动墙体 IMPROVEMENT_GWP_LINK 的美术条目，
│                             Xref 到原版 Walls.artdef 的 GreatWallSet
├── Data/
│   └── GreatWallPass_Gameplay.xml   核心数据：Types/Districts/Adjacency_YieldChanges(4行)/
│                             District_Adjacencies(4行)/Traits/CivilizationTraits/
│                             Improvements(联动墙体)/AiLists/AiFavoredItems
├── Lua/
│   ├── GreatWallPass_Wall.lua   ★ 联动墙体逻辑（扫地图地块 → 给完工的关隘格补墙体）
│   └── GreatWallPass_Diag.lua   诊断脚本（**默认未挂载**，排查时才加回 modinfo）
├── Platforms/Windows/BLPs/   自制美术资源（GWP_Gate.blp + 两张 SHARED_DATA 贴图）
├── Mod.Art.xml               美术资源清单
├── Config/
│   └── GreatWallPass_Config.xml     选屏 PlayerItems：中国 5 领袖 ID × 3 玩家域 = 15 行
├── Icons/
│   ├── GreatWallPass_Icons.xml      IconDefinitions 1 行（指向原版长城图标）
│   └── GreatWallPass{22..256}.dds   自制贴图 7 张（保留未注册）
├── Text/
│   └── GreatWallPass_Text.xml       zh_Hans_CN + en_US：区域名/描述/特性名/联动墙体名/百科
├── CHANGELOG.md              更新日志（1.00 / 1.10）
├── README.md                 面向玩家的说明书
└── PROJECT.md                本文件
```

## 五、墙事：前 8 条路全死，**第 9 条做成了**

目标：让关隘和原版长城在视觉上连成一条线。

> ⚠️ **本节标题与结论在 2026-10-13 被推翻过一次。**
> 旧版本写的是"8 条路全死（数据层无解，已结案）"——那是**错的**，
> 错在把问题当成"模型/artdef 问题"。第 9 条换了思路就成了。

### 9. 往地块上放一个"视觉节点" ✅ 已实装（1.10）

**关键认知（之前 8 条路全卡在这里）**：

> 长城的墙**不是模型**，是 **DynamicGeometry** 按"地块上有长城改良"把所有满足条件的格子
> 连成 spline 画出来的。关隘是**区域**，永远进不了那个地块集合。
> **所以只改模型、只改 artdef 永远连不上 —— 必须往地块上"放一个东西"。**

**做法**：

1. 自建一个**纯视觉改良** `IMPROVEMENT_GWP_LINK`（显示名「关隘墙体」）：
   `Buildable=false / Removable=false / Capturable=false`、**不写任何 YieldChange**
   → 玩家既看不到它、也拆不掉它，关隘格也不会白吃长城改良的收益
2. 美术上它 Xref 到原版 `Walls.artdef` 的 `GreatWallSet` → 画出来就是长城本身
   （`ArtDefs/Improvements.artdef`）
3. `Lua/GreatWallPass_Wall.lua` 在**完工**的关隘格上把它写上去
   → 动态墙系统把关隘格当成长城节点 → **墙真正穿过去**

**触发时机**（下面这些事件都经心跳实测确认会响）：

| 时机 | 事件 |
|---|---|
| 关隘**完工那一刻** | `Events.CityProductionCompleted`（实测 25 次/局） |
| 每回合兜底 | `GameEvents.PlayerTurnStarted`（实测 40 次/局） |
| 关隘放下时 | `Events.DistrictAddedToMap` |
| 读档后自动补齐 | 上述各事件的首次触发 |

**枚举方式（这里踩了五轮的坑）**：必须**直接扫地图地块** ——
`Map.GetPlotCount()` + `Map.GetPlotByIndex(i)` + `Plot:GetOwner()` + `Plot:GetDistrictType()`。

- `Player:GetDistricts()` 实测**只返回城市中心那一类，不含关隘**（日志：`districts=5 pass=0`）
- `City:GetDistricts()` 在**游戏脚本环境**里连 `Members` 都取不到（报 `function expected instead of nil`）

**完工守门（必须留着）**：只在关隘**建完之后**才写墙体。
施工中的地块上不能同时有"区域 + 改良"，否则该格无法再被 `CanProduce` 选中，
表现就是"修到一半切走生产，再点关隘没法继续"。
代价：**施工途中墙先不连，完工后才连** —— 这个取舍是故意的。

### 已失败的 8 条路（别再试）

| # | 路径 | 结果 |
|---|---|---|
| 1 | 区域绑自有 WallSet（DynamicGeo） | 能成链但三类缺陷：隔空连线（4 格外关隘被拉墙）、市中心锚定拉墙、概率缺件 |
| 2 | 覆盖官方墙集字段 | ❌ artdef 合并=子集合追加，**同元素同名字段不替换** |
| 3 | 给官方长城条目追加第二个 GreatWall Xref | ❌ 墙集被独占，关隘反丢墙 |
| 4 | 同名元素 `AppendMergedParameterCollections=true` 追加 Gameplay Name | ❌ 无效 |
| 5 | 「关墙」建筑绑 WallSet（仿市中心城墙） | ❌ 造完不渲染——**城墙环硬编码只认市中心格** |
| 6 | 「关墙」改良（BuildInLine + 共享官方 GreatWallSet） | 能贴原版长城起头，但种子规则=只能贴已有墙线，是原版长城的**真子集** → 冗余撤除 |
| 7 | DLC 静态城墙圈 DIS_Wall_Base（黑死病情景资产） | ❌ 整合版装了 DLC 但实机**红柱错误占位** |
| 8 | 在基础游戏里找静态城墙件 | ❌ 不存在：344 个 TileBase 里 fort/wall/gate 语义只有 `IMP_Fort_*_Base` 三件 |

**第 1–8 条的共同错误**：都在"改模型 / 改 artdef / 换资产"这一层打转，
没有意识到**墙是按地块数据画出来的**。第 9 条正是绕开了这一层。

**替代玩法（原生就有，仍然有效）**：用原版长城改良修到关隘相邻格，也能视觉衔接。

## 六、自定义静态模型路线（仍然可选）

前置已验证：整合版**能读 mod 自带 .blp**（SDK Example Art Mod 弯刀 canary 实测✅）。管线：

```
FBX → AssetEditor(GUI, FbxImporter_Release.dll) → .ast/.geo/.fgx/.wig
    → Civ6AssetCooker_FinalRelease.exe(CLI) → mod Platforms/Windows/BLPs/*.blp
```

- **卡点：FBX→fgx 导入是 GUI-only**（.geo 不含顶点数据、指向 .fgx Granny 二进制；
  CIVBLP 容器带签名，逆向已放弃）→ 需用户跟步骤点 AssetEditor 一次（约半小时），cook+接线我来
- 注意：静态件**不会自动拼接**，只是造型上让长城贴建时视觉衔接
- **1.10 已经不是必须项**：视觉联动靠第 9 条已经做成了

## 七、版本历史与回退点链

| commit | 对外版本 | 内容 |
|---|---|---|
| **（1.10 提交）** | **1.10（当前）** | **长城关门造型 + 长城视觉联动 + 邻近收益 + 两处修复 + CHANGELOG** |
| `a691473` | **1.00（= 旧 v1.9）** | 工坊在架版本；区域本体 + 文本 + 百科 + AI 倾向 + artdef 合并外观 |
| `2a80d8b` 及以下 | 开发期内部 | 旧 v2.0–v2.3-rc2：邻近收益、8 条墙路的实验与撤回（**均未发布**） |

**回退点链**（都是完整快照，各带校验与还原脚本）：

```
E:\CivMods\_snapshots\
  GreatWallPass_1.17\        联动做成的那一版（根因修复）
  GreatWallPass_1.18\        收尾版：诊断全关 + 幽灵特性已删（当前对外形态）
  GreatWallPass_1.19_check\  测试用检查版（诊断全开）
  GreatWallPass_1.01 … 1.16   中间迭代
```

还原：`powershell -ExecutionPolicy Bypass -File "…\_snapshots\GreatWallPass_1.18\_RESTORE.ps1"`

## 八、待办清单

- [ ] **GitHub 推送**：本地领先 `origin/main` 若干提交未推（代理 `127.0.0.1:7897` 已配好）。
      可选：压成 `1.00 → 1.10` 两个提交再推，避免公开 v2.x 那串"墙事全死"的实验历史
- [ ] **工坊发布 1.10**：用户指示**搁置**；日后发布用 ModUploader 选 .modinfo + 预览图
- [ ] **修"幽灵墙"**：关隘被移除（城市被夷平等）后，格子上那段纯视觉墙体不会被清掉，
      墙上会残留一段。修法：扫描时若"格子有联动改良但已无对应关隘"就清掉
- [ ] **README 通读**：§五/§六 与末尾版本历史仍带旧编号（v2.x），与新编号不一致
- [ ] （可选）自定义静态模型：走第六节管线，需一次 GUI 协作
- [x] 墙事 8 条路实验档案齐
- [x] 弯刀 blp canary 测试 mod（`Mods\GWP_BlpLoadTest`）已删除

## 九、排查速查（踩过的坑一句话版）

1. 改了没生效 → **彻底重启游戏进程**（只在启动时加载）
2. 模型不显示 → 查 `.dep` 的 SystemDependencies 消费者是否声明（v1.1 教训）
3. 邻近加成 → 会显示在地块悬停框区域产出区；**引用原版行不生效，必须自定义行**
4. 图标 → 散装 dds 死路，指原版打包图集槽位
5. artdef 合并 → 同名文件自动合并；子集合追加、同名元素字段**不替换**
6. 诊断手法 → 临时改夸张值 / 绑显眼资产肉眼确认机制
7. 做平行改良前 → 先比种子规则与功能集，防做出原版子集
8. **`Members()` 的迭代器返回 `(索引, 对象)` 两个值** ——
   写成 `for x in coll:Members()` 拿到的是**数字**，下一行就报 `attempt to index a number value`。
   正确写法 `for i, x in coll:Members()`（游戏本体 `WorldRankings.lua:1219` 就这么写）
9. **`GameEvents` 会 auto-vivify**：取任何名字都给你一个带 `.Add` 的对象，
   所以"注册成功"**什么都证明不了**。挂在 `GameEvents` 上的事件，除了 `PlayerTurnStarted`，
   **永远不会被调用**。`Events` 才是真表（没有的键就是 nil）
10. **判断事件是否真的会响，唯一办法是看它回调有没有打出日志** ——
    `Events.LoadGameViewStateDone` / `CitySelectionChanged` 就是"注册得上但永不触发"的反例
11. **`Player:GetDistricts()` 不含普通区域**（只给城市中心那类）；
    `City:GetDistricts()` 在游戏脚本环境里没有 `Members`。要枚举区域就**扫地图地块**
12. **`pcall` 会吞错误** —— 诊断脚本里 `pcall(fn)` 一定要接错误并打出来，
    否则会像 v1.15 那次一样：整个日志一条输出都没有，白跑一轮游戏
13. **写扫描类逻辑，第一天就要打印"我扫到了几个目标"** ——
    一个 `pass=0` 的计数器能省掉四轮游戏（本项目的血泪教训）

---

*Made with Claude Code · 2026-10*
