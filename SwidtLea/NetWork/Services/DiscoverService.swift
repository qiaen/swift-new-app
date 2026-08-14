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
    
    // 获取活动列表，eventStatus 传 nil 表示不区分活动状态
    func getDiscoverList(
        eventStatus: EventStatus? = nil,
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
    
    // 获取活动详情
    func getEventDetail(
        eventId: String,
        completion: @escaping (Result<BaseResponse<EventDetailData>, NetworkError>) -> Void
    ) {
        network.get(
            path: NetworkConstants.APIPath.eventDetail(eventId: eventId),
            parameters: nil,
            responseType: EventDetailData.self,
            completion: completion
        )
    }
    
    // 获取活动素材列表
    func getMaterials(
        eventId: String,
        pageNo: Int = 1,
        pageSize: Int = 100,
        completion: @escaping (Result<BaseResponse<MaterialsData>, NetworkError>) -> Void
    ) {
        let parameters: [String: Any] = [
            "eventId": eventId,
            "pageNo": pageNo,
            "pageSize": pageSize
        ]
        network.get(
            path: NetworkConstants.APIPath.materials,
            parameters: parameters,
            responseType: MaterialsData.self,
            completion: completion
        )
    }
    
}
