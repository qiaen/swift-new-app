import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {
        // 初始化时从本地读取 Token
        if let token = StorageDefault.shared.getToken() {
            self.authToken = token
            print("✅ 从本地恢复 Token: \(token.prefix(20))...")
        }
    }
    
    private let baseURL = NetworkConstants.baseURL
    private let timeout = NetworkConstants.timeout
    private var headers: [String: String] = [
        NetworkConstants.Headers.contentType: NetworkConstants.Headers.json,
        NetworkConstants.Headers.accept: NetworkConstants.Headers.json
    ]
    
    // Token 管理
    private var authToken: String? {
        get {
            return StorageDefault.shared.getToken()
        }
        set {
            if let token = newValue {
                StorageDefault.shared.saveToken(token)
                headers[NetworkConstants.Headers.authorization] = "Bearer \(token)"
            } else {
                StorageDefault.shared.deleteToken()
                headers.removeValue(forKey: NetworkConstants.Headers.authorization)
            }
        }
    }
    
    // MARK: - 公开方法
    func setAuthToken(_ token: String) {
        print("token-----", token)
        self.authToken = token
    }
    
    func clearAuthToken() {
        authToken = nil
    }
    
    // MARK: - 请求方法
    func request<T: Decodable>(
        method: HTTPMethod,
        path: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<BaseResponse<T>, NetworkError>) -> Void
    ) {
        guard let url = URL(string: baseURL + path) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeout
        
        // 合并 Headers
        var allHeaders = self.headers
        if let additionalHeaders = headers {
            allHeaders.merge(additionalHeaders) { _, new in new }
        }
        allHeaders.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        // 处理参数
        if let parameters = parameters {
            if method == .get || method == .delete {
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                components?.queryItems = parameters.map { key, value in
                    URLQueryItem(name: key, value: "\(value)")
                }
                if let newURL = components?.url {
                    request.url = newURL
                }
            } else {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                } catch {
                    completion(.failure(.encodingError))
                    return
                }
            }
        }
        
        // 发送请求
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 日志记录
             NetworkLogger.log(request: request, data: data, response: response, error: error)
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error.localizedDescription)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    DispatchQueue.main.async {
                        completion(.failure(.unauthorized))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(.httpError(httpResponse.statusCode)))
                    }
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let baseResponse = try decoder.decode(BaseResponse<T>.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(baseResponse))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(error.localizedDescription)))
                }
            }
        }
        
        task.resume()
    }
}

// MARK: - 便捷方法
extension NetworkManager {
    func get<T: Decodable>(
        path: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<BaseResponse<T>, NetworkError>) -> Void
    ) {
        request(method: .get, path: path, parameters: parameters, headers: headers, responseType: responseType, completion: completion)
    }
    
    func post<T: Decodable>(
        path: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<BaseResponse<T>, NetworkError>) -> Void
    ) {
        request(method: .post, path: path, parameters: parameters, headers: headers, responseType: responseType, completion: completion)
    }
    
    func put<T: Decodable>(
        path: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<BaseResponse<T>, NetworkError>) -> Void
    ) {
        request(method: .put, path: path, parameters: parameters, headers: headers, responseType: responseType, completion: completion)
    }
    
    func delete<T: Decodable>(
        path: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<BaseResponse<T>, NetworkError>) -> Void
    ) {
        request(method: .delete, path: path, parameters: parameters, headers: headers, responseType: responseType, completion: completion)
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
