//
//  CachedAsyncImage.swift
//  SwiftNew
//
//  Created by QIAEN on 2026/8/14.
//

import SwiftUI

/// 带缓存的网络图片组件
struct CachedAsyncImage<Placeholder: View>: View {
    let urlString: String
    @ViewBuilder let placeholder: () -> Placeholder
    
    @StateObject private var loader = CachedImageLoader()
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                placeholder()
            }
        }
        // 用原始路径（去掉签名参数）作为 id，签名变化不会触发重复加载
        .task(id: SignedURLCache.originalKey(of: urlString)) {
            await loader.load(urlString: urlString)
        }
    }
}

@MainActor
final class CachedImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private var task: Task<Void, Never>?
    
    func load(urlString: String) async {
        guard let url = URL(string: urlString), !urlString.isEmpty else { return }
        
        task?.cancel()
        task = Task {
            let loaded = await ImageCache.shared.image(for: url)
            guard !Task.isCancelled else { return }
            self.image = loaded
        }
        await task?.value
    }
}
