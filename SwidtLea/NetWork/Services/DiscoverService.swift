import Foundation
enum EventStatus: String, Codable {
    case Active
    case Ended
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = EventStatus(rawValue: raw) ?? .unknown
    }
}

// 活动数据
struct DiscoverData: Decodable {
    let list: [DiscoverItem]
}

// 后端返回逗号分隔字符串时，用它自动解码为数组
struct CommaSeparatedList: Decodable, Equatable {
    let values: [String]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        values = raw
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
// 活动 对象
struct DiscoverItem: Decodable, Identifiable {
    let id: String
    let bannerUrl: String
    let name: String
    let eventStatus: EventStatus
    let platforms: CommaSeparatedList
    let startAt: String
    let endAt: String
}

class DiscoverService {
    static let shared = DiscoverService()
    private let network = NetworkManager.shared
    
    private init() {}
    
    // 登录
    func getDiscoverList(
        eventStatus: EventStatus,
        completion: @escaping (Result<BaseResponse<DiscoverData>, NetworkError>) -> Void
    ) {
        let request = DiscoverRequest(eventStatus: eventStatus)
        network.get(
            path: NetworkConstants.APIPath.discoverList,
            parameters: request.toDictionary(),
            responseType: DiscoverData.self,
            completion: completion
        )
    }
    
}
