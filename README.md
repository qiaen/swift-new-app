# Swidt New App

一个用于探索 Swift / SwiftUI 新功能的 iOS 示例 App，功能还会不断更新。

## 功能

- 基于 `NavigationStack` + 自定义 `Router` 的路由导航，支持页面跳转、返回、回首页，并通过枚举传递参数
- 自定义组件 `QnButton`：支持主按钮/默认按钮样式、图标、loading 状态
- `ZStackTest`：演示层叠布局（overlay、ZStack）的页面

## 目录结构

```
SwidtLea/
├── SwidtLeaApp.swift   # App 入口
├── ContentView.swift   # 首页，注册路由与 navigationDestination
├── Router.swift        # 路由定义（enum Route）与导航逻辑
└── ZStackTest.swift    # 自定义按钮 QnButton、OauthBox、ZStackTest 页面
```

## 运行

使用 Xcode 打开 `SwidtLea.xcodeproj`，选择模拟器或真机后直接 Run 即可。

## 说明

- 页面路由统一在 `Route` 枚举中注册，跳转通过 `router.push(.zst(userId: xxx))`，参数随枚举携带
- 返回上一页使用 `router.pop()`，回到首页使用 `router.popRoot()`
