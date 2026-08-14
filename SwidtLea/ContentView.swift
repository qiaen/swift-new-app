import SwiftUI

enum MainTab: String, CaseIterable {
    case home = "首页"
    case discover = "发现"
    case materials = "素材库"
    case mine = "我的"
    
    var icon: (normal: String, selected: String) {
        switch self {
        case .home: return ("house", "house.fill")
        case .discover: return ("safari", "safari.fill")
        case .materials: return ("book", "book.fill")
        case .mine: return ("person", "person.fill")
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .home: HomePage()
        case .discover: Discover()
        case .materials: HomePage()
        case .mine: HomePage()
        }
    }
}

struct ContentView: View {
    @StateObject private var router = Router()
    @AppStorage("selectedTab") private var selectedTab: MainTab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                tab.view
                    .environmentObject(router)
                    .tabItem {
                        VStack(spacing: 4) {
                            Image(systemName: selectedTab == tab ? tab.icon.selected : tab.icon.normal)
                            Text(tab.rawValue)
                        }
                    }
                    .tag(tab)
            }
        }
    }
}

#Preview {
    ContentView()
}
