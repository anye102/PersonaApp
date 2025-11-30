//
//  ChatView.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/20.
//

import SwiftUI

//MARK: - 聊天视图
struct PersonaChatView: View {
    @EnvironmentObject var personaManager: PersonaManager
    var persona: Persona
    @State private var messageText = ""
    @State private var messages: [Message] = []
    @State private var isThinking = false
    @ObservedObject private var aiService = AIService.shared
    
    // 用于流式输出
    @State private var streamingMessageId: UUID?
    @State private var streamingContent = ""
    
    private let scrollToBottomId = UUID()
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    loadAvatar(imageName: persona.avatar)
                    Text(persona.name)
                }
                .padding(.vertical)

                
                // 消息列表
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .environmentObject(personaManager)
                            }
                            
                            // 用于自动滚动的锚点
                            Color.clear
                                .id(scrollToBottomId)
                        }
                        .padding(.top)
                    }
                    .onChange(of: messages) {
                        scrollToBottom(proxy: proxy)
                    }
                }
                    
                // 输入区域
                HStack {
                    TextField("输入消息...", text: $messageText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...3)
                        .disabled(isThinking)
                    
                    Button(action: sendMessage) {
    //                    Text("发送")
    //                        .padding(.horizontal, 16)
    //                        .padding(.vertical, 8)
    //                        .background(Color.blue)
    //                        .foregroundColor(.white)
    //                        .cornerRadius(8)
                        Image(systemName: "paperplane.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    .disabled(messageText.isEmpty || isThinking)
                }
                .padding()
            }
    //        .navigationTitle(persona.name)
    //        .navigationBarTitleDisplayMode(.large)
            .onAppear {
                messages = personaManager.getChatHistory(for: persona.id)
                if messages.isEmpty {
                    // 模拟初始消息
                    let initMessage = Message(
                            id: UUID(),
                            senderId: persona.id,
                            senderName: persona.name,
                            content: "你好！我是\(persona.name)。很高兴与你聊天",
                            isFromUser: false,
                            timestamp: Date()
                        )
                    messages.append(initMessage)
                    personaManager.saveChatMessages(personaId: persona.id, message: initMessage)
                }
            }
        }
    }
    
    private func sendMessage() {
        if !messageText.isEmpty {
            // 添加用户消息
            let userMessage = Message(
                id: UUID(),
                senderId: UUID(),
                senderName: "zk",
                content: messageText,
                isFromUser: true,
                timestamp: Date()
            )
            messages.append(userMessage)
            personaManager.saveChatMessages(personaId: persona.id, message: userMessage)
            
            // 清空输入框
            messageText = ""
            
            // AI思考中
            isThinking = true
            
            // 创建流式消息ID
            let streamingId = UUID()
            streamingMessageId = streamingId
            streamingContent = ""
            
            // 使用AI服务获取流式回复
            aiService.generateStreamResponse(
                persona: persona,
                messages: messages,
                onTokenReceived: { [self] token in
                    
                    DispatchQueue.main.async {
                        // 检查是否是当前流式消息
                        if self.streamingMessageId == streamingId {
                            
                            let selectedProvider = self.aiService.config.selectedProvider
                            if selectedProvider != .mock {
                                self.streamingContent += token
                            } else {
                                self.streamingContent = token
                            }
                            
                            // 更新消息列表
                            if let index = self.messages.firstIndex(where: { $0.id == streamingId }) {
                                self.messages[index].content = self.streamingContent
                            } else {
                                // 创建新的流式消息
                                let streamingMessage = Message(
                                    id: streamingId,
                                    senderId: self.persona.id,
                                    senderName: self.persona.name,
                                    content: self.streamingContent,
                                    isFromUser: false,
                                    timestamp: Date()
                                )
                                self.messages.append(streamingMessage)
                            }
                        }
                    }
                },
                completion: { [self] result in
                    
                    DispatchQueue.main.async {
                        self.isThinking = false
                        
                        switch result {
                        case .success(let fullResponse):
                            // 检查是否是当前流式消息
                            if self.streamingMessageId == streamingId {
                                // 更新为完整消息
                                if let index = self.messages.firstIndex(where: { $0.id == streamingId }) {
                                    self.messages[index].content = fullResponse
                                    // 保存完整消息到历史记录
                                    personaManager.saveChatMessages(personaId: persona.id, message: self.messages[index])
                                }
                                
                                // 重置流式状态
                                self.streamingMessageId = nil
                                self.streamingContent = ""
                            }
                            
                        case .failure(let error):
                            // 显示错误消息
                            let errorMessage = Message(
                                id: UUID(),
                                senderId: self.persona.id,
                                senderName: self.persona.name,
                                content: "抱歉，无法获取回复：\(error.localizedDescription)",
                                isFromUser: false,
                                timestamp: Date()
                            )
                            
                            self.messages.append(errorMessage)
                            
                            // 重置流式状态
                            self.streamingMessageId = nil
                            self.streamingContent = ""
                        }
                    }
                }
            )
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                proxy.scrollTo(scrollToBottomId, anchor: .bottom)
            }
        }
    }
    
}

struct PrePersonaChatView: PreviewProvider {
    static var previews: some View {
        if let persona = PersonaManager.shared.getPersonas().first {
            PersonaChatView(persona: persona)
                .environmentObject(PersonaManager.shared)
        }
    }
}
