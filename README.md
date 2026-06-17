# Shadowrocket Rules

用于维护小火箭（Shadowrocket）的自定义分流/去广告规则。

## 文件说明

- `config/sr_ad_only.conf`: 从上游下载的原始广告规则。
- `config/custom.conf`: 基于上游规则复制出来的自定义规则（内联了几万条广告域名，体积大）。
- `config/shcode.conf`: 精简版配置（推荐）。手写 AI 精确分流 + blackmatrix7 远程规则集（广告/海外/国内），兜底走节点，体积小、随 App 自动更新。
- `data/sr_ad_only.db`: 从本机 Shadowrocket 沙盒复制出的规则数据库备份。
- `docs/`: 需求、设计和进度记录。

## 当前基线

上游规则地址：

```text
https://johnshall.github.io/Shadowrocket-ADBlock-Rules-Forever/sr_ad_only.conf
```

本机数据库来源：

```text
/Users/shcodegojo/Library/Containers/com.liguangming.Shadowrocket/Data/Documents/Databases/sr_ad_only.db
```

## custom.conf 结构

`config/custom.conf` 当前结构（按文件顺序）：

1. `[General]`：TUN 旁路路由参数（`bypass-system`、`skip-proxy`、`tun-excluded-routes`）。TUN 总开关仍由 Shadowrocket/VPN 控制，此处只配置 TUN 旁路与系统兼容路由。
2. `[Proxy Group]`：自定义策略组，每个平台 = 主策略组(`select`) + 自动测速子组(`<平台>-Auto`, `url-test`)。
3. `[Rule]`：先是 AI / Google / Apple 前置分流规则，后接上游广告 `Reject` 规则。

### 手动 / 自动 切换

每个平台都有两个组：

- `<平台>`（主组，`select`）：首页点开后，可选 `<平台>-Auto` 自动，或手动点某个具体节点。默认第一项为 Auto（Apple 默认 `DIRECT`）。
- `<平台>-Auto`（`url-test`）：在该平台专属地区内自动选延迟最低的节点（`interval=300`，`tolerance=50`），永远不会停在“剩余流量”等死节点上。

例如 OpenAI：首页 `OpenAI` 组里既能选 `OpenAI-Auto`（自动选最快美国节点），也能手动指定某个美国节点。

### 各平台专属地区

| 策略组 | 专属地区 | 说明 |
| --- | --- | --- |
| OpenAI | 🇺🇸 美国 US | ChatGPT 美国最稳 |
| Claude | 🇺🇸 美国 US | Anthropic 美国最稳 |
| GoogleAI | 🇺🇸 美国 US | AI Studio 美国优先 |
| Gemini | 🇯🇵 日本 JP | 日本可用且亚洲延迟低 |
| GoogleSearch | 🇭🇰🇹🇼🇯🇵🇸🇬 香港/台湾/日本/新加坡 | 就近择优、速度快 |
| Apple | 🇭🇰🇺🇸 + DIRECT | 默认直连，可切香港/美国 |

> 地区筛选用“旗帜 emoji / 中文名 / 带词界 `\b` 的英文代码”三种方式匹配节点名，可避免 `US` 误配 `Plus`/`Russia`，并自动排除“剩余流量/到期/官网”等信息节点。
> 若订阅缺少某地区节点，对应策略组会为空，需把该平台改成你实际拥有的地区。

## 重新导入 Shadowrocket

修改 `config/custom.conf` 后，按以下任一方式导入：

- 本地文件导入：把 `config/custom.conf` 传到手机（隔空投送 / iCloud Drive / 文件 App），在 Shadowrocket 里
  `配置 → 选择文件` 选中该文件导入。
- 链接导入：将文件放到可访问的 URL，在 Shadowrocket `配置 → 添加配置` 处填入链接后下载导入。

导入后在 App 内打开 TUN/VPN，验证 AI / Google / Apple 分流是否走对应策略组、广告是否被拦截。

> 注意：导入会覆盖同名配置。如需保险，可先在 App 内对当前配置做备份/导出，再导入新文件。

## shcode.conf（精简远程规则集版，推荐）

与 `custom.conf` 的区别：广告 / 海外 / 国内分流改用 blackmatrix7 远程规则集（jsdelivr CDN），不再内联几万行域名，文件从 5 万多行降到约 150 行，规则随 App「自动后台更新」刷新。

- AI 平台（OpenAI / Claude / GoogleAI / Gemini / GoogleSearch / Apple）仍用手写精确规则 + 原排除式正则策略组。
- 兜底 `FINAL → Final`：默认 `Auto`（自动选最快节点），也可手动切 `DIRECT` 或任一可用节点。
- 规则集：广告 `AdvertisingLite`(REJECT)、`Telegram` / `Global`(→Final)、`ChinaMax` + `GEOIP,CN`(→Domestic)、`Lan`(DIRECT)。

导入步骤同上；导入后建议在配置详情页开启「自动后台更新」，让远程规则集保持最新。

### 配套模块（「配置 → 模块 → +」粘贴链接导入）

> 去广告 / 解锁类模块需先开 HTTPS 解密并信任证书：配置文件右侧 `ⓘ → HTTPS 解密 → 生成 CA 证书 → 安装`，再到 iOS「设置 → 通用 → VPN 与设备管理」装描述文件、「关于本机 → 证书信任设置」开启完全信任。

下列链接均已验证可访问（2026-06）：

| 用途 | 链接 |
| --- | --- |
| App 去广告大合集（含微信 / 支付宝 / 开屏，约 538 款 App） | `https://raw.githubusercontent.com/fmz200/wool_scripts/main/Surge/module/blockAds.module` |
| App 去广告合集（备选，数百款应用 / 小程序 / 网站） | `https://raw.githubusercontent.com/zirawell/R-Store/main/Rule/Surge/Adblock/All/allAdBlock.sgmodule` |
| 支付宝去广告（单独） | `https://raw.githubusercontent.com/zirawell/R-Store/main/Rule/Surge/Adblock/All/alipayAdBlock.sgmodule` |
| YouTube 去广告 | `https://raw.githubusercontent.com/iab0x00/ProxyRules/main/Rewrite/YouTubeNoAd.sgmodule` |
| TikTok 免拔卡换区（日本；改区把 `TiKTok-JP` 换成 `TiKTok-TW/KR/US`） | `https://raw.githubusercontent.com/shom/TikTok-Unlock/master/Shadowrocket/TiKTok-JP.conf` |

- **微信广告**：单独的微信去广告模块多已失效；微信小程序 / 公众号 / 部分开屏广告已包含在上面的 `blockAds` / `allAdBlock` 合集里。朋友圈信息流广告微信加密强、校验严，未必能 100% 去除。
- **TikTok 换区**：除装模块外，节点也要切到目标国家的原生 IP，否则只改运营商代码仍可能被识别；换区后建议清缓存或重装 TikTok。
- **Sub-Store**：订阅管理 / 转换 / 合并多机场。自建或用公共实例，把聚合后的订阅链接添加到小火箭即可，与本 conf 解耦、互不影响。
- 去广告 / 换区模块仓库会偶尔变更链接，若某条失效可在 GitHub 搜对应仓库名找新地址。

