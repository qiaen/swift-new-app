import Foundation

struct BaseResponse<T: Decodable>: Decodable {
    let message: String
    let data: T?
    let result: Bool
    
    enum CodingKeys: String, CodingKey {
        case message
        case data
        case result
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = (try? container.decode(String.self, forKey: .message)) ?? ""
        result = (try? container.decode(Bool.self, forKey: .result)) ?? false
        if let decoded = try? container.decode(T.self, forKey: .data) {
            data = decoded
        } else {
            // data 缺失或解码失败时置空，并留痕，避免「数据空白」问题难以排查
            data = nil
            print("⚠️ BaseResponse data 解码失败: \(T.self), message=\(message)")
        }
    }
}

// 空数据模型
struct EmptyData: Decodable {}
