import Foundation
enum SocialPlatform: String, Decodable {
    case TikTok
    case Youtube
    case FaceBook
    // 兜底：接口返回未知平台时不崩溃
    case unknown
}

// 登录响应数据
struct GetMeData: Decodable {
    let socialAccounts: [SocialAccounts]
}

// user 对象
struct SocialAccounts: Decodable {
    let id: String
    let followers: Int
    let platform: SocialPlatform
}

class UserService {
    static let shared = UserService()
    private let network = NetworkManager.shared
    
    private init() {}
    
    // 登录
    func getMe(
        completion: @escaping (Result<BaseResponse<GetMeData>, NetworkError>) -> Void
    ) {
        network.get(
            path: NetworkConstants.APIPath.getMe,
            responseType: GetMeData.self,
            completion: completion
        )
    }
    
}
