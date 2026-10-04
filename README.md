# 长城关隘 Great Wall Pass

> 为《席德·梅尔的文明 VI》中国文明新增一个独特防御区域：**可以成群连片建造的带血量城墙**。
>
> 版本：v1.0 ｜ 兼容：基础游戏及全部资料片（迭起兴衰 / 风云变幻 / 新纪元季票）｜ 纯加法 Mod，随时可关

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
| 产出 | 无 | 平衡代价：墙海换经济 |
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
│   └── Districts.artdef             外观定义：复制官方军营条目并改名，引擎按名自动合并
├── Data/
│   └── GreatWallPass_Gameplay.xml   核心数据：区域、特性、绑定中国
├── Icons/
│   ├── GreatWallPass_Icons.xml      图标定义（指向原版「长城」改良图标）
│   └── GreatWallPass{22..256}.dds   自制贴图（保留未注册；本机整合版读不了散装 dds）
├── Text/
│   └── GreatWallPass_Text.xml       简体中文 + 英文文本
└── README.md                        本说明
```

## 五、技术实现说明（给想改数值的你）

- **数值调整**：全部在 `Data\GreatWallPass_Gameplay.xml` 的 `<Districts>` 一行里。造价改 `Cost`，血量改 `HitPoints`，关掉 ZOC 改 `ZOC="false"`，每城限一个改 `OnePerCity="true"`。改完重进游戏生效。
- **行为模板来源**：血量 + ZOC 参照官方 `DISTRICT_ENCAMPMENT`（军营）；可多个 + 不吃人口名额参照 `DISTRICT_NEIGHBORHOOD`（社区）；"数据驱动的防御型独特区域"可行性由高卢 `DISTRICT_OPPIDUM`（奥皮杜姆）验证——它证明了血量/控制区不是军营写死专属。
- **外观复用原理**：资料片新增区域靠同名 `Districts.artdef` 合并机制（`m_ReplaceMergedCollectionElements=false`），本 Mod 完全照此办理：条目从军营深拷贝改名，Landmark / StrategicView / Audio 引用原样保留，因此模型、战略视图图标、音效都继承军营。
- **想加风味产出**（例如每相邻一段墙 +1 文化）：在 `<District_Adjacencies>` 表添加行并定义 `Adjacency_YieldChanges`，参照原版长城改良的写法。

## 六、已知限制

- 图标：v1.7 起改用原版「长城」改良图标（本机整合版读不了自制散装贴图），模型仍复用军营
- **AI 建造**：v1.9 已按官方规范接好 AI 倾向数据（`AiFavoredItems`/`AiLists` 绑定文明特性，机制同官方高卢奥皮杜姆）；实际行为未做实测（对局难验证，作者决定略过）
- 模型显示：v1.1 修复，**实测通过**（军营造型）
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

## 八、致谢

数据结构与美术合并机制均逆向参照官方文件：`Base\Assets\Gameplay\Data\`（Districts / Improvements / Schema）、`DLC\Expansion1`（artdef 合并与 modinfo 规范）、`DLC\Byzantium_Gaul`（独特防御区域先例）。感谢 Firaxis 把数据库和 artdef 都以明文留给 Mod 社区。

## 九、进度快照（接续工作入口）

**截至 2026-10-04：v1.9 ＝ 当前完整版。功能已齐，剩下的是可选增强。**

- **已完成（代码层面）**：区域本体（100 血 / ZOC / 每城多建 / 不吃人口名额 / 零产出）、军营造型、中英文本、选屏 5 领袖、图标（原版「长城」图标，v1.7）、百科词条（v1.8）、AI 倾向数据（v1.9）。
- **未实测**：图标 / 百科需进游戏看一眼确认（数据已按官方规范接好）；**AI 建造数据已接但不做实测**（对局难验证，作者决定略过）。
- **可选增强（未做）**：相邻墙 +1 文化；上创意工坊（需正版 Steam + Development Tools）。
- **环境备注**：本机为 **CTP 整合版**（安装目录 0 个松散 `.dds`，全部贴图封在 `.blp`；无 `Logs` 目录）。**自制散装 DDS 图标路径已判定走不通**：后续若确需自定义图标，只能走"把贴图打包进 `.blp`"或换成非整合版游戏。所有踩过的坑（dep 消费者、前端/游戏内分区、PlayerItems、百科自动生成机制、AI 偏好清单、DDS 头结构/尺寸规则）已记录在上文各节，接续前先读第五、七节。

---

*Made with Claude Code · 2026-10*
