//
//  User.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/30.
//

import Foundation

// 用户模型
struct User: Codable, Identifiable {
    let id: UUID
    var username: String
    var password: String
    var avatar: String?
    
    // 初始化
    init(id: UUID = UUID(), username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
}
