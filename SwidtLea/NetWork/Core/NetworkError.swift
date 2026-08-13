import Foundation

enum NetworkError: Error {
    case invalidURL
    case encodingError
    case decodingError(String)
    case networkError(String)
    case invalidResponse
    case httpError(Int)
    case noData
    case unauthorized
    case custom(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .encodingError:
            return "参数编码失败"
        case .decodingError(let message):
            return "数据解析失败: \(message)"
        case .networkError(let message):
            return "网络错误: \(message)"
        case .invalidResponse:
            return "无效的响应"
        case .httpError(let code):
            return "HTTP 错误: \(code)"
        case .noData:
            return "没有数据返回"
        case .unauthorized:
            return "未授权，请重新登录"
        case .custom(let message):
            return message
        }
    }
    
    var code: Int {
        switch self {
        case .httpError(let code):
            return code
        case .unauthorized:
            return 401
        default:
            return -1
        }
    }
}
