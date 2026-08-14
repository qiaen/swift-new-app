# Swidt New App

一个用于探索 Swift / SwiftUI 新功能的 iOS 示例 App，功能还会不断更新。

## 功能

- 基于 `NavigationStack` + 自定义 `Router` 的路由导航，支持页面跳转、返回、回首页，并通过枚举传递参数
- 统一导航目标视图 `RouterDestinationView`，可在页面进入时统一处理埋点等逻辑
- 底部 TabView 导航（首页 / 发现 / 素材库 / 我的），选中状态通过 `@AppStorage` 持久化
- 首页 `BannerBox` 轮播图：`TabView` 分页样式 + Timer 自动轮播、手势暂停自动播放
- 登录流程：未登录时首页展示引导页，登录成功后将 Token 保存到本地，自动注入请求头
- 网络层封装：基于 `URLSession`，支持 GET / POST / PUT / DELETE、统一 `BaseResponse` 解析、错误分类（401 未授权等）、网络日志打印
- 自定义组件：
  - `QnButton`：主按钮/默认按钮样式、图标、loading 状态、自定义圆角
  - `QnInput`：圆角输入框，支持 placeholder
  - `CheckboxToggleStyle`：自定义 checkbox 样式的 Toggle
- `ZStackTest`：演示层叠布局（overlay、ZStack）的页面

## 目录结构

```
SwidtLea/
├── SwidtLeaApp.swift        # App 入口
├── ContentView.swift        # Tab 容器（首页/发现/素材库/我的）
├── HomePage.swift           # 首页：BannerBox 轮播、未登录引导
├── Login.swift              # 登录页：QnInput、CheckboxToggleStyle、登录请求
├── NotLoginPage.swift       # 未登录提示页（去登录）
├── Router.swift             # 路由定义（enum Route）与统一导航目标 RouterDestinationView
├── ZStackTest.swift         # QnButton 自定义按钮、OauthBox、ZStackTest 页面
├── NetWork/                 # 网络层
│   ├── Core/                # NetworkManager / NetworkConstants / NetworkError
│   ├── Models/              # BaseResponse 通用响应模型
│   ├── Requests/            # LoginRequest 请求模型
│   ├── Services/            # AuthService（登录/登出）、UserService（用户信息）
│   └── Utils/               # NetworkLogger 网络日志
└── Utils/
    └── StorageDefault.swift # Token 本地存储（UserDefaults）
```

## 运行

使用 Xcode 打开 `SwidtLea.xcodeproj`，选择模拟器或真机后直接 Run 即可。

> 说明：`NetWork/Core/NetworkConstants.swift` 中 `baseURL` 目前为空，调试接口前需先配置为实际服务地址。

## 说明

- 页面路由统一在 `Route` 枚举中注册，跳转通过 `router.push(.zst(userId: xxx))`，参数随枚举携带
- 返回上一页使用 `router.pop()`，回到首页使用 `router.popRoot()`
- 登录成功后调用 `NetworkManager.shared.setAuthToken(token)` 保存 Token，之后的请求会自动携带 `Authorization: Bearer <token>`
- 未登录判断通过 `StorageDefault.shared.hasToken()`，Token 以 UserDefaults 方式持久化
