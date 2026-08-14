//
//  Router.swift
//  SwidtLea
//
//  Created by Qiaen on 2026/8/13.
//

import SwiftUI

enum Route: Hashable {
    case zst(userId: Int)
    case profile
    case login
}

class Router: ObservableObject {
    @Published var path: [Route] = []
    // 进入下一个页面，页面需要在enum Route配置，还可以传递参数
    func push(_ route: Route) {
//        print("hello router")
        path.append(route)
    }
    // 放回上一级
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    // 清除所有后回到首页
    func popRoot() {
        path.removeAll()
    }
    
    // 统一的路由目标
    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .zst(let userId):
            ZStackTest(userId: userId)
        case .profile:
            EmptyView()
        case .login:
            Login()
        }
    }
}
// 统一的导航目标视图，这里可以做埋点等功能
struct RouterDestinationView: View {
    let route: Route
    @EnvironmentObject var router: Router
    
    var body: some View {
        router.destination(for: route)
            .onAppear{
                print("进入页面：\(route)")
            }
    }
}
