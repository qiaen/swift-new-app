import Foundation

class NetworkLogger {
    static let shared = NetworkLogger()
    private let isLoggingEnabled = true

    /// 敏感字段：日志输出时自动脱敏
    private static let sensitiveKeys: Set<String> = [
        "password", "token", "accessToken", "refreshToken", "authorization"
    ]

    /// 将 "key": "value" 形式的敏感值替换为 "***"
    private static func maskSensitive(_ text: String) -> String {
        var masked = text
        for key in sensitiveKeys {
            masked = masked.replacingOccurrences(
                of: "\"\(key)\"\\s*:\\s*\"[^\"]*\"",
                with: "\"\(key)\": \"***\"",
                options: .regularExpression
            )
        }
        // 处理 Authorization: Bearer xxx
        masked = masked.replacingOccurrences(
            of: "(?i)(Bearer\\s+)[^\\s\"]+",
            with: "$1***",
            options: .regularExpression
        )
        return masked
    }

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
        
        // Headers（Authorization 等敏感值脱敏）
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("📤 Headers:")
            headers.forEach { key, value in
                let masked = sensitiveKeys.contains(key.lowercased()) ? "***" : value
                print("   \(key): \(masked)")
            }
        }
        
        // Body（敏感字段脱敏）
        if let bodyData = request.httpBody,
           let bodyString = String(data: bodyData, encoding: .utf8) {
            print("📤 Body: \(maskSensitive(bodyString))")
        }
        
        // 响应信息
        if let httpResponse = response as? HTTPURLResponse {
            print("📥 Status Code: \(httpResponse.statusCode)")
        }
        
        // 响应数据（敏感字段脱敏）
        if let data = data,
           let dataString = String(data: data, encoding: .utf8) {
            print("📥 Response Data: \(maskSensitive(dataString))")
        }
        
        // 错误信息
        if let error = error {
            print("❌ Error: \(error.localizedDescription)")
        }
        
        print("🌐 ====================================")
    }
}
