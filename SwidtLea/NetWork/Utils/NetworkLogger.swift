import Foundation

class NetworkLogger {
    static let shared = NetworkLogger()
    private let isLoggingEnabled = true
    
    private init() {}
    
    static func log(
        request: URLRequest,
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) {
        guard NetworkLogger.shared.isLoggingEnabled else { return }
        
        print("🌐 ========== Network Request ==========")
        
        // 请求信息
        print("📤 Method: \(request.httpMethod ?? "UNKNOWN")")
        print("📤 URL: \(request.url?.absoluteString ?? "UNKNOWN")")
        
        // Headers
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("📤 Headers:")
            headers.forEach { print("   \($0.key): \($0.value)") }
        }
        
        // Body
        if let bodyData = request.httpBody,
           let bodyString = String(data: bodyData, encoding: .utf8) {
            print("📤 Body: \(bodyString)")
        }
        
        // 响应信息
        if let httpResponse = response as? HTTPURLResponse {
            print("📥 Status Code: \(httpResponse.statusCode)")
        }
        
        // 响应数据
        if let data = data,
           let dataString = String(data: data, encoding: .utf8) {
            print("📥 Response Data: \(dataString)")
        }
        
        // 错误信息
        if let error = error {
            print("❌ Error: \(error.localizedDescription)")
        }
        
        print("🌐 ====================================")
    }
}
