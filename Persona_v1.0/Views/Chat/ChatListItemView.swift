//
//  ChatListItemView.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/26.
//
import SwiftUI

// 聊天列表项视图
struct ChatListItemView: View {
    let persona: Persona
    @EnvironmentObject var personaManager: PersonaManager
    
    var body: some View {
        HStack(spacing: 12) {
            // 头像
            loadAvatar(imageName: persona.avatar)
            
            // 中间部分：名称和最后一条消息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(persona.name)
                        .font(.headline)
                        .lineLimit(1)
                }
                
                Text(lastMessageText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // 右侧：时间
            Spacer()
            
            Text(lastMessageTime)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
    
    // 获取最后一条消息的文本
    private var lastMessageText: String {
        let chatHistory = personaManager.getChatHistory(for: persona.id)
        
        if chatHistory.isEmpty {
            return personaManager.getUserPersonas().contains(where: { $0.id == persona.id }) ?
                "我的专属AI助手" : persona.personality
        }
        
        // 按时间排序，获取最后一条消息
        let sortedMessages = chatHistory.sorted(by: { $0.timestamp < $1.timestamp })
        if let lastMessage = sortedMessages.last {
            return lastMessage.content
        }
        
        return ""
    }
    
    // 获取最后一条消息的时间
    private var lastMessageTime: String {
        let chatHistory = personaManager.getChatHistory(for: persona.id)
        
        if chatHistory.isEmpty {
            return ""
        }
        
        // 按时间排序，获取最后一条消息
        let sortedMessages = chatHistory.sorted(by: { $0.timestamp < $1.timestamp })
        if let lastMessage = sortedMessages.last {
            let formatter = DateFormatter()
            
            // 如果是今天，显示小时和分钟
            if Calendar.current.isDateInToday(lastMessage.timestamp) {
                formatter.dateFormat = "HH:mm"
            }
            // 否则显示年、月、日
            else {
                formatter.dateFormat = "yyyy-MM-dd"
            }
            
            return formatter.string(from: lastMessage.timestamp)
        }
        
        return ""
    }
}
