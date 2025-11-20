//
//  Persona.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/20.
//

import Foundation
internal import Combine

// Persona数据模型
class Persona: Identifiable, ObservableObject, Hashable {
    
    let id: UUID
    var name: String
    var avatar: String
    var personality: String
    var backstory: String
    @Published var isFollowed: Bool = false
    
    init(
        id: UUID = UUID(),
        name: String,
        avatar: String,
        personality: String,
        backstory: String = "nil"
    ) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.personality = personality
        self.backstory = backstory
    }
    
    // MARK: - Hashable
        
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Persona, rhs: Persona) -> Bool {
        return lhs.id == rhs.id
    }
}
