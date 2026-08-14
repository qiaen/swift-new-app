import Foundation

// 获取活动请求
struct DiscoverRequest: Encodable {
    let eventStatus: EventStatus
    
    init(eventStatus: EventStatus) {
        self.eventStatus = eventStatus
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "eventStatus": eventStatus
        ]
        return dict
    }
}
