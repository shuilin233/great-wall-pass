# 长城关隘 Great Wall Pass

> 为《席德·梅尔的文明 VI》中国文明新增一个独特防御区域：**可以成群连片建造的带血量城墙**。
>
> 版本：**1.10** ｜ 兼容：基础游戏及全部资料片（迭起兴衰 / 风云变幻 / 新纪元季票）｜ 纯加法 Mod，随时可关
>
> 更新日志见 [CHANGELOG.md](CHANGELOG.md)

---

## 一、这个 Mod 加了什么

新增中国专属区域「**长城关隘**」，规格如下：

| 属性 | 数值 | 说明 |
|---|---|---|
| 前置科技 | 砌石 | 与长城改良设施同期解锁 |
| 造价 | 40 生产力 | 随游戏进程逐步上涨，防止后期无限刷墙 |
| 人口名额 | **不占用** | 不挤占专业区域名额 |
| 每城数量 | **不限** | 可以沿边境连片布防 |
| 生命值 | **100** | 与军营相同，必须先打掉血才能掠夺 |
| 控制区 (ZOC) | **有** | 相邻敌军单位移动被拦截，可封锁隘口 |
| 产出 | 邻近长城/关隘 +金/文化 | 每相邻 1 段长城 **+2 金**（砌石后）、**+2 文化**（城堡后）；每相邻 1 座关隘 **+1 金** / **+1 文化**（同门控）。数值在本 mod 内自定义（无法继承原版/其他 Mod 的长城数值，见「已知限制」） |
| 掠夺收益 | 无 | 敌人拆墙无利可图 |
| 魅力 | -1 | 与军营一致 |
| 维护费 | 0 | |

**不改动的内容**：军营、市中心、城墙、原长城改良设施（工人建造的连墙玩法保留）、其他所有文明——本 Mod 对原版数据**只增不改**，理论上与任何其他 Mod 不冲突。

## 二、玩法定位：中国的四重防线

1. **长城改良**（原版保留）：工人连墙，堆文化 / 旅游业绩 / 防御加成
2. **长城关隘**（本 Mod）：不占名额的带血肉墙，ZOC 卡位、迟滞大军
3. **军营**（原版）：驻军反击、军事建筑
4. **市中心城墙**（原版）：最后堡垒

## 三、安装与启用

1. 确认 Mod 位于：`文档\My Games\Sid Meier's Civilization VI\Mods\GreatWallPass\`
2. 启动游戏 → 主菜单 **附加内容 (Additional Content)** → 启用「长城关隘 Great Wall Pass」
3. **开新档**选中国（旧存档中途启用可能不出现该区域）
4. 研究「砌石」后，城市生产列表即可看到「长城关隘」

## 四、文件结构

```
GreatWallPass/
├── GreatWallPass.modinfo            Mod 清单：ID、版本、加载动作（前端+游戏内双分区注册）
├── GreatWallPass.dep                美术资源依赖清单（供 UpdateArt 加载）
├── ArtDefs/
│   ├── Districts.artdef             区域外观定义：复制官方军营条目并改名，引擎按名自动合并
│   ├── Landmarks.artdef             区域地标：关隘用「长城关门」造型（v1.10 起）
│   └── Improvements.artdef          联动墙体：IMPROVEMENT_GWP_LINK 的美术定义，
│                                    Xref 到原版 Walls.artdef 的 GreatWallSet
├── Data/
│   └── GreatWallPass_Gameplay.xml   核心数据：区域、特性、绑定中国、邻近收益、联动墙体
├── Lua/
│   ├── GreatWallPass_Wall.lua       ★ 联动墙体：扫地图地块，给完工的关隘格补上墙体
│   └── GreatWallPass_Diag.lua        诊断脚本（默认未挂载，排查时才启用）
├── Platforms/Windows/BLPs/
│   └── GWP_Gate.blp                 自制美术资源（长城关门）
├── Icons/
│   ├── GreatWallPass_Icons.xml      图标定义（指向原版「长城」改良图标）
│   └── GreatWallPass{22..256}.dds   自制贴图（保留未注册；本机整合版读不了散装 dds）
├── Text/
│   └── GreatWallPass_Text.xml       简体中文 + 英文文本
├── Mod.Art.xml                      美术资源清单
├── CHANGELOG.md                     更新日志
└── README.md                        本说明
```

## 五、技术实现说明（给想改数值的你）

- **数值调整**：全部在 `Data\GreatWallPass_Gameplay.xml` 的 `<Districts>` 一行里。造价改 `Cost`，血量改 `HitPoints`，关掉 ZOC 改 `ZOC="false"`，每城限一个改 `OnePerCity="true"`。改完重进游戏生效。
- **行为模板来源**：血量 + ZOC 参照官方 `DISTRICT_ENCAMPMENT`（军营）；可多个 + 不吃人口名额参照 `DISTRICT_NEIGHBORHOOD`（社区）；"数据驱动的防御型独特区域"可行性由高卢 `DISTRICT_OPPIDUM`（奥皮杜姆）验证——它证明了血量/控制区不是军营写死专属。
- **外观复用原理**：资料片新增区域靠同名 `Districts.artdef` 合并机制（`m_ReplaceMergedCollectionElements=false`），本 Mod 完全照此办理：条目从军营深拷贝改名，Landmark / StrategicView / Audio 引用原样保留，因此模型、战略视图图标、音效都继承军营。
- **外观 v2.1（要塞模型，实测通过）**：新增 `ArtDefs\Landmarks.artdef`，在 `Districts` 根集合加 `DISTRICT_GREAT_WALL_PASS` 条目（结构照抄官方军营条目：`BaseVariants` + `BuildingSets`），`BaseVariants` 按时代指向原版要塞资产 `IMP_Fort_Medieval/Industrial/Modern_Base`（`landmarks/tilebases.blp`，TileBase 类，零 cook、零 DLC 依赖）；`Districts.artdef` 的 Landmark Xref 由 `DISTRICT_ENCAMPMENT` 改指本条目。关隘从此不再是帐篷军营造型，且随时代演进。**v2.2 起锁定最早时代**：`BaseVariants` 只留 `DEFAULT → IMP_Fort_Medieval_Base` 一档，全时代不变（用户要求）。
- **关隘互邻加成（v2.1）**：`Adjacency_YieldChanges` 增加 `GWP_Adj_Pass_Gold` / `GWP_Adj_Pass_Culture` 两行（`AdjacentDistrict="DISTRICT_GREAT_WALL_PASS"`，官方港口 `Harbor_Gold` 先例），+1 金 / +1 文化，门控同长城行（砌石 / 城堡）。改数值改这两行的 `YieldChange`。
- **动态墙链（v2.1 尝试后撤除）**：曾试让关隘走引擎 DynamicGeo 动态墙系统（`Walls.artdef` 的 WallSet 靠 `Gameplay Name` 字段绑实体，官方区域先例＝引水渠 `DISTRICT_AQUEDUCT` / 浴场 `DISTRICT_BATHS`；改良则走 `Improvements.artdef` 的 `GreatWall` 子集合 Xref）。四轮实测：①自有 WallSet 能让关隘成链，但生成器有三类缺陷——不相邻关隘被**隔空拉墙连线**、引擎按引水渠式锚定**把墙从市中心拉到关隘**、非边境或同城多关隘时**概率缺件**；②覆盖官方墙集字段❌（合并非替换语义）；③给官方长城追加第二个 Xref❌（墙集被独占，关隘反丢墙）；④同名追加 `Gameplay Name`❌（无效）。长城改良不出这些问题全因 `BuildInLine` 放置规则保证永远相邻，区域无此保证。**结论：区域走动态墙无干净解，整套撤除；"关隘与长城同链互连"为引擎限制。**
- **想改邻近收益**：v2.0 起在 `<Adjacency_YieldChanges>` 定义了 `GWP_Adj_Gold` / `GWP_Adj_Culture` 两行，由 `<District_Adjacencies>` 挂到关隘。改数值就改这两行的 `YieldChange`。**注意**：实测在本机整合版上，区域侧**引用**原版 `GreatWall_Gold` / `GreatWall_Culture` 行**不生效**（显示 0），必须自定义，因此无法自动跟随其他「长城加强」Mod 的数值。要换成别的条件（如相邻山脉）改 `AdjacentImprovement` 即可，规则同原版工业区 `Mine_Production`。提示文案由引擎按邻近条件自动生成，不走 `Description` 字段。

## 六、已知限制

- 图标：v1.7 起改用原版「长城」改良图标（本机整合版读不了自制散装贴图）；模型 v2.1 起为原版要塞（三时代演进），不再是军营
- **改数据后必须彻底重启游戏（v2.0 排查教训）**：Civ6 只在**进程启动**时加载 mod 数据库，运行中读档 / 开新局都**不会**重载改过的 XML——排查邻近加成时曾因此产生"不生效"的假象。邻近加成**正常显示**在地块悬停框的区域产出区（如"75 文化值 / 75 金币"），无需额外 UI
- **邻近数值无法继承**：区域侧**引用**原版 `GreatWall_Gold` / `GreatWall_Culture` 行在本机整合版上不生效（实机显示 0），只能自定义行，故数值写死、不随其他长城 Mod 变动。若日后要跟随，需换实现（未验证）
- **AI 建造**：v1.9 已按官方规范接好 AI 倾向数据（`AiFavoredItems`/`AiLists` 绑定文明特性，机制同官方高卢奥皮杜姆）；实际行为未做实测（对局难验证，作者决定略过）
- 模型显示：v1.1 修复，**实测通过**（v2.1 起为要塞造型：中世纪石垒→工业→现代）
- **关隘之间、关隘与长城之间不会自动连墙（引擎限制，v2.1 定论）**：动态墙网络按 WallSet 划分且区域绑定走引水渠式锚定，实测评出隔空连线 / 市中心拉墙 / 概率缺件三类生成器缺陷，数据层无开关可修，故不做墙链。关隘为独立要塞造型，与长城相邻时视觉上各自收口
- **城墙环也只能挂在市中心（v2.2 实测）**：试过给关隘加「关墙」建筑（`BUILDING_GWP_WALL`）复用市中心城墙机制（WallSet 的 Gameplay Name 绑建筑类型），实机**造完不渲染墙环**——城墙环硬编码只认市中心那一格。至此"给关隘加墙"的两条数据路径（区域绑定 / 建筑绑定）均实测不可用，墙事结案，最终形态＝干净要塞
- 战斗行为实测：被攻击反伤 ✅、驻军回血 ✅；区域本体不主动炮击（与官方军营一致——射击由驻军远程单位执行）
- 选屏展示：v1.2 实测通过，中国全部 5 位领袖（天命者/大一统/忽必烈/武则天/永乐）均显示

## 七、版本历史

- **v1.0**（2026-10-03）：首版。区域数据、特性绑定、中英文本、图标、artdef 合并外观；自检修正 modinfo 双分区注册与造价递进模型。实机验证：血量 100/100 生效、可建造、ZOC 待确认。
- **v1.1**（2026-10-04）：修复两个实机问题——①模型不显示：dep 的 `SystemDependencies` 为空导致渲染子系统（Landmarks 等 6 个消费者）未加载我们的 artdef，已镜像官方消费者声明；②选中国界面无独特项目说明：新增 `Config\GreatWallPass_Config.xml`（PlayerItems 表，覆盖秦始皇/武则天/永乐 × 3 个玩家域），按官方规范挂入 FrontEndActions。实机验证：军营模型显示正常、反伤与驻军回血生效。
- **v1.2**（2026-10-04）：补「秦始皇（大一统）」人格领袖 `LEADER_QIN_ALT` 的选屏显示（v1.1 漏注册，导致该人格不显示独特项目）。至此中国全部 4 位领袖 ID（QIN / QIN_ALT / WU_ZETIAN / YONGLE）× 3 域共 12 行配置齐全。注意：选屏显示仅为信息面板；游戏内任何中国领袖本就可用该区域（特性绑定在文明层面）。
- **v1.3**（2026-10-04）：自定义图标上线。管线：GPT 生成徽章原图（1536×1024 三变体）→ alpha 阈值+圆形遮罩抠图 → LANCZOS 缩 22/32/38/50/80 五档 → 自研 BC3(DXT5) 编码器写 DDS（含规范 128 字节头，PIL 回读验证）→ 注册独立图集 `ICON_ATLAS_GREAT_WALL_PASS`（1×1 单格×5 尺寸）→ `IconDefinitions` 改指向新图集。dds 以散文件放 `Icons\` 并在 modinfo 登记。
- **v1.4**（2026-10-04）：补 `LEADER_KUBLAI_KHAN_CHINA`（忽必烈·中国）选屏显示。以权威 grep（`Base\Players.xml` + RulersOfChina + KublaiKhan_Vietnam）重生成全部 15 行 PlayerItems（5 领袖 × 3 域）。
- **v1.5**（2026-10-04）：换用用户提供的长城图标原图并抹除右下角水印；DDS 编码反复试错（BC3/DXT5 带 mip 链、非 2 次幂、无压缩 A8R8G8B8），实机仍不显示。
- **v1.6**（2026-10-04）：**图标真根因定位＝DDS 像素格式标志位写错**。自研写头脚本把像素格式 `dwFlags` 标成 `0x42`（DDPF_RGB | **DDPF_ALPHA**），而 `DDPF_ALPHA` 意为"仅 alpha 单通道贴图"，引擎据此把整张图当 alpha 处理 => 花屏/占位图标（v1.3 起每次失败皆因此，此前一直误判为格式/尺寸/路径问题）。正确值＝`0x41`（DDPF_RGB | DDPF_ALPHAPIXELS），以 PIL 自带 DDS 编码器校正。附带修正图集尺寸规则：**贴图边长必须＝IconSize**（原版 `Districts22.dds`＝176＝8×22 即证，"松散贴图必须 2 的幂"系误传）。最终改用 **PIL 自带 DDS 编码器** 出 7 张精确边长贴图（22/32/38/50/80/128/256），往返读回 0 误差。实机仍不显示——说明本机整合版根本不读 mod 散装贴图。
- **v1.7**（2026-10-04）：放弃自制散装贴图。本机为 CTP 整合版，mod 松散 `.dds` 反复实测均无法被引擎读取（v1.3~v1.6 已排除格式/尺寸/路径/像素标志多个变量）。图标改为指向**原版「长城」改良设施图标**（`ICON_ATLAS_UNIT_ACTIONS` 索引 18，打包贴图，必定显示）——造型即长城城墙，主题契合。自制贴图文件（`Icons\GreatWallPass*.dds`）保留在目录中但不再注册。
- **v1.8**（2026-10-04）：补**百科（Civilopedia）词条**。机制：Civilopedia 的 DISTRICTS 分区由 `CivilopediaPageQueries` 里的 SQL 自动为每个 `Districts` 行（`WHERE InternalOnly = 0`）生成一页，页布局固定为 `District`（仅含 HISTORY 章节），**无需新增任何数据库行**，只缺正文文本。本 mod 区域行已含 `InternalOnly="false"`，故仅需补 `LOC_PEDIA_DISTRICTS_PAGE_DISTRICT_GREAT_WALL_PASS_CHAPTER_HISTORY_PARA_1`（中英各一段关隘历史）。待实测。
- **v1.9**（2026-10-04）：补 **AI 建造数据**。机制：Civ6 的 AI 区域偏好由 `AiFavoredItems`（偏好清单项）+ `AiLists`（把清单绑定到 LeaderType **或文明特性**、`System="Districts"`）驱动。仿官方高卢奥皮杜姆（`GaulFavoredTechs` 绑 `TRAIT_CIVILIZATION_DISTRICT_OPPIDUM`）与城邦（`MINOR_CIV_*_TRAIT`）做法，新增 `GreatWallPassFavoredDistricts` 清单、绑定到本 mod 文明特性 `TRAIT_CIVILIZATION_DISTRICT_GREAT_WALL_PASS`（覆盖中国全部领袖），并把 `DISTRICT_GREAT_WALL_PASS` 标为 `Favored="true"`。区域无产出，AI 是否买账及建造频率需对局观察。
- **v2.0**（2026-10-10）：加**邻近收益**：每相邻 1 段长城 **+2 金**（砌石后）/ **+2 文化**（城堡后）。机制：区域吃改良邻近是原生支持（工业区即 `AdjacentImprovement="IMPROVEMENT_MINE"` 范例），在 `District_Adjacencies` 挂 `YieldChangeId` → `Adjacency_YieldChanges` 即可。**实现踩坑（重要）**：最初尝试**引用**原版长城改良的 `GreatWall_Gold` / `GreatWall_Culture` 两行以实现"与长城同值/自动跟随"，实机**始终显示 0**；改用本文件内**自定义**的 `GWP_Adj_Gold` / `GWP_Adj_Culture`（同条件同数值）后才正常。故**代价是数值固定、无法继承其他长城 Mod 的改动**。诊断过程与结论：① 增量排查确认自定义行 + `OnePerCity` 任意值都能生效，卡点确在"引用原版行"；② 邻近距离收益**会正常显示**在地块悬停框的区域产出区（诊断用夸张 +25 值时显示"75 文化值 / 75 金币"＝3 段相邻长城），无需额外 UI；③ 改 XML 后必须**彻底重启游戏进程**才重载，运行中读档 / 开新局都不会重载（否则会被旧数据误导）。中英区域描述同步更新（改为不写死数字）。
- **v2.1**（2026-10-11）：**关隘外观换原版要塞模型**（新增 `Landmarks.artdef` 条目，三时代要塞资产，实测通过）；**新增关隘互邻加成**（每相邻 1 座关隘 +1 金 / +1 文化，`AdjacentDistrict` 机制，实测通过）；**动态墙链实验收尾撤除**——四轮机制实测（自有墙集 / 覆盖字段 / 追加 Xref / 追加同名）证明区域走 DynamicGeo 有隔空连线、市中心锚定拉墙、概率缺件三类生成器缺陷且无数据层修法，"关隘与长城同链互连"确认为引擎限制。本版本无串墙 bug。
- **v2.2**（2026-10-11）：**关隘模型锁定最早时代**（`BaseVariants` 只留 `DEFAULT → IMP_Fort_Medieval_Base`，全时代石垒要塞不变，用户要求）；**墙事结案**：补测「关墙」建筑复用市中心城墙机制（WallSet 绑建筑类型），实机造完不渲染墙环——城墙环硬编码只认市中心；连同 v2.1 的区域墙链三缺陷，两条数据路径均不可用，撤除全部墙相关件。最终形态＝干净要塞 + 双重邻近加成。期间另测过 v2.3-rc1「关墙」改良（`BuildInLine` + 共享官方 `GreatWallSet`）：实机种子规则＝只能贴已有墙线起头，功能集为原版长城的真子集（更严且无邻近贡献），判定冗余撤除。**想把长城接到关隘旁：直接用原版长城改良修到关隘相邻格即可（原生功能）。**

## 八、致谢

数据结构与美术合并机制均逆向参照官方文件：`Base\Assets\Gameplay\Data\`（Districts / Improvements / Schema）、`DLC\Expansion1`（artdef 合并与 modinfo 规范）、`DLC\Byzantium_Gaul`（独特防御区域先例）。感谢 Firaxis 把数据库和 artdef 都以明文留给 Mod 社区。

## 九、进度快照（接续工作入口）

**截至 2026-10-11：v2.2 ＝ 当前版本**（v1.9 已实测通过并发布创意工坊，订阅 100+；v2.0–v2.2 待发布）。

- **已完成（代码层面）**：区域本体（100 血 / ZOC / 每城多建 / 不吃人口名额）、**邻近收益（v2.0：每相邻 1 段长城 +2 金 / +2 文化；v2.1：每相邻 1 座关隘 +1 金 / +1 文化）**、**要塞造型（v2.1 引入、v2.2 锁定最早时代：全时代石垒要塞）**、中英文本、选屏 5 领袖（v1.1–v1.4）、图标（原版「长城」图标，v1.7）、百科词条（v1.8）、AI 倾向数据（v1.9）。
- **未实测**：**AI 建造数据**已接但不做实测（对局难验证，作者决定略过）。
- **已定论不做**：关隘墙链 / 与长城同链互连 / 关隘城墙环 / 「关墙」改良（前者为引擎限制：区域绑定有隔空连线等三缺陷、城墙环硬编码市中心；关墙改良实测种子规则只能贴已有墙线、功能集为原版长城子集，冗余撤除；见「已知限制」与第五节动态墙条目；实验档案在 `D:\模型模块\墙实验_测试与回退.md`）。**把长城接到关隘旁＝用原版长城改良修到关隘相邻格（原生功能，今天就能用）**。
- **可选待办**：真·自定义关隘模型（FBX → AssetEditor/Civ6AssetCooker → 自带 `.blp`）——本机 SDK 齐备，但需要源 3D 模型，且整合版能否读取 mod 自带 `.blp` **未验证**（与散装 dds 同类风险）；若做，目标是"城门+墙茬"静态件，让长城贴建时视觉衔接，但不会自动拼接。
- **环境备注**：本机为 **CTP 整合版**（安装目录 0 个松散 `.dds`，贴图/模型全封在 `.blp`；无 `Logs` 目录）。所有踩过的坑（dep 消费者、前端/游戏内分区、PlayerItems、百科自动生成机制、AI 偏好清单、DDS 头结构/尺寸规则、区域邻近自动提示）已记录在上文各节，接续前先读第五、七节。

---

*Made with Claude Code · 2026-10*
