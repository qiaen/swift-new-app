import Foundation

// 获取活动请求
struct DiscoverRequest: Encodable {
    let eventStatus: EventStatus?
    
    init(eventStatus: EventStatus? = nil) {
        self.eventStatus = eventStatus
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        if let eventStatus = eventStatus {
            dict["eventStatus"] = eventStatus.rawValue
        }
        return dict
    }
}
