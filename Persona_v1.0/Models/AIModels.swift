//
//  AIModels.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/27.
//

import Foundation

// 单个AI提供商的配置
struct ProviderConfig: Codable {
    var apiKey: String
    var model: String
    
    // 默认配置
    static func defaultConfig(for provider: AIProvider) -> ProviderConfig {
        switch provider {
        case .mock:
            return ProviderConfig(apiKey: "", model: "mock-model")
        case .coze:
            return ProviderConfig(
                apiKey: "pat_TWi1IxFBe5YzkLobzVz9l6BE7zQCWhTVIeXUfhdq1GEFRLlt342Z8QTe88C8UuNo",
                model: "7577019283109101620"
            )
        }
    }
}

// AI API配置模型
struct AIConfig: Codable {
    var selectedProvider: AIProvider // 默认使用模拟AI
    var providerConfigs: [AIProvider: ProviderConfig]
    
    // 当前选中的provider配置
    var currentConfig: ProviderConfig {
        get {
            providerConfigs[selectedProvider] ?? ProviderConfig.defaultConfig(for: selectedProvider)
        }
        set {
            providerConfigs[selectedProvider] = newValue
        }
    }
    
    // 当前选中的API Key
    var apiKey: String {
        get {
            currentConfig.apiKey
        }
        set {
            currentConfig.apiKey = newValue
        }
    }
    
    // 当前选中的模型
    var model: String {
        get {
            currentConfig.model
        }
        set {
            currentConfig.model = newValue
        }
    }
    
    // 初始化
    init() {
        self.selectedProvider = .mock
        self.providerConfigs = [:]
        
        // 为所有provider设置默认配置
        for provider in AIProvider.allCases {
            self.providerConfigs[provider] = ProviderConfig.defaultConfig(for: provider)
        }
    }
    
    // 保存到本地存储
    func save() {
        if let encodedData = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encodedData, forKey: "AIConfig")
        }
    }
    
    // 从本地存储加载
    static func load() -> AIConfig {
        if let data = UserDefaults.standard.data(forKey: "AIConfig"),
           let decodedConfig = try? JSONDecoder().decode(AIConfig.self, from: data) {
            return decodedConfig
        }
        return AIConfig()
    }
}

// AI服务提供商枚举
enum AIProvider: String, Codable, CaseIterable, Identifiable {
    case mock
    case coze
    
    var id: Self { self }
    
    // 获取默认模型
    var displayName: String {
        switch self {
        case .mock: return "模拟AI"
        case .coze: return "Coze"
        }
    }
    
    // 获取API基础URL
    var baseURL: String {
        switch self {
        case .mock: return ""
        case .coze: return "https://api.coze.cn/v3/chat"
        }
    }
}


// AI消息模型
struct AIChatMessage: Codable {
    let role: String
    let content: String
}

// AI消息请求模型
struct AIChatRequest: Codable {
    let model: String
    let messages: [AIChatMessage]
}

// AI响应模型
struct AIResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [AIResponseChoice]
}

struct AIResponseChoice: Codable {
    let message: AIChatMessage
    let finish_reason: String
    let index: Int
}

// Coze响应模型
struct CozeResponse: Codable {
    let code: Int
    let msg: String
    let data: CozeData
}

// Coze数据模型
struct CozeData: Codable {
    let id: String
    let conversation_id: String
    let created_at: Int
    let content: String
    let role: String
    let content_type: String
}
