//
//  Message.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/20.
//

import Foundation

//MARK: - 消息模型
struct Message: Identifiable, Equatable, Codable {
    let id: UUID
    let senderId: UUID
    let senderName: String
    var content: String
    let isFromUser: Bool
    let timestamp: Date
}
