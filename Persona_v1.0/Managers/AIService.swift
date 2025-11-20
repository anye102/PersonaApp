//
//  AIService.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/27.
//

import Foundation
internal import Combine

class AIService: ObservableObject {
    static let shared = AIService()
    
    private init() {}
    
    // 存储Combine订阅
    private var cancellables = Set<AnyCancellable>()
    
    private var completeResponse: [UUID: String] = [:]
        
    // 当前AI配置
    @Published var config: AIConfig = AIConfig.load()
    
    // 保存配置
    func saveConfig() {
        config.save()
    }
    
    // 生成AI回复（非流式）
    func generateResponse(persona: Persona, messages: [Message], completion: @escaping (Result<String, Error>) -> Void) {
        processAIRequest(persona: persona, messages: messages) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 生成AI回复（流式）
    func generateStreamResponse(persona: Persona, messages: [Message], onTokenReceived: @escaping (String) -> Void, completion: @escaping (Result<String, Error>) -> Void) {
        processAIRequest(persona: persona, messages: messages, isStreaming: true, onTokenReceived: onTokenReceived) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 处理AI请求的公共方法
    private func processAIRequest(persona: Persona, messages: [Message], isStreaming: Bool = false, onTokenReceived: ((String) -> Void)? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        // 检查Persona是否为用户创建的
        let isUserCreated = PersonaManager.shared.isUserPersona(persona.id)
        
        // 如果是用户创建的Persona，使用配置的AI模型
        // 如果不是，使用mock
        let originalProvider = config.selectedProvider
        if !isUserCreated {
            config.selectedProvider = .mock
        }
        
        // 处理请求
        processAIRequestInternal(personaId: persona.id, persona: persona, messages: messages, isStreaming: isStreaming, onTokenReceived: onTokenReceived) { [weak self] result in
            guard let self = self else { return }
            
            // 恢复原始配置
            self.config.selectedProvider = originalProvider
            
            completion(result)
        }
    }
    
    // 处理AI请求的内部方法
    private func processAIRequestInternal(personaId: UUID, persona: Persona, messages: [Message], isStreaming: Bool = false, onTokenReceived: ((String) -> Void)? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        // 如果是模拟AI，直接返回模拟回复
        if config.selectedProvider == .mock {
            if let onTokenReceived = onTokenReceived {
                DispatchQueue.global().async {
                    let response = self.generateMockResponse(persona: persona, messages: messages)
                    var accumulatedText = ""
                    
                    for character in response {
                        accumulatedText += String(character)
                        DispatchQueue.main.async {
                            onTokenReceived(accumulatedText)
                        }
                        Thread.sleep(forTimeInterval: Double.random(in: 0.02...0.05))
                    }
                    
                    DispatchQueue.main.async {
                        completion(.success(accumulatedText))
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1...3)) {
                    let response = self.generateMockResponse(persona: persona, messages: messages)
                    completion(.success(response))
                }
            }
            return
        }
        
        // 检查API密钥是否为空
        guard !config.apiKey.isEmpty else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "AIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "API密钥不能为空"])))
            }
            return
        }
        
        // 转换为AI消息格式
        let aiMessages = convertToAIMessages(persona: persona, messages: messages)
        
        // 创建请求
        let request = AIChatRequest(model: config.model, messages: aiMessages)
        
        // 发送流式请求
//        if let onTokenReceived = onTokenReceived {
//            sendStreamRequest(personaId: persona.id, request: request, onTokenReceived: onTokenReceived, completion: completion)
//        } else {
//            sendRequest(personaId: personaId, request: request, completion: completion)
//        }
        sendStreamRequest(personaId: persona.id, request: request, onTokenReceived: onTokenReceived, completion: completion)
    }
    
    // 转换为AI消息格式
    private func convertToAIMessages(persona: Persona, messages: [Message]) -> [AIChatMessage] {
        var aiMessages: [AIChatMessage] = []
        
        // 添加系统提示（Persona的背景和性格）
        let systemPrompt = """
        你是\(persona.name)，\(persona.personality)。
        背景故事：\(persona.backstory)
        
        请根据以上设定，以\(persona.name)的身份与用户进行对话。
        """
        
        aiMessages.append(AIChatMessage(role: "user", content: systemPrompt))
        
        // 添加历史消息
        for message in messages {
            let role = message.isFromUser ? "user" : "assistant"
            aiMessages.append(AIChatMessage(role: role, content: message.content))
        }
        
        return aiMessages
    }
    
    // 发送请求
    private func sendRequest(personaId: UUID, request: AIChatRequest, completion: @escaping (Result<String, Error>) -> Void) {
        // 创建URLRequest
        do {
            let urlRequest = try createURLRequest(personaId: personaId, request: request, isStreaming: false)
            
            // 发送请求
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let data = data else {
                        completion(.failure(NSError(domain: "AIService", code: -3, userInfo: [NSLocalizedDescriptionKey: "没有收到数据"])))
                        return
                    }
                    
                    // 解析响应
                    self.parseResponse(personaId: personaId, data: data, completion: completion)
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
    
    // 发送流式请求
    private func sendStreamRequest(personaId: UUID, request: AIChatRequest, onTokenReceived: ((String) -> Void)? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        
        do {
            let urlRequest = try createURLRequest(personaId: personaId, request: request, isStreaming: true)
            
            // 使用URLSession的dataTaskPublisher处理流式响应
            URLSession.shared.dataTaskPublisher(for: urlRequest)
                .retry(1)
                .sink(receiveCompletion: { completionStatus in
                    DispatchQueue.main.async {
                        switch completionStatus {
                        case .finished:
                            // 流式响应处理完成，返回完整内容
                            let fullResponse = self.completeResponse[personaId] ?? ""
                            completion(.success(fullResponse))
                            // 清除保存的完整响应
                            self.completeResponse.removeValue(forKey: personaId)
                        case .failure(let error):
                            completion(.failure(error))
                            // 清除保存的完整响应
                            self.completeResponse.removeValue(forKey: personaId)
                        }
                    }
                }, receiveValue: { data, response in
                    // 检查HTTP响应状态码
                    if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                        let statusCode = httpResponse.statusCode
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: "AIService", code: -3, userInfo: [NSLocalizedDescriptionKey: "请求失败，状态码: \(statusCode)"])))
                        }
                        return
                    }
                    
                    // 解析流式响应
                    if let fullContent = self.parseStreamResponse(personaId: personaId, data: data, onTokenReceived: onTokenReceived) {
                        // 收到完整内容，则保存起来
                        DispatchQueue.main.async {
                            self.completeResponse[personaId] = fullContent
                        }
                    }
                })
                .store(in: &self.cancellables)
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
    // 创建URLRequest的公共方法
    private func createURLRequest(personaId: UUID, request: AIChatRequest, isStreaming: Bool) throws -> URLRequest {
        guard let url = URL(string: config.selectedProvider.baseURL) else {
            throw NSError(domain: "AIService", code: -2, userInfo: [NSLocalizedDescriptionKey: "无效的API URL"])
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 添加API密钥
        switch config.selectedProvider {
        case .mock:
            break
        case .coze:
            urlRequest.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
            
            // 如果有会话ID，添加到URL参数中
            if let conversationId = PersonaManager.shared.getConversationId(for: personaId) {
                if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                    urlComponents.queryItems = [URLQueryItem(name: "conversation_id", value: conversationId)]
                    if let newUrl = urlComponents.url {
                        urlRequest.url = newUrl
                    }
                }
            }
        }
        
        // 设置请求体
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        // 创建请求参数
        if config.selectedProvider == .coze {
            // Coze API的流式请求格式
            
            // 请求的消息
            var additionalMessages: [[String: String]] = []
            
            // 获取系统提示（第一条消息）
            let systemPrompt = request.messages.first { $0.role == "user" }
            
            // 检查是否已有会话ID
            let conversationId = PersonaManager.shared.getConversationId(for: personaId)
            
            // 如果是第一次请求且存在系统提示，则添加到请求中
            if let systemPrompt = systemPrompt {
                if conversationId == nil {
                    additionalMessages.append([
                        "role": systemPrompt.role,
                        "content": systemPrompt.content,
                        "content_type": "text"
                    ])
                }
            }
            
            // 从请求中提取用户消息（最后一条消息）
            let userMessage = request.messages.last { $0.role == "user" }
            
            if let userMessage = userMessage {
                additionalMessages.append([
                    "role": userMessage.role,
                    "content": userMessage.content,
                    "content_type": "text"
                ])
            }
            
            let cozeRequest = [
                "bot_id": config.model, // Coze使用model字段存储bot_id
                "user_id": "user_" + UUID().uuidString, // 生成唯一的用户ID
                "stream": true,
                "auto_save_history": true,
                "additional_messages": additionalMessages
            ] as [String: Any]
            
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: cozeRequest)
        } else {
            urlRequest.httpBody = try encoder.encode(request)
        }
        
        return urlRequest
    }
    
    // 解析响应的公共方法
    private func parseResponse(personaId: UUID, data: Data, completion: @escaping (Result<String, Error>) -> Void) {
        // 解析响应
        do {
            var responseText = ""
            
            switch self.config.selectedProvider {
            case .mock:
                break
            case .coze:
                // 解析Coze API响应
                let cozeResponse = try JSONDecoder().decode(CozeResponse.self, from: data)
                responseText = cozeResponse.data.content
                
                // 保存会话ID
                PersonaManager.shared.saveConversationId(for: personaId, conversationId: cozeResponse.data.conversation_id)
            }
            
            completion(.success(responseText))
        } catch {
            // 尝试解析错误信息
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let errorMessage = json["error"] as? [String: Any],
               let message = errorMessage["message"] as? String {
                completion(.failure(NSError(domain: "AIService", code: -5, userInfo: [NSLocalizedDescriptionKey: message])))
            } else {
                completion(.failure(error))
            }
        }
    }
    
    // 解析流式响应
    private func parseStreamResponse(personaId: UUID, data: Data, onTokenReceived: ((String) -> Void)? = nil) -> String? {
        // 完整的内容
        var fullContent: String? = nil
        
        guard let responseString = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        // 分割响应字符串
        let lines = responseString.components(separatedBy: "\n")
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 跳过空行
            if trimmedLine.isEmpty {
                continue
            }
            
            // 检查是否是数据行
            if trimmedLine.starts(with: "data:") {
                let jsonString = String(trimmedLine.dropFirst(5))
                
                // 检查是否是结束标记
                if jsonString == "\"[DONE]\"" {
                    return fullContent
                }
                
                // 解析JSON
                if let jsonData = jsonString.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: jsonData, options: []),
                   let jsonDict = json as? [String: Any] {
                    
                    // 处理不同提供商的响应格式
                    switch config.selectedProvider {
                    case .coze:
                        // 解析Coze格式的响应
                        // 1. 处理会话状态更新响应 (created, in_progress, completed)
                        if jsonDict["status"] is String {
                            // 保存会话ID（在第一次响应中获取）
                            if let conversationId = jsonDict["conversation_id"] as? String {
                                PersonaManager.shared.saveConversationId(for: personaId, conversationId: conversationId)
                            }
                            
                            // 跳过状态更新响应，不处理内容
                            continue
                        }
                        
                        // 2. 处理内容响应
                        if let type = jsonDict["type"] as? String {
                            switch type {
                            case "answer":
                                // 处理回答内容
                                if let content = jsonDict["content"] as? String, !content.isEmpty {
                                    // 检查是否包含完整内容响应的表示
                                    let hasTimeCost = jsonDict["time_cost"] != nil
                                    let hasCreatedAt = jsonDict["created_at"] != nil
                                    if hasTimeCost && hasCreatedAt {
                                        fullContent = content
                                    } else if let onTokenReceived = onTokenReceived {
                                        DispatchQueue.main.async {
                                            onTokenReceived(content)
                                        }
                                        Thread.sleep(forTimeInterval: Double.random(in: 0.02...0.05))
                                    }
                                }
                                
                            case "verbose", "follow_up":
                                // 跳过verbose（完成通知）和follow_up（推荐问题）响应
                                continue
                                
                            default:
                                // 忽略其他类型的响应
                                break
                            }
                        }
                    case .mock:
                        break
                    }
                }
            }
        }
        
        return nil
    }
    
    // 生成内容（用于动态发布等）
    func generateContent(persona: Persona, prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        // 构建消息
        let messages = [
            Message(
                id: UUID(),
                senderId: UUID(),
                senderName: "zk",
                content: prompt,
                isFromUser: true,
                timestamp: Date()
            )
        ]
        
        processAIRequest(persona: persona, messages: messages, isStreaming: true) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 生成模拟回复
    private func generateMockResponse(persona: Persona, messages: [Message]) -> String {
        let responses = [
            "这是个很有趣的想法！我认为我们可以从多个角度来思考这个问题...",
            "根据我的理解，你是想了解更多关于这方面的信息，对吗？",
            "作为\(persona.personality)，我觉得这个话题非常有价值...",
            "我很赞同你的观点。此外，我还想补充一点...",
            "这让我想起了我的背景故事中的一个经历...",
            "从\(persona.personality)的角度来看，我会这样处理...",
            "你的问题很有深度，让我思考一下...",
            "我认为这个问题可以从不同的维度来分析...",
            "作为\(persona.name)，我对此有一些独特的见解..."
        ]
        
        return responses.randomElement()! + "\n\n（这是模拟的AI回复，在设置中配置真实AI API后可以获得真实回复）"
    }
    
    // 生成模拟内容（用于动态发布等）
    private func generateMockContent(persona: Persona, prompt: String) -> String {
        let contents = [
            "今天天气真好，适合出门散步！🌞 #生活 #日常",
            "刚刚完成了一个新项目，感觉很有成就感！💪 #工作 #成就感",
            "分享一首最近很喜欢的歌曲，希望大家也能喜欢！🎵 #音乐 #分享",
            "和朋友们一起度过了愉快的周末，这样的时光总是很珍贵！👭 #友情 #周末",
            "思考了一个问题：\(persona.personality)的人如何看待生活中的挑战？🤔 #思考 #人生",
            "推荐一本好书，最近正在读《\(persona.name)的冒险》，很有意思！📖 #阅读 #推荐",
        ]
        
        // 如果有特定要求，尝试根据要求生成
        if prompt.contains("故事") {
            return "今天想和大家分享一个小故事：从前有一只勇敢的小鸟，它克服了重重困难终于实现了自己的梦想。这个故事告诉我们，只要坚持就没有什么不可能！✨ #故事 #励志"
        } else if prompt.contains("看法") || prompt.contains("观点") {
            return "对于\"\(prompt.components(separatedBy: "：").last ?? "生活")\"这个话题，我认为最重要的是保持积极的心态和开放的思维。每个人都有自己的看法，尊重差异才能更好地理解世界！🤝 #观点 #思考"
        }
        
        return contents.randomElement()!
    }
}
