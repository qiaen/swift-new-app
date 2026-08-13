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
struct ContentView: View {
    @StateObject private var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                BannerBox()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 10)
                    .padding()
                
            }
            .navigationTitle("Home")
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
