//
//  DTOs.swift
//  LeanNetworkingDemo
//
//  Created by Oleksandr Glagoliev on 13.07.2020.
//  Copyright © 2020 Oleksandr Glagoliev. All rights reserved.
//

import Foundation

public struct MediaDTO: Codable {
    public let url: String
    public let id: String
    
    public init(id: String, url: String) {
        self.id = id
        self.url = url
    }
}

public struct TimelineOwnerDTO: Codable {
    public let id: String
    public let fullname: String
    public let username: String
    public let profilePhoto: MediaDTO?
    public let isVerified: Bool
}

public struct TimelineAlbumDTO: Codable {
    public let id: String
    public let name: String
}

public struct TimelineItemDTO: Codable {
    public let id: String
    public let type: String
    public let object: MediaDTO?
    public let thumb: MediaDTO?
    public let isLiked: Bool?
}


public struct TimelineBody: Codable {
    public let limit: Int
    public let offset: String?
    
    public init(limit: Int, offset: String? = nil) {
        self.limit = limit
        self.offset = offset
    }
}

public struct TimelineDTO: Codable {
    public let id: String
    public let owner: TimelineOwnerDTO
    public let album: TimelineAlbumDTO
    public let items: [TimelineItemDTO]
    public let totalItemCount: Int
    public let created: Date

    public init(
        id: String,
        owner: TimelineOwnerDTO,
        album: TimelineAlbumDTO,
        items: [TimelineItemDTO],
        totalItemCount: Int,
        created: Date
    ) {
        self.id = id
        self.owner = owner
        self.album = album
        self.items = items
        self.created = created
        self.totalItemCount = totalItemCount
    }
}

public struct TimelineResponse: Decodable {
    public let content: [TimelineDTO]

    public init(content: [TimelineDTO]) {
        self.content = content
    }
}
