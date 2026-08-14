import Foundation

// 活动详情响应：{ event: EventDetail }
struct EventDetailData: Decodable {
    let event: EventDetail?
}

// 活动详情（对应后端 ResEvent）
struct EventDetail: Decodable, Identifiable {
    let id: String
    let name: String
    let bannerUrl: String
    let eventStatus: EventStatus
    let startAt: String
    let endAt: String
    let platforms: CommaSeparatedList
    let countryScope: CommaSeparatedList
    let rulesText: String
    let creatorSubmissionStatus: String?
    let visibility: String?
    let submissionMode: String?
    let contentTypes: String?
    let gameCode: String?
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, bannerUrl, eventStatus, startAt, endAt
        case platforms, countryScope, rulesText, creatorSubmissionStatus
        case visibility, submissionMode, contentTypes, gameCode, description
    }
}

// 素材列表响应：{ list: [MaterialItem] }
struct MaterialsData: Decodable {
    let list: [MaterialItem]
}

// 活动素材（对应后端 ResMaterial）
struct MaterialItem: Decodable, Identifiable {
    let id: String
    let title: String
    let type: String
    let fileUrl: String
    let thumbnailUrl: String?
    let fileSize: Double?
    let materialStatus: String?
    let eventId: String?
    let visibility: String?
    let zipDescription: String?
}
