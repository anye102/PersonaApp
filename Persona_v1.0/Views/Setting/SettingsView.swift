//
//  SettingsView.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/26.
//
import SwiftUI

// 设置视图
struct SettingsView: View {
    @EnvironmentObject var personaManager: PersonaManager
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var aiService = AIService.shared
    @ObservedObject private var userManager = UserManager.shared
    
    // AI信息编辑状态
    @State private var showingProviderConfigSheet = false
    @State private var selectedProviderForConfig: AIProvider?
    @State private var apiKeyInput = ""
    @State private var modelInput = ""
    
    // 用户信息编辑状态
    @State private var isEditingUserInfo = false
    @State private var selectedAvatarName: String?
    @State private var showingAvatarPicker = false
    
    // 退出登录确认
    @State private var showingLogoutConfirmation = false
    
    var body: some View {
        List {
            // 用户信息部分
            if userManager.isLoggedIn {
                Section("个人信息") {
                    if isEditingUserInfo {
                        // 编辑模式
                        VStack(alignment: .center, spacing: 20) {
                            // 头像
                            ZStack {
                                if let avatarName = selectedAvatarName {
                                    Image(avatarName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(50)
                                        .clipped()
                                } else if let userAvatar = userManager.currentUser?.avatar, !userAvatar.isEmpty {
                                    Image(userAvatar)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(50)
                                        .clipped()
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 100))
                                        .foregroundColor(.secondary)
                                }
                                
                                // 更换头像按钮
                                Button(action: {
                                    showingAvatarPicker = true
                                }) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.blue)
                                        .cornerRadius(15)
                                }
                                .offset(x: 30, y: 30)
                            }
                            
                            HStack(spacing: 20) {
                                Button("取消") {
                                    isEditingUserInfo = false
                                    resetEditFields()
                                }
                                .buttonStyle(.bordered)
                                
                                Button("保存") {
                                    saveUserInfo()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding(.vertical)
                    } else {
                        // 查看模式
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .center, spacing: 20) {
                                // 头像
                                if let userAvatar = userManager.currentUser?.avatar, !userAvatar.isEmpty {
                                    Image(userAvatar)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(30)
                                        .clipped()
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(userManager.currentUser?.username ?? "未知用户")
                                        .font(.headline)
                                    Text("@\(userManager.currentUser?.username ?? "unknown")")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: startEditingUserInfo) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            
            Section("AI设置") {
                // AI提供商选择
                Picker("当前AI提供商", selection: $aiService.config.selectedProvider) {
                    ForEach(AIProvider.allCases) { provider in
                        Text(provider.displayName)
                    }
                }
                .onChange(of: aiService.config.selectedProvider) { oldValue, newValue in
                    aiService.saveConfig()
                }
                
                // 提供商配置管理
                NavigationLink("管理提供商配置") {
                    ProviderConfigListView(aiConfig: $aiService.config)
                }
                
                // 当前提供商信息
                VStack(alignment: .leading, spacing: 8) {
                    Text("当前提供商: \(aiService.config.selectedProvider.displayName)")
                    Text("当前模型: \(aiService.config.model)")
                    Text("API密钥状态: \(aiService.config.apiKey.isEmpty ? "未设置" : "已设置")")
                }
                .foregroundColor(.secondary)

            }
//            Section("通用设置") {
//                Toggle("深色模式", isOn: .constant(false))
//                NavigationLink("通知设置", destination: Text("通知设置页面"))
//                NavigationLink("隐私设置", destination: Text("隐私设置页面"))
//            }
            
//            Section("数据管理") {
//                Button(action: {
//                    // 清除聊天记录
//                    if UserDefaults.standard.data(forKey: "chatHistory") != nil {
//                        UserDefaults.standard.removeObject(forKey: "chatHistory")
//                        personaManager.chatHistory.removeAll()
//                    }
//                }) {
//                    Text("清除聊天记录")
//                        .foregroundColor(.red)
//                }
//                
//                Button(action: {
//                    // 清除所有数据
//                    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
////                    personaManager.personas.removeAll()
//                    personaManager.posts.removeAll()
//                    personaManager.allPersonas.removeAll()
//                    personaManager.chatHistory.removeAll()
//                }) {
//                    Text("重置所有数据")
//                        .foregroundColor(.red)
//                }
//            }
            
            Section("关于") {
                Text("Persona v1.0")
                    .foregroundColor(.secondary)
                Text("© 2025 Persona团队")
                    .foregroundColor(.secondary)
            }
            
            // 退出登录按钮（仅登录状态）
            if userManager.isLoggedIn {
                Section {
                    Button(action: { showingLogoutConfirmation = true }) {
                        Text("退出登录")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAvatarPicker) {
            AssetImagePickerView(selectedImageName: $selectedAvatarName)
        }
        .confirmationDialog("确认退出登录?", isPresented: $showingLogoutConfirmation) {
            Button("退出登录", role: .destructive) {
                logout()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("退出登录后，你需要重新登录才能使用应用。")
        }
        .sheet(item: $selectedProviderForConfig) { provider in
            NavigationStack {
                ProviderConfigDetailView(
                    provider: provider,
                    config: Binding(
                        get: { aiService.config.providerConfigs[provider] ?? .defaultConfig(for: provider) },
                        set: { aiService.config.providerConfigs[provider] = $0 }
                    ),
                    onSave: { newConfig in
                        aiService.config.providerConfigs[provider] = newConfig
                        aiService.saveConfig()
                    }
                )
                .navigationTitle("\(provider.displayName)配置")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") {
                            selectedProviderForConfig = nil
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("保存") {
                            if let config = aiService.config.providerConfigs[provider] {
                                aiService.config.providerConfigs[provider] = config
                                aiService.saveConfig()
                            }
                            selectedProviderForConfig = nil
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - User Info Management
    
    // 开始编辑用户信息
    private func startEditingUserInfo() {
        selectedAvatarName = userManager.currentUser?.avatar
        isEditingUserInfo = true
    }
    
    // 重置编辑字段
    private func resetEditFields() {
        selectedAvatarName = nil
    }
    
    // 保存用户信息
    private func saveUserInfo() {
        userManager.updateUserInfo()
        
        // 如果选择了新头像
        if let avatarName = selectedAvatarName {
            userManager.updateAvatar(avatarName)
        }
        
        isEditingUserInfo = false
    }
    
    // 退出登录
    private func logout() {
        userManager.logout()
        
        // 返回登录界面
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(rootView: LaunchScreen())
        }
    }
}

// MARK: - AI提供商修改子视图

// 提供商配置列表视图
struct ProviderConfigListView: View {
    @Binding var aiConfig: AIConfig
    @State private var selectedProvider: AIProvider?
    
    var body: some View {
        List {
            ForEach(AIProvider.allCases) { provider in
                NavigationLink {
                    ProviderConfigDetailView(
                        provider: provider,
                        config: Binding(
                            get: { aiConfig.providerConfigs[provider] ?? .defaultConfig(for: provider) },
                            set: { aiConfig.providerConfigs[provider] = $0 }
                        ),
                        onSave: { newConfig in
                            aiConfig.providerConfigs[provider] = newConfig
                            aiConfig.save()
                        }
                    )
                } label: {
                    ProviderConfigRowView(
                        provider: provider,
                        config: aiConfig.providerConfigs[provider] ?? ProviderConfig.defaultConfig(for: provider),
                        isSelected: aiConfig.selectedProvider == provider
                    )
                }
            }
        }
        .navigationTitle("提供商配置")
    }
}

// 提供商配置行视图
struct ProviderConfigRowView: View {
    let provider: AIProvider
    let config: ProviderConfig
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(provider.displayName)
                    .font(.headline)
                Text("模型: \(config.model)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                if isSelected {
                    Text("当前使用")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                Text(config.apiKey.isEmpty ? "未设置API密钥" : "已设置API密钥")
                    .font(.caption)
                    .foregroundColor(config.apiKey.isEmpty ? .red : .green)
            }
        }
    }
}

// 提供商配置详情视图
struct ProviderConfigDetailView: View {
    let provider: AIProvider
    @Binding var config: ProviderConfig
    let onSave: (ProviderConfig) -> Void
    
    var body: some View {
        List {
            Section("API设置") {
                // API密钥
                SecureField("API密钥", text: $config.apiKey)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                
                // 模型
                TextField("模型名称", text: $config.model)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                
                // 默认模型提示
                Text("默认模型: \(ProviderConfig.defaultConfig(for: provider).model)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("API信息") {
                Text("API地址: \(provider.baseURL)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("\(provider.displayName)配置")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    onSave(config)
                }
            }
        }
    }
}
