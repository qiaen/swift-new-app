//
//  ContentView.swift
//  SwidtLea
//
//  Created by Qiaen on 2026/8/13.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            VStack {
                QnButton(title: "从这个页面去另外页面", type: .primary) {
                    print("hello----zs")
                    router.push(.zst(userId: 10086))
                }
            }
            .padding()
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .zst(let userId):
                    ZStackTest(userId: userId)
                case .profile:
                    EmptyView()
                }
            }
        }
        .environmentObject(router)
    }
}

#Preview {
    ContentView()
}
