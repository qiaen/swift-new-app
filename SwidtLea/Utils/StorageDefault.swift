import Foundation

// MARK: - Token 存储管理器
class StorageDefault {
    static let shared = StorageDefault()
    private init() {}
    
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "auth_token"
    
    // 保存 Token
    func saveToken(_ token: String) {
        userDefaults.set(token, forKey: tokenKey)
        print("✅ Token 已保存到本地")
    }
    
    // 读取 Token
    func getToken() -> String? {
        return userDefaults.string(forKey: tokenKey)
    }
    
    // 删除 Token
    func deleteToken() {
        userDefaults.removeObject(forKey: tokenKey)
        print("🗑️ Token 已从本地清除")
    }
    
    // 检查 Token 是否存在
    func hasToken() -> Bool {
        return getToken() != nil
    }
}
