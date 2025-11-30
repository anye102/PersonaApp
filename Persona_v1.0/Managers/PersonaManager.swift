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
        // 从本地加载所有数据
        loadAllPersonas()
        loadConversationIdsFromLocalStorage()
        loadPostsFromLocalStorage()
        // 从本地加载聊天记录
        loadChatHistoryFromLocalStorage()
        
        // 添加通知观察者，监听Post更新
        NotificationCenter.default.addObserver(self, selector: #selector(postUpdated(_:)), name: NSNotification.Name("PostUpdated"), object: nil)
    }
    
    
    @Published var allPersonas: [Persona] = []
    
    @Published var posts: [Post] = []
    @Published var selectedPersona: Persona?
    
    @Published var chatHistory: [String : [Message]] = [:]
    
    @Published var conversationIds: [String: String] = [:]
    
    // 计算自己创建的personas
    var userPersonas: [Persona] {
        guard let currentUserId = UserManager.shared.currentUser?.id else {
            return []
        }
        return allPersonas.filter { $0.userId == currentUserId }
    }
    
    // 计算属性：当前用户可见的Persona（自己创建的 + 关注的）
    var visiblePersonas: [Persona] {
        guard let currentUserId = UserManager.shared.currentUser?.id else {
            return []
        }
        // 自己创建的Persona + 关注的Persona
        return allPersonas.filter { $0.userId == currentUserId || $0.isFollowedByCurrentUser() }
    }
    
    // 获取post对应的persona
    func getPersona(for post: Post) -> Persona? {
        return allPersonas.first { $0.id == post.personaId }
    }
    
    func getPersonas() -> [Persona] {
        return allPersonas
    }
    
    func getUserPersonas() -> [Persona] {
        return userPersonas
    }
    
    func getPersonaById(for id: UUID) -> Persona? {
        return allPersonas.first {
            $0.id == id
        }
    }
    
    // 删除指定id的userPersona
    func deleteUserPersona(_ id : UUID) {
        
        // 检查是否是当前用户创建的Persona
        guard self.isUserPersona(id) else {
            return
        }
        
        // 从allPersonas数组中删除
        if let index = allPersonas.firstIndex(where: { $0.id == id }) {
            allPersonas.remove(at: index)
            
            // 保存到本地存储
            self.saveAllPersonasToLocalStorage()
        }
    }
    
    // 获取所有已关注的personas
    func getFollowedPersonas() -> [Persona] {
        guard let currentUserId = UserManager.shared.currentUser?.id else {
            return []
        }
        return allPersonas.filter { $0.isFollowedByCurrentUser() && $0.userId != currentUserId }
    }
    
    // 关注功能
    func followPersona(_ personaId: UUID) {
        guard (UserManager.shared.currentUser?.id) != nil else {
            return
        }
        
        if let index = allPersonas.firstIndex(where: { $0.id == personaId }) {
            let persona = allPersonas[index]
            let isCurrentlyFollowed = persona.isFollowedByCurrentUser()
            persona.setFollowedByCurrentUser(!isCurrentlyFollowed)
            
            // 手动触发objectWillChange，通知视图更新
            objectWillChange.send()
            // 保存到本地存储
            saveAllPersonasToLocalStorage()
        }
    }
    
    func createPersona(_ persona: Persona) {
        allPersonas.append(persona)
        let post = Post(persona: persona, content: "我刚刚加入Persona世界！", timestamp: Date())
        posts.append(post)
    }
    
    func addPost(_ post: Post){
        posts.insert(post, at: 0)
    }
    
    // 判断persona是否为userPersona
    func isUserPersona(_ personaId: UUID) -> Bool {
        guard let currentUserId = UserManager.shared.currentUser?.id else {
            return false
        }
        if let persona = getPersonaById(for: personaId) {
            return persona.userId == currentUserId
        } else {
            return false
        }
        
    }
    
    // 从本地存储加载所有Persona
    private func loadAllPersonas() {
        if let data = UserDefaults.standard.data(forKey: "allPersonas"),
           let decodedPersonas = try? JSONDecoder().decode([Persona].self, from: data) {
            allPersonas = decodedPersonas
        } else {
            // 如果没有本地数据，加载示例数据
            loadSamplePersonas()
        }
    }
    
    // 保存所有Persona到本地存储
    private func saveAllPersonasToLocalStorage() {
        if let encodedData = try? JSONEncoder().encode(allPersonas) {
            UserDefaults.standard.set(encodedData, forKey: "allPersonas")
        }
    }
    
    // 保存聊天消息
    func saveChatMessages(personaId: UUID, message: Message) {
        guard let currentUserId = UserManager.shared.currentUser?.id else {
            return
        }
        let key = "\(currentUserId)_\(personaId)"
        if chatHistory[key] == nil {
            chatHistory[key] = []
        }
        chatHistory[key]?.append(message)
        
        // 保存聊天记录到本地
        saveChatHistoryToLocalStorage()
    }
    
    // 获取聊天记录
    func getChatHistory(for personaId: UUID) -> [Message] {
        guard let currentUserId = UserManager.shared.currentUser?.id else {
            return []
        }
        
        let key = "\(currentUserId)_\(personaId)"
        return chatHistory[key] ?? []
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
           let decodedChatHistory = try? JSONDecoder().decode([String: [Message]].self, from: data) {
            chatHistory = decodedChatHistory
        }
    }
    
    // 添加自创的userPersona
    func addUserPersona(_ userPersona: Persona, completion: @escaping (Result<Void, Error>) -> Void) {
        allPersonas.append(userPersona)
        
        // 保存到本地存储
        saveAllPersonasToLocalStorage()
        
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
        // 保存到本地存储
        savePostsToLocalStorage()
    }
    
    // 从本地存储加载动态
    func loadPostsFromLocalStorage() {
        if let data = UserDefaults.standard.data(forKey: "posts"),
           let decodedPosts = try? JSONDecoder().decode([Post].self, from: data) {
            posts = decodedPosts
        } else {
            // 随机生成一些动态
            generateMockPosts()
        }
    }
    
    // 保存动态到本地存储
    func savePostsToLocalStorage() {
        if let encodedData = try? JSONEncoder().encode(posts) {
            UserDefaults.standard.set(encodedData, forKey: "posts")
        }
    }
    // 处理Post更新通知
    @objc private func postUpdated(_ notification: Notification) {
        if let updatedPost = notification.object as? Post {
            // 更新posts数组中的对应Post
            if let index = posts.firstIndex(where: { $0.id == updatedPost.id }) {
                posts[index] = updatedPost
                // 保存到本地存储
                savePostsToLocalStorage()
            }
        }
    }
    
    // 获取Persona的会话ID
    func getConversationId(for personaId: UUID) -> String? {
        guard let currentUserId = UserManager.shared.currentUser?.id else {
            return nil
        }
        
        let key = "\(currentUserId)_\(personaId)"
        return conversationIds[key]
    }
    
    // 保存Persona的会话ID
    func saveConversationId(for personaId: UUID, conversationId: String) {
        guard let currentUserId = UserManager.shared.currentUser?.id else {
            return
        }
        
        let key = "\(currentUserId)_\(personaId)"
        conversationIds[key] = conversationId
        
        // 保存到本地存储
        saveConversationIdsToLocalStorage()
    }
    
    // 从本地存储加载会话ID
    func loadConversationIdsFromLocalStorage() {
        if let data = UserDefaults.standard.data(forKey: "conversationIds"),
           let decodedConversationIds = try? JSONDecoder().decode([String: String].self, from: data) {
            conversationIds = decodedConversationIds
        }
    }
    
    // 保存会话ID到本地存储
    func saveConversationIdsToLocalStorage() {
        if let encodedData = try? JSONEncoder().encode(conversationIds) {
            UserDefaults.standard.set(encodedData, forKey: "conversationIds")
        }
    }
    
    private func loadSamplePersonas() {
        allPersonas = [
            Persona(name: "皮卡丘",
                    avatar: "皮卡丘",
                    personality: "友好、乐于助人",
                    backstory: "一个乐于解答问题的AI助手",
                    userId: UUID()
                   ),
            Persona(name: "数字艺术家",
                    avatar: "酒馆",
                    personality: "创意、感性",
                    backstory: "热爱创作的数字艺术家",
                    userId: UUID()
                   ),
            Persona(name: "未来探索者",
                    avatar: "摆烂表情包",
                    personality: "好奇、冒险",
                    backstory: "对未知世界充满好奇的探索者",
                    userId: UUID()
                   )
        ]
        
        // 保存示例数据到本地存储
        saveAllPersonasToLocalStorage()
    }
    
    private func generateMockPosts() {
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
        
        for _ in 0..<20 { // 生成20条额外动态
            let randomPersona = allPersonas.randomElement()!
            let randomContent = contents.randomElement()!
            let randomLikes = Int.random(in: 0...100)
            let randomMarks = Int.random(in: 0...100)
            
            let post = Post(persona: randomPersona, content: randomContent, timestamp: Date())
            post.likeCount = randomLikes
            post.markCount = randomMarks
            
            // 随机设置一些点赞数
            post.likeCount = Int.random(in: 0...100)
            
            // 随机设置一些收藏数
            post.markCount = Int.random(in: 0...100)
            
            posts.append(post)
            savePostsToLocalStorage()
        }
    }
}
