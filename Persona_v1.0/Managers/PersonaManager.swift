//
//  PersonaManager.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/20.
//

import Foundation
internal import Combine
import SwiftUI
/**
 /Users/zoukun/工作/swift/Persona_v1.0/Persona_v1.0/res/Images
 */
// MARK: - Persona管理器
class PersonaManager: ObservableObject {
    
    static let shared = PersonaManager()
    
    private init() {
        // 从本地加载聊天记录
        loadChatHistoryFromLocalStorage()
        // 随机生成一些动态
        generateMockPosts()
    }
    
    
    @Published private var personas: [Persona] = [
        Persona(name: "皮卡丘",
                avatar: "皮卡丘",
                personality: "友好、乐于助人",
                backstory: "一个乐于解答问题的AI助手"
               ),
        Persona(name: "数字艺术家",
                avatar: "酒馆",
                personality: "创意、感性",
                backstory: "热爱创作的数字艺术家"
               ),
        Persona(name: "未来探索者",
                avatar: "摆烂表情包",
                personality: "好奇、冒险",
                backstory: "对未知世界充满好奇的探索者"
               )
    ]
    
    @Published var posts: [Post] = []
    @Published var selectedPersona: Persona?
    
    let contents = [
        "今天学习了SwiftUI的动画效果，真的很强大！",
        "分享一个实用的开发技巧：如何优化列表性能",
        "参加了苹果开发者大会，收获满满",
        "新的iOS版本发布了，大家更新了吗？",
        "推荐一本关于Swift编程的好书",
        "今天天气不错，适合户外活动！",
        "分享一张我拍的风景照 #摄影 #旅行",
        "刚刚完成了一个新项目，很有成就感",
        "大家最喜欢的SwiftUI组件是什么？",
        "学习编程的第100天，继续加油！"
    ]
    
    @Published var chatHistory: [UUID : [Message]] = [:]
    
    @Published var userPersonas: [Persona] = [
        Persona(name: "momo",
                avatar: "动漫",
                personality: "友好、乐于助人",
                backstory: "一个乐于解答问题的AI助手"
               )
    ]
    
    @Published var conversationIds: [UUID: String] = [:] // 新增：存储每个Persona的会话ID

    private func generateMockPosts() {
        // 随机设置一些已关注
        for index in personas.indices {
            personas[index].isFollowed = Bool.random()
        }
        
        for _ in 0..<20 { // 生成20条额外动态
            let randomPersona = personas.randomElement()!
            let randomContent = contents.randomElement()!
            let randomLikes = Int.random(in: 0...100)
            let randomMarks = Int.random(in: 0...100)
            
            let post = Post(persona: randomPersona, content: randomContent, timestamp: Date())
            post.likeCount = randomLikes
            post.markCount = randomMarks
            
            // 随机设置一些已点赞
            if Bool.random() {
                post.isLiked = true
            }
            
            // 随机设置一些已收藏
            if Bool.random() {
                post.isMarked = true
            }
            
            posts.append(post)
        }
        
        for userPersona in userPersonas {
            userPersona.isFollowed = true
            personas.append(userPersona)
        }
    }
    
    // 获取post对应的persona
    func getPersona(for post: Post) -> Persona? {
        return personas.first { $0.id == post.personaId }
    }
    
    func getPersonas() -> [Persona] {
        return personas
    }
    
    func getUserPersonas() -> [Persona] {
        return userPersonas
    }
    
    func getPersonaById(for id: UUID) -> Persona? {
        return personas.first {
            $0.id == id
        }
    }
    
    // 删除指定id的userPersona
    func deleteUserPersona(_ id : UUID) {
        if let index = userPersonas.firstIndex(where: { $0.id == id }) {
            userPersonas.remove(at: index)
        }
        
        // 从personas数组中删除
        if let index = personas.firstIndex(where: { $0.id == id }) {
            personas.remove(at: index)
        }
    }
    
    // 获取所有已关注的personas
    func getFollowedPersonas() -> [Persona] {
        let followedPersonas = personas.filter { $0.isFollowed }
        // 过滤掉自己创建的Persona
        let userPersonaIds = Set(userPersonas.map { $0.id })
        return followedPersonas.filter { !userPersonaIds.contains($0.id) }
    }
    
    // 关注功能
    func followPersona(_ personaId: UUID) {
        if let index = personas.firstIndex(where: { $0.id == personaId }) {
            personas[index].isFollowed.toggle()
            objectWillChange.send()
        }
    }
    
    func createPersona(_ persona: Persona) {
        personas.append(persona)
        let post = Post(persona: persona, content: "我刚刚加入Persona世界！", timestamp: Date())
        posts.append(post)
    }
    
    func addPost(_ post: Post){
        posts.insert(post, at: 0)
    }
    
    // 判断persona是否为userPersona
    func isUserPersona(_ personaId: UUID) -> Bool {
        return userPersonas.contains { $0.id == personaId }
    }
    
    // 保存聊天消息
    func saveChatMessages(personaId: UUID, message: Message) {
        if chatHistory[personaId] == nil {
            chatHistory[personaId] = []
        }
        chatHistory[personaId]?.append(message)
        
        // 保存聊天记录到本地
        saveChatHistoryToLocalStorage()
    }
    
    // 获取聊天记录
    func getChatHistory(for personaId: UUID) -> [Message] {
        return chatHistory[personaId] ?? []
    }
    
    // 保存聊天记录到本地
    internal func saveChatHistoryToLocalStorage() {
        if let encodeData = try? JSONEncoder().encode(chatHistory) {
            UserDefaults.standard.set(encodeData, forKey: "chatHistory")
        }
    }
    
    // 从本地加载聊天记录
    func loadChatHistoryFromLocalStorage() {
        if let data = UserDefaults.standard.data(forKey: "chatHistory"),
           let decodedChatHistory = try? JSONDecoder().decode([UUID: [Message]].self, from: data) {
            chatHistory = decodedChatHistory
        }
    }
    
    // 添加自创的userPersona
    func addUserPersona(_ userPersona: Persona, completion: @escaping (Result<Void, Error>) -> Void) {
        userPersonas.append(userPersona)
        personas.append(userPersona)
        
        // 隐式发送system_prompt来初始化会话
        initializePersonaConversation(persona: userPersona, completion: completion)
    }
    
    // 隐式发送system_prompt来初始化会话
    private func initializePersonaConversation(persona: Persona, completion: @escaping (Result<Void, Error>) -> Void) {
        // 创建一个空的消息列表，只包含系统提示
        let messages: [Message] = []
        
        // 使用AIService生成响应，这将隐式发送system_prompt
        AIService.shared.generateResponse(persona: persona, messages: messages) { result in
            switch result {
            case .success(_):
                // 会话初始化成功，conversation_id已在AIService中存储
                completion(.success(()))
            case .failure(let error):
                // 会话初始化失败
                completion(.failure(error))
            }
        }
    }
    
    // 发布动态
    func createPost(persona: Persona, content: String) {
        let newPost = Post(persona: persona, content: content, timestamp: Date())
        posts.insert(newPost, at: 0)
    }
    
    // 新增：获取Persona的会话ID
    func getConversationId(for personaId: UUID) -> String? {
        return conversationIds[personaId]
    }
    
    // 新增：保存Persona的会话ID
    func saveConversationId(for personaId: UUID, conversationId: String) {
        conversationIds[personaId] = conversationId
        
        // 保存到本地存储
        saveConversationIdsToLocalStorage()
    }
    
    // 新增：从本地存储加载会话ID
    func loadConversationIdsFromLocalStorage() {
        if let data = UserDefaults.standard.data(forKey: "conversationIds"),
           let decodedConversationIds = try? JSONDecoder().decode([UUID: String].self, from: data) {
            conversationIds = decodedConversationIds
        }
    }
    
    // 新增：保存会话ID到本地存储
    func saveConversationIdsToLocalStorage() {
        if let encodedData = try? JSONEncoder().encode(conversationIds) {
            UserDefaults.standard.set(encodedData, forKey: "conversationIds")
        }
    }
}
