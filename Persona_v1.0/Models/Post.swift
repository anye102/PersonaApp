//
//  Post.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/20.
//

import Foundation
internal import Combine

// 动态数据模型
class Post: Identifiable, ObservableObject, Codable {
    // MARK： - 基本属性
    let id: UUID
    var personaId: UUID
    var content: String
    var timestamp: Date
    
    // MARK: - 点赞相关属性
    @Published var likeCount: Int = 0
    @Published var likes: [UUID: Bool] = [:]
    
    // MARK: - 收藏相关属性
    @Published var markCount: Int = 0
    @Published var marks: [UUID: Bool] = [:]
    
    // 用于解码的初始化器
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.personaId = try container.decode(UUID.self, forKey: .personaId)
        self.content = try container.decode(String.self, forKey: .content)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.likeCount = try container.decode(Int.self, forKey: .likeCount)
        self.likes = try container.decode([UUID:Bool].self, forKey: .likes)
        self.markCount = try container.decode(Int.self, forKey: .markCount)
        self.marks = try container.decode([UUID:Bool].self, forKey: .marks)
    }
    
    // 用于编码的方法
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.personaId, forKey: .personaId)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.timestamp, forKey: .timestamp)
        try container.encode(self.likeCount, forKey: .likeCount)
        try container.encode(self.likes, forKey: .likes)
        try container.encode(self.markCount, forKey: .markCount)
        try container.encode(self.marks, forKey: .marks)
    }
    
    // 定义CodingKeys
    enum CodingKeys: String, CodingKey {
        case id
        case personaId
        case content
        case timestamp
        case likeCount
        case likes
        case markCount
        case marks
    }

    // MARK: - 构造函数
    
    init(persona: Persona, content: String, timestamp: Date) {
        self.id = UUID()
        self.personaId = persona.id
        self.content = content
        self.timestamp = timestamp
    }
    
    // MARK: - 日期显示函数
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // 检查当前用户是否点赞
    func isLikedByCurrentUser() -> Bool {
        guard let currentUserId = UserManager.shared.currentUser?.id else {
            return false
        }
        return likes[currentUserId] ?? false
    }
    
    // 检查当前用户是否收藏
    func isMarkedByCurrentUser() -> Bool {
        guard let currentUserId = UserManager.shared.currentUser?.id else {
            return false
        }
        return marks[currentUserId] ?? false
    }
    
    func toggleLike() {
        
        guard let currentUserId = UserManager.shared.currentUser?.id else {
            return
        }
        
        let currentlyLiked = isLikedByCurrentUser()
        likes[currentUserId] = !currentlyLiked
        
        // 更新点赞总数
        likeCount += currentlyLiked ? -1 : 1
        
        // 通知PersonaManager保存更新后的Post
        NotificationCenter.default.post(name: NSNotification.Name("PostUpdated"), object: self)
    }
    
    func toggleMark() {
        guard let currentUserId = UserManager.shared.currentUser?.id else {
            return
        }
        
        let currentlyMarked = isMarkedByCurrentUser()
        marks[currentUserId] = !currentlyMarked
        
        // 更新点赞总数
        markCount += currentlyMarked ? -1 : 1
        
        // 通知PersonaManager保存更新后的Post
        NotificationCenter.default.post(name: NSNotification.Name("PostUpdated"), object: self)
    }
}
