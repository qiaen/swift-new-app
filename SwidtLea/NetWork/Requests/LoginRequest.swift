import Foundation

// 登录请求
struct LoginRequest: APIRequestParameters {
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
}
