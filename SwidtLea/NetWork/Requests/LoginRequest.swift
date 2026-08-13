import Foundation

// 登录请求
struct LoginRequest: Encodable {
    let username: String
    let password: String
    let deviceId: String?
    let platform: String?
    
    init(username: String, password: String, deviceId: String? = nil, platform: String? = nil) {
        self.username = username
        self.password = password
        self.deviceId = deviceId
        self.platform = platform
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "username": username,
            "password": password
        ]
        if let deviceId = deviceId {
            dict["deviceId"] = deviceId
        }
        if let platform = platform {
            dict["platform"] = platform
        }
        return dict
    }
}
