//
//  ImageCache.swift
//  SwiftNew
//
//  Created by QIAEN on 2026/8/14.
//

import SwiftUI
import CryptoKit

/// 图片缓存管理：内存 + 磁盘双缓存
/// 磁盘文件名基于原始路径（不含签名参数），同一张图即使签名变化也不会重复下载
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
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ImageCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    }
    
    /// 获取图片：优先内存 -> 磁盘 -> 网络下载
    /// 网络下载前会先查签名 URL 缓存，命中且未过期则用缓存的签名链接
    func image(for url: URL) async -> UIImage? {
        let originalKey = SignedURLCache.originalKey(of: url.absoluteString)
        let cacheKey = originalKey as NSString
        
        // 1. 内存缓存
        if let image = memoryCache.object(forKey: cacheKey) {
            return image
        }
        
        // 2. 磁盘缓存（以原始路径为文件名，签名变化不重复下载）
        let fileURL = diskFileURL(forKey: originalKey)
        if let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            memoryCache.setObject(image, forKey: cacheKey)
            return image
        }
        
        // 3. 网络下载
        // 3.1 优先使用未过期的签名链接
        let downloadURL: URL
        if let cached = await SignedURLCache.shared.cachedSignedURL(for: originalKey),
           let cachedURL = URL(string: cached) {
            downloadURL = cachedURL
        } else {
            // 未命中或已过期 → 使用后端新给的链接
            downloadURL = url
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: downloadURL)
            guard let image = UIImage(data: data) else { return nil }
            memoryCache.setObject(image, forKey: cacheKey)
            try? data.write(to: fileURL)
            // 下载成功后，用后端给的链接更新签名缓存
            await SignedURLCache.shared.store(signedURL: url.absoluteString)
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
    
    private func diskFileURL(forKey key: String) -> URL {
        let fileName = sha256(key)
        return cacheDirectory.appendingPathComponent(fileName)
    }
    
    private func sha256(_ string: String) -> String {
        guard let data = string.data(using: .utf8) else { return string }
        return CryptoKit.SHA256.hash(data: data)
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
}
