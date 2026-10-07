
## 🎬 MPV Player · 硬核技术交流群
[![QQ Group](https://img.shields.io/badge/QQ①群-1097053691-12B7F5?logo=tencent-qq&logoColor=white)](https://qm.qq.com/q/KQZsl4wFmG)
[![Members](https://img.shields.io/badge/群成员-2000+-4CAF50)](https://qm.qq.com/q/KQZsl4wFmG)          [![QQ Group](https://img.shields.io/badge/QQ②群-1104144778-12B7F5?logo=tencent-qq&logoColor=white)](https://qm.qq.com/q/KDxk01ukwe)
[![Members](https://img.shields.io/badge/群成员-33+-4CAF50)](https://qm.qq.com/q/KDxk01ukwe)


## 🎬 yosh-mpv-config · 个人优化版 mpv 配置

> 本仓库在 [dyphire/mpv-config](https://github.com/dyphire/mpv-config) 最新版基础上，叠加了本人（yosh.wang）的一系列界面与功能优化，自用整合包。

> 部分功能参考了 [杳知 / Yaozhi](https://github.com/Yaozhil/mpv-Yaozhi) 项目，在此表示感谢。

---
# **🎯 mpv · 为画质而生，为技术而狂 · mpv 🎯**
---
- 💬 MPV 中文社区：[MPV-QQ-Discussion-Group](https://github.com/yosh-wang/MPV-QQ-Discussion-Group)
- 🧭 mpv 资源导航：[MPV-Resource-Index](https://github.com/yosh-wang/MPV-Resource-Index)
- 🐧 QQ ①群：[1097053691](https://qm.qq.com/q/KQZsl4wFmG) 【点击加入】
- 🐧 QQ ②群：[1104144778](https://qm.qq.com/q/KDxk01ukwe) 【点击加入】

### 🔗 相关仓库

| 项目 | 简介 | 仓库 |
|------|------|------|
| stats.lua 汉化版 🔥 | 播放统计信息界面汉化 | [yosh-wang/mpv-stats.lua-zh](https://github.com/yosh-wang/mpv-stats.lua-zh-chinese-translation-) |
| MPV-Settings 🔥🔥🔥 | MPV 播放器配置文件可视化设置工具 | [yosh-wang/MPV-Settings](https://github.com/yosh-wang/MPV-Settings) |
| uosc Video Tags 🔥 | 视频技术标签模块-左下角 | [yosh-wang/uosc-video-tags](https://github.com/yosh-wang/uosc-video-tags) |
| startup-format-logos 🔥 | 启动时显示视频/音频格式标识-右上角 | [yosh-wang/mpv-startup-format-logos](https://github.com/yosh-wang/mpv-startup-format-logos) |
| hdr-auto-toggle 🔥 | hdr 自动切换 | [mpv-hdr-auto-toggle](https://github.com/yosh-wang/mpv-hdr-auto-toggle) |
| MPV-Resource-Index 🔥 | mpv 资源大全 | [MPV-Resource-Index](https://github.com/yosh-wang/MPV-Resource-Index) |

---

## 📖 项目简介

| 项目 | 信息 |
|------|------|
| 上游仓库 | [dyphire/mpv-config](https://github.com/dyphire/mpv-config)（Windows 下 mpv 播放器配置模板） |
| 个人分支 | `yosh.wang`（承载全部个人优化，master 保持与上游同步） |
| 基线版本 | 2026.08.12 自用 `portable_config` → 已跟进 dyphire 最新版 |
| 适用平台 | Windows（mpv 便携版 `portable_config`） |
| 语言 | Lua / Conf（中文注释） |

**分支策略说明**
- `master`：仅用于跟进上游更新，保持与 `dyphire/mpv-config:master` 一致，不存放个人改动。
- `yosh.wang`：个人优化分支，装载全部脚本与个性化配置，日常使用此分支。

---

## 🔄 相对原版 / 基线的优化清单

> 以下均为 `yosh.wang` 分支相对上游**新增或改写**的部分；上游自身更新（如 uosc 升级、字体更换）已一并跟进，不在此重复列举。

| # | 优化模块 | 类型 | 说明 |
|---|---------|------|------|
| 1 | 右键上下文菜单| 新增 | 独立维护的鼠标中键/右键菜单，增加菜单项间隙等视觉微调 |
| 2 | 起播专业格式 Logo  | 新增 | 开播展示 Dolby Vision / HDR10+ / Atmos / DTS-X 等格式徽章 |
| 3 | 视频技术参数标签  | 新增 | 控制栏上方实时显示编码/分辨率/HDR/音频技术参数 |
| 4 | 统计信息面板（中文版） | 新增 | 汉化版 stats.lua + 调校配置 |
| 5 | HDR 自动切换  | 新增 | 按显示器 HDR/SDR 状态自动切换 |
| 6 | 文件浏览器鼠标导航 | 增强 | file-browser 增加鼠标滚轮/光标导航 |
| 7 | 打开文件重置倍速 | 新增 | 避免倍速残留 |
| 8 | uosc 界面与空闲页优化 | 调校 | 透明度、音量/倍速持久化、空闲页中央 Logo |
| 9 | 图标字体升级 | 升级 | MaterialIcons → modernz-icons / uosc_icons |
| 10 | 其余脚本配置微调 | 调校 | trackselect / recentmenu / dynamic_crop 等约 12 项 conf 微调 |

---

## ✨ 功能详解

### 1. 右键上下文菜单 `context_menu_yosh` 🖱️
从上游 `context_menu.conf` 独立拆分出的 `context_menu_yosh.lua` + `context_menu_yosh.conf`，由本人**独立维护**，与杳知菜单逻辑、ker 视觉样式**无关**。不污染原版配置，可随上游更新安全合并。

- 相对原版主要改动：**增加菜单项间隙**（`gap`）、子菜单水平缝隙（`submenu_gap`）等视觉微调，使菜单更透气
- 启用了**自适应缩放**：窗口化与全屏时按高度自动缩放（`menu_min_scale=1.5` / `menu_max_scale=3.5`），不再用「…」截断长菜单项
- 支持**子菜单展开延迟**控制（`seconds_to_open_submenus`）
- 关键参数（`context_menu_yosh.conf`）：

```ini
font_size=20                # 字体大小
gap=0.2                     # 菜单项间距
padding_x=8                 # 水平留空
padding_y=4                 # 垂直留空
corner_radius=5             # 圆角半径
scale_with_window=auto      # 随窗口高度同步缩放
menu_min_scale=1.5          # 窗口化缩放下限（不再过小）
menu_max_scale=3.5          # 全屏缩放上限（不再过大）
submenu_gap=6               # 子菜单与父菜单水平缝隙
focused_color=#222222       # 聚焦项文字色
focused_back_color=#FFFFFF  # 聚焦项背景色
```

> 绑定策略：默认绑定鼠标**中键**；右键默认仍走 uosc 菜单（作为对照基线），需改键时编辑 `input.conf` 与脚本绑定。

### 2. 起播专业格式 Logo `startup-format-logos` 🌈
开播时在画面角落展示当前媒体所符合的**专业格式徽章**，一眼识别 Dolby Vision / HDR Vivid / HDR10+ / Atmos / DTS-HD MA / DTS:X 等。

- 脚本 `scripts/startup-format-logos.lua`（约 1559 行，独立自维护）
- 素材 `script-assets/startup-format-logos/runtime/`（697 个 `.bgra` 位图 + `manifest.json`，由 `startup-logo-bounds.lua` 计算边界）
- 支持**彩色 / 白色**两种图标样式、四角定位、随横竖屏基准自动缩放
- 智能识别：从文件名/标题/路径补充识别，避免多音轨 Dolby/DTS 串标；蓝光盘编码黑边自动校正徽章位置
- 关键参数（`startup_format_logos.conf`）：

```ini
enabled=yes              # 总开关
style=color              # color=彩色徽章 / white=透明底白图标
show_video=yes           # 显示画面标准 Logo
show_audio=yes           # 显示音频标准 Logo
show_sdr=yes             # 普通 SDR 也显示彩色 SDR 徽章
position=top-right       # 显示位置：top-right / top-left / bottom-right / bottom-left
scale=1.0                # 整体缩放倍率
portrait_scale=1.18      # 竖屏额外倍率
hold=4.0                 # 完全点亮后停留秒数
fade_in=0.12             # 淡入时间
fade_out=0.18            # 淡出时间
video_priority=dolby-vision,hdr-vivid,hdr10-plus,hdr10,hlg,sdr
audio_priority=dolby-atmos,dts-x,audio-vivid,dolby-truehd,dts-hd-ma,...
```

### 3. 视频技术参数标签 `uosc MediaInfo` 🏷️
为 uosc 控制栏上方添加**视频/音频技术参数标签**（源自本人另一仓库 [uosc-video-tags](https://github.com/yosh-wang/uosc-video-tags)）。

- 元素 `scripts/uosc/elements/MediaInfo.lua`（约 914 行，单文件自包含）
- `scripts/uosc/main.lua` 末尾追加一行加载：`require('elements/MediaInfo'):new()`
- 配置 `script-opts/mediainfo.conf`（约 89 行，可自定义字体/位置/渐变主题）
- 显示顺序固定：硬解/软解 → HDR → 编码 → 音频编码 → 音频声道 → 分辨率 → 帧率
- 无需 ffprobe，纯 mpv 属性检测，智能高亮 HDR / 高分辨率 / 高品质音频

### 4. 统计信息面板 `stats`（中文版）📊
- 汉化版 `scripts/stats.lua`（约 3231 行，对应本人仓库 [mpv-stats 中文翻译](https://github.com/yosh-wang/mpv-stats.lua-zh-chinese-translation-)）
- `script-opts/stats.conf` 调校（约 +34 行），uosc 控制栏「统计」按钮即调用

### 5. HDR 自动切换 `toggleHDR` 🔆 【备用功能】
根据**显示器当前 HDR/SDR 状态**与**播放视频的 HDR/SDR 属性**，自动切换系统 HDR（依赖 `HDRCmd.exe`）。

- 脚本 `scripts/toggleHDR.lua`+ `script-opts/toggleHDR.conf`
- 四条逻辑独立开关（`hdr_hdr` / `hdr_off_open` / `hdr_open_off` / `sdr_sdr`）
- 默认 `enabled=no`，需要时改为 `yes` 并配置 `hdr_cmd_path`（如 `D:\HDRTray\HDRCmd.exe`）

### 6. 文件浏览器鼠标导航 📂
增强 `scripts/file-browser` 模块：

- 新增 `modules/navigation/mouse.lua`（约 +93 行）—— 鼠标滚轮/点击导航
- 新增 `modules/navigation/cursor.lua`（约 +30 行）—— 光标跟随
- 改写 `modules/ass.lua`（约 +230 行）、`modules/controls.lua`、`modules/globals.lua`、`modules/keybinds.lua`

### 7. 打开文件重置倍速 🔁
`scripts/reset_speed_on_file.lua`（约 12 行）：打开新文件时自动将播放速度恢复为 1.0x，避免上一段视频的倍速残留到新视频。

### 8. uosc 界面与空闲页优化 ⚙️
`script-opts/uosc.conf` 关键调校：

```ini
volume_persistency=idle       # 暂停/空闲时保持音量设置
speed_persistency=idle        # 暂停/空闲时保持倍速设置
destination_time=total        # 时间轴右侧显示总时长（原为剩余时间）
opacity=menu=0.9,submenu=0.7,curtain=0.5,position=0.8,timeline=0.8  # 控制栏/时间轴半透明
idlescreen=yes                # 空闲页显示中央标记（移植自 uosc v5.12.1 / mpv-lazy）
idlemsg=yosh.wang             # 空闲页中央文字
idlelogo_scale=1.15           # 中央 Logo 独立倍率（0=自动按窗口高度换算）
```

控制栏 `controls` 行增加 `<idle>` 状态显示：空闲时也能看到「统计 / 画质 / 封面 / 章节 / 倍速 / 播放列表」等入口。

### 9. 图标字体升级 🔤
- 移除旧版 `MaterialIconsRound-Regular.otf` + `Material-Design-Iconic-Font.ttf`
- 改用 `modernz-icons.ttf` + `uosc_icons.otf`（modernz / uosc 新版图标集，显示更清晰）

### 10. 其余脚本配置微调 🛠️
对以下约 12 项配置做了针对性调校（多为交互手感与默认值优化）：

`trackselect.conf`(+19) · `recentmenu.conf`(+2) · `dynamic_crop.conf`(+2) · `persist_properties.conf`(+2) · `sub_assrt.conf`(+2) · `sub_fastwhisper.conf`(+8) · `thumbfast.conf`(+2) · `webui.conf`(+2) · `hdr_mode.conf`(+4) · `history_bookmark.conf`(+2) · `file-browser-keybinds.json`(+6) · `uosc_danmaku.conf`(+2)

### 11. 空闲页 Logo（空白页显示）🖼️
当 mpv 处于**空闲状态**（未加载任何视频、播放器显示空白页）时，uosc 会在画面中央绘制一个 **Logo + 文字** 的空闲页，避免一片黑屏。

- `idlescreen=yes` —— 总开关，开启空闲页
- `idlemsg=yosh.wang` —— 空闲页中央文字（可改成任意内容，如你的 ID / 标语）
- `idlelogo_scale=1.15` —— 中央 Logo 的独立缩放倍率（`0` = 自动按窗口高度换算，数值越大 Logo 越大）
- Logo 图形取自第 9 节升级后的图标字体（`modernz-icons` / `uosc_icons`），显示更清晰
- 空闲页同时提供「统计 / 画质 / 封面 / 章节 / 倍速 / 播放列表」等入口（见第 8 节 `controls` 行的 `<idle>` 状态）

> 说明：空闲页 Logo 是 uosc 自带能力，本仓库仅做了**缩放倍率（1.15）与中央文字（yosh.wang）的个性化**，未改动其显示逻辑。

---

## ⚙️ 关键参数速查

| 配置项 | 文件 | yosh 取值 | 作用 |
|--------|------|-----------|------|
| 右键菜单缩放 | `context_menu_yosh.conf` | `1.5`~`3.5` | menu_min/max_scale：自适应宽度 |
| 起播格式 Logo | `startup_format_logos.conf` | `yes`/`color` | enabled/style：开播展示专业格式徽章 |
| 视频技术标签 | `mediainfo.conf` | `yes` | mediainfo_enabled：控制栏技术参数标签 |
| 空闲页 Logo | `uosc.conf` | `1.15` | idlelogo_scale：中央 mpv Logo 倍率 |
| 时间轴显示 | `uosc.conf` | `total` | destination_time：右侧显示总时长 |
| 音量/倍速持久 | `uosc.conf` | `idle` | volume/speed_persistency：空闲保持设置 |


---

## 📥 安装与使用

### 直接使用（推荐自用）
1. 克隆或下载本仓库 `yosh.wang` 分支
2. 将 `portable_config/` 内全部内容复制到你的 mpv 便携目录（与 `mpv.exe` 同级）
3. 启动 mpv 即可

```bash
git clone -b yosh.wang https://github.com/yosh-wang/yosh-mpv-config.git
```

---

## 📜 许可证

本仓库继承上游 [dyphire/mpv-config](https://github.com/dyphire/mpv-config) 的许可证（见 `LICENSE.MD`）。
其中本人新增/改写的脚本（context_menu_yosh、startup-format-logos、MediaInfo 等）以 MIT 授权，可自由使用与二次修改。

---

⭐ 如果这个配置对你有帮助，欢迎 Star 与进群交流！
