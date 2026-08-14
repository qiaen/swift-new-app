//
//  ImageCache.swift
//  SwiftNew
//
//  Created by QIAEN on 2026/8/14.
//

import SwiftUI
import CryptoKit

/// 图片缓存管理：内存 + 磁盘双缓存
actor ImageCache {
    static let shared = ImageCache()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    
    private var cacheDirectory: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ImageCache", isDirectory: true)
    }
    
    private init() {
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    /// 获取图片：优先内存 -> 磁盘 -> 网络下载
    func image(for url: URL) async -> UIImage? {
        let key = url.absoluteString as NSString
        
        // 1. 内存缓存
        if let image = memoryCache.object(forKey: key) {
            return image
        }
        
        // 2. 磁盘缓存
        let fileURL = diskFileURL(for: url)
        if let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            memoryCache.setObject(image, forKey: key)
            return image
        }
        
        // 3. 网络下载
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            memoryCache.setObject(image, forKey: key)
            try? data.write(to: fileURL)
            return image
        } catch {
            print("图片下载失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 清空缓存
    func clearCache() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    private func diskFileURL(for url: URL) -> URL {
        let fileName = sha256(url.absoluteString)
        return cacheDirectory.appendingPathComponent(fileName)
    }
    
    private func sha256(_ string: String) -> String {
        guard let data = string.data(using: .utf8) else { return string }
        return CryptoKit.SHA256.hash(data: data)
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
}
