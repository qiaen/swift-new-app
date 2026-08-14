import Foundation

/// 请求参数协议：所有入参模型遵循 Encodable，由网络层统一编码，
/// 避免手写 [String: Any] 字典导致 key 拼写错误、类型不匹配等运行时问题。
protocol APIRequestParameters: Encodable {}

extension Encodable {
    /// Encodable → [String: Any]，用于 GET/DELETE 拼接 query string。
    /// 注意：Optional 字段为 nil 时会被自动省略（与手写字典的行为一致）。
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    }
}
