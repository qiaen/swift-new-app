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
        message = try container.decode(String.self, forKey: .message)
        result = try container.decode(Bool.self, forKey: .result)
        data = try? container.decode(T.self, forKey: .data)
    }
}

// 空数据模型
struct EmptyData: Decodable {}
