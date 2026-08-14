import Foundation

// 获取活动请求
struct DiscoverRequest: APIRequestParameters {
    let eventStatus: EventStatus?
    
    init(eventStatus: EventStatus? = nil) {
        self.eventStatus = eventStatus
    }
}
