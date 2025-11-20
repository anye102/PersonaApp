//
//  Post.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/20.
//

import Foundation
internal import Combine

// 动态数据模型
class Post: Identifiable, ObservableObject {
    // MARK： - 基本属性
    let id = UUID()
    var personaId: UUID
    var content: String
    var timestamp: Date
    
    // MARK: - 点赞相关属性
    @Published var likeCount: Int = 0
    @Published var isLiked: Bool = false
    
    // MARK: - 收藏相关属性
    @Published var markCount: Int = 0
    @Published var isMarked: Bool = false
    
    // MARK: - 构造函数
    
    init(persona: Persona, content: String, timestamp: Date) {
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
}
