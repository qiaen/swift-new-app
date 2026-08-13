import Foundation

struct NetworkConstants {
    // 基础 URL
    static let baseURL = ""
    
    // 超时时间
    static let timeout: TimeInterval = 30
    
    // 请求头
    struct Headers {
        static let contentType = "Content-Type"
        static let accept = "Accept"
        static let authorization = "Authorization"
        static let userAgent = "User-Agent"
        
        static let json = "application/json"
        static let formUrlencoded = "application/x-www-form-urlencoded"
        static let multipart = "multipart/form-data"
    }
    
    // API 路径
    struct APIPath {
        // Auth
        static let login = "/api/koc/auth/login"
        static let logout = "/api/koc/auth/logout"
        static let register = "/api/koc/auth/register"
        static let refreshToken = "/api/koc/auth/refresh"
        
        // User
        static let userInfo = "/api/koc/user/info"
        static let userUpdate = "/api/koc/user/update"
        static let userDelete = "/api/koc/user/delete"
        static let getMe = "/api/koc/creator/profile/me"
        
        // 提供构建方法, Service那里使用path时候： path: APIPath.userDelete(userId: userId),
        static func testPingjieUrl(userId: Int) -> String {
            return "/api/koc/user/\(userId)/delete"
        }
        // Video
        static let videoList = "/api/koc/video/list"
        static let videoDetail = "/api/koc/video/detail"
        static let videoUpload = "/api/koc/video/upload"
        
        // 添加更多...
    }
    
    // 状态码
    struct StatusCode {
        static let success = 200
        static let created = 201
        static let badRequest = 400
        static let unauthorized = 401
        static let forbidden = 403
        static let notFound = 404
        static let serverError = 500
    }
}
