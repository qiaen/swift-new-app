//
//  SignedURLCache.swift
//  SwiftNew
//
//  Created by QIAEN on 2026/8/14.
//

import Foundation

/// 签名 URL 缓存项
struct SignedURLCacheItem: Codable {
    let signedURL: String        // 完整签名链接（含 query 参数）
    let expireAt: TimeInterval   // 过期时间戳（已提前 1 分钟）
}

/// 签名 URL 缓存
/// 以原始路径 URL（不含签名参数）为 key，
/// value 为「完整签名链接 + 过期时间（q-sign-time 结束时间 - 1 分钟）」。
/// 命中 key 且未过期 → 返回缓存里的完整签名链接；否则返回 nil，需使用新链接。
actor SignedURLCache {
    static let shared = SignedURLCache()
    
    private let defaults = UserDefaults.standard
    private let keyPrefix = "signed_url_cache_"
    /// 提前 1 分钟过期，避免踩线
    private let advanceSeconds: TimeInterval = 60
    
    private init() {}
    
    /// 存储：key 为原始路径 URL
    func store(originalKey: String, signedURL: String, expireAt: TimeInterval) {
        guard expireAt > 0 else { return } // 解析不到过期时间则不缓存
        let item = SignedURLCacheItem(signedURL: signedURL, expireAt: expireAt)
        guard let data = try? JSONEncoder().encode(item) else { return }
        defaults.set(data, forKey: keyPrefix + originalKey)
    }
    
    /// 从签名 URL 中解析出原始 key、过期时间并存储
    /// - Returns: 原始路径 key
    @discardableResult
    func store(signedURL: String) -> String {
        guard let url = URL(string: signedURL),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return signedURL
        }
        
        let originalKey = Self.originalKey(of: signedURL)
        
        // 从 q-sign-time=开始;结束 中解析过期时间
        var expireAt: TimeInterval = 0
        for item in components.queryItems ?? [] where item.name == "q-sign-time" {
            let parts = (item.value ?? "").split(separator: ";")
            if parts.count == 2, let end = Double(parts[1]) {
                expireAt = end - advanceSeconds
            }
        }
        
        store(originalKey: originalKey, signedURL: signedURL, expireAt: expireAt)
        return originalKey
    }
    
    /// 查询：命中 key 且未过期 → 返回完整签名链接；否则返回 nil（需用新的链接）
    func cachedSignedURL(for originalKey: String) -> String? {
        guard let data = defaults.data(forKey: keyPrefix + originalKey),
              let item = try? JSONDecoder().decode(SignedURLCacheItem.self, from: data) else {
            return nil
        }
        // 未过期
        guard Date().timeIntervalSince1970 < item.expireAt else {
            defaults.removeObject(forKey: keyPrefix + originalKey)
            return nil
        }
        return item.signedURL
    }
    
    /// 清空缓存
    func clear() {
        let allKeys = defaults.dictionaryRepresentation().keys
            .filter { $0.hasPrefix(keyPrefix) }
        allKeys.forEach { defaults.removeObject(forKey: $0) }
    }
    
    /// 去掉 query 参数，得到原始路径 key
    static func originalKey(of urlString: String) -> String {
        guard var components = URLComponents(string: urlString) else { return urlString }
        components.query = nil
        components.fragment = nil
        return components.string ?? urlString
    }
}
