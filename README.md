# AniList
孩子自己vibe-coding的，发布才发现重名了✋😭🤚，（官方站在此：https://docs.anilist.co/）

一款专为二次元爱好者设计的**个人作品追踪 App**，帮助你系统化管理轻小说、动漫、漫画与 Galgame 四种作品的观看/游玩进度。

界面采用樱粉系二次元风格，圆角卡片设计，支持亮色/深色主题。**所有数据存储在本地，完全离线可用**。

## 功能特性

### 四种作品分类
- 轻小说 / 动漫 / 漫画 / Galgame 各自独立页面，底部导航栏切换，互不干扰

### 状态管理
- 轻小说 / 动漫 / 漫画：想看 / 追番中 / 已看完 / 弃坑
- Galgame：想玩 / 推线中 / 结局 / 弃坑
- 状态彩色标签区分，切换状态时**自动记录日期**（开始日期、完成日期）

### 作品信息
- 标题、封面（相册选择，可选）、观看平台与网址（轻小说/动漫/漫画，非必填，网址可点击跳转浏览器）

### 列表交互
- 卡片视图 / 列表视图自由切换
- 按状态筛选标签、标题关键词模糊搜索
- 三种排序：添加时间、标题（中文按拼音）、状态

### 批量管理
- AppBar 按钮或长按卡片进入批量模式
- 批量修改状态、批量删除（二次确认）、全选/取消全选
- 批量模式下右下角悬浮按钮自动隐藏

### 其它
- 可拖拽的悬浮添加按钮，松手自动吸附屏幕边缘
- 数据导出/导入 JSON 备份，换手机轻松迁移（支持合并导入与覆盖导入）
- 自带二次元风格启动页与空状态引导插画

## 技术栈

| 项目 | 说明 |
|------|------|
| 框架 | Flutter (Dart) |
| 本地存储 | SQLite (sqflite)，已实现版本化迁移 |
| 状态管理 | Provider |
| 最低版本 | Android 8.0 (API 26) |
| 应用语言 | 简体中文 |

主要依赖：`sqflite`、`provider`、`image_picker`、`file_picker`、`url_launcher`、`flutter_svg`、`shared_preferences`、`lpinyin`

## 运行与构建

```bash
# 安装依赖
flutter pub get

# 连接 Android 设备后运行调试
flutter run

# 构建发布版 APK
flutter build apk --release
```

构建产物位于 `build/app/outputs/flutter-apk/app-release.apk`。

## 项目结构

```
lib/
├── main.dart                 # 入口
├── app.dart                  # 应用装配（Provider + 路由）
├── theme/app_theme.dart      # 亮色/深色主题
├── constants/app_constants.dart  # 类型/状态枚举、配色常量
├── models/work.dart          # 作品数据模型
├── database/database_helper.dart # SQLite 建表与迁移、导出导入
├── providers/                # 状态管理（作品、设置）
├── screens/                  # 页面（启动页/列表/详情/添加/设置）
└── widgets/                  # 通用组件（卡片/标签/选择器/悬浮按钮等）
```

## 数据与隐私

- 所有数据保存在设备本地 SQLite 数据库，不上传任何服务器
- 应用不申请网络权限，无任何统计/追踪代码
- 封面图片复制到应用私有目录存储

## 版本

当前版本：1.1.0
