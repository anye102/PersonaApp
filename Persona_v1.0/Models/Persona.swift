//
//  Persona.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/20.
//

import Foundation
internal import Combine

// Persona数据模型
class Persona: Identifiable, ObservableObject, Hashable, Codable {
    
    let id: UUID
    var name: String
    var avatar: String
    var personality: String
    var backstory: String
    @Published var followers: [UUID: Bool] = [:]
    let userId: UUID
    
    init(
        id: UUID = UUID(),
        name: String,
        avatar: String,
        personality: String,
        backstory: String = "nil",
        userId: UUID
    ) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.personality = personality
        self.backstory = backstory
        self.userId = userId
    }
    
    // 检查是否被当前用户关注
    func isFollowedByCurrentUser() -> Bool {
        guard let currentUserId = UserManager.shared.currentUser?.id else {
            return false
        }
        return followers[currentUserId] ?? false
    }

    // 设置当前用户的关注状态
    func setFollowedByCurrentUser(_ followed: Bool) {
        guard let currentUserId = UserManager.shared.currentUser?.id else {
            return
        }
        followers[currentUserId] = followed
    }
    
    // 用于解码的初始化器
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.avatar = try container.decode(String.self, forKey: .avatar)
        self.personality = try container.decode(String.self, forKey: .personality)
        self.backstory = try container.decode(String.self, forKey: .backstory)
        self.followers = try container.decode([UUID: Bool].self, forKey: .followers)
        self.userId = try container.decode(UUID.self, forKey: .userId)
    }
    
    // 用于编码的方法
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encodeIfPresent(self.avatar, forKey: .avatar)
        try container.encode(self.personality, forKey: .personality)
        try container.encodeIfPresent(self.backstory, forKey: .backstory)
        try container.encode(self.followers, forKey: .followers)
        try container.encode(self.userId, forKey: .userId)
    }
    
    // 定义CodingKeys
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case avatar
        case personality
        case backstory
        case followers
        case userId
    }
    
    // MARK: - Hashable
        
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Persona, rhs: Persona) -> Bool {
        return lhs.id == rhs.id
    }
}
