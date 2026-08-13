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
}

class Router: ObservableObject {
    @Published var path: [Route] = []
    // 进入下一个页面，页面需要在enum Route配置，还可以传递参数
    func push(_ route: Route) {
        print("hello router")
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
}
