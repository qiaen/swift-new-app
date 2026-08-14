import Foundation

// 登录响应数据
struct LoginData: Decodable {
    let accessToken: String
    let user: LoginUser
}

// user 对象
struct LoginUser: Decodable {
    let userName: String
    let email: String
}

class AuthService {
    static let shared = AuthService()
    private let network = NetworkManager.shared
    
    private init() {}
    
    // 登录
    func login(
        username: String,
        password: String,
        completion: @escaping (Result<BaseResponse<LoginData>, NetworkError>) -> Void
    ) {
        let request = LoginRequest(username: username, password: password)
        network.post(
            path: NetworkConstants.APIPath.login,
            parameters: request,
            responseType: LoginData.self
        ) { result in
            switch result {
                case .success(let response):
                    // 网络层已保证 result == true 才走 success
                    if let data = response.data {
                        // ⭐ 登录成功后保存 Token
                        NetworkManager.shared.setAuthToken(data.accessToken)
                        print("✅ Token 已保存: \(data.accessToken.prefix(12))...")
                    }
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
    
    // 登出
    func logout(completion: @escaping (Result<BaseResponse<EmptyData>, NetworkError>) -> Void) {
        network.post(
            path: NetworkConstants.APIPath.logout,
            responseType: EmptyData.self,
            completion: completion
        )
    }
}
