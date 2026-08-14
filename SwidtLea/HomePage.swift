//
//  ContentView.swift
//  SwidtLea
//
//  Created by Qiaen on 2026/8/13.
//

import SwiftUI
struct BannerBox: View {
    @EnvironmentObject var router: Router
    let images = ["banner2", "banner3", "banner1"]
    
    @State private var isAutoPlay = true
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 6, on: .main, in: .common).autoconnect()
    
    let boxHeight = 210.0
    var body: some View {
        TabView(selection: $currentIndex) {
                    ForEach(images.indices, id: \.self) { index in
                        Image(images[index])
                            .resizable()
                            .scaledToFill()
                            .frame(height: boxHeight)
                            .onTapGesture {
                                router.push(.zst(userId: 1001))
                            }
                            .clipped()
                            .tag(index)
                            
                    }
                }
                .frame(height: boxHeight)
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .always))
                #endif
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            isAutoPlay = false
                        }
                        .onEnded { _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                isAutoPlay = true
                            }
                        }
                )
                .onReceive(timer) { _ in
                    guard isAutoPlay else { return }
                    withAnimation {
                        currentIndex = (currentIndex + 1) % images.count
                    }
                }
            
    }
}
struct HomePage: View {
    @EnvironmentObject var router: Router
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                if StorageDefault.shared.hasToken() {
                    BannerBox()
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 10)
                        .padding()
                } else {
                    NotLoginPage(pageTitle: "Home")
                }
            }
            .navigationDestination(for: Route.self) { route in
                // 重点：导航目标由它生成
                RouterDestinationView(route: route)
            }
            .navigationTitle("Home")
            .toolbar {
                        ToolbarItem() {
                            Button("完成") {
                                
                            }
                        }
                    }
        }
    }
}

#Preview {
    ContentView()
}
