//
//  PersonaDetailView.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/25.
//

import SwiftUI

// Persona详情视图
struct PersonaDetailView: View {
    @ObservedObject var persona: Persona
    @EnvironmentObject var personaManager: PersonaManager
    @State private var showingChat = false
    @State private var showingCreatePost = false
    @State private var showingDeleteConfirmation = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 头像和基本信息
                    HStack(alignment: .top, spacing: 16) {
                        loadAvatar(imageName: persona.avatar)
                        VStack(alignment: .leading) {
                            Text(persona.name)
                                .font(.title)
                            Text(persona.personality)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        if !personaManager.getUserPersonas().contains(where: { $0.id == persona.id }) {
                            Button(action: {
                                personaManager.followPersona(persona.id)
                            }) {
                                Text(persona.isFollowed ? "已关注" : "关注")
                                    .font(.subheadline)
                                    .foregroundColor(persona.isFollowed ? .secondary : .white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(persona.isFollowed ? Color(.systemGray5) : Color.blue)
                                    .cornerRadius(8)
                            }
                        } else {
                            // 右侧发布动态按钮
                            Button(action: {
                                showingCreatePost = true
                            }) {
                                Text("写动态")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            .padding(.trailing)
                        }
                    }
                    
                    // 背景故事
                    Section("背景故事") {
                        Text(persona.backstory)
                            .font(.body)
                    }
                    
                    Spacer()
                }
                .padding()
                
                // 发布的动态
                Section("发布的动态") {
                    let personaPosts = personaManager.posts.filter { $0.personaId == persona.id }
                    
                    if personaPosts.isEmpty {
                        Text("暂无动态")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(personaPosts) { post in
                            PostRowView(
                                post: post,
                                showingChat: $showingChat,
                                selectedPost: .constant(nil)
                            )
                            .listRowInsets(EdgeInsets())
                        }
                    }
                }
                .padding()
            }
//            .navigationTitle(persona.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 只有自己创建的Persona才显示删除按钮
                if personaManager.getUserPersonas().contains(where: { $0.id == persona.id }) {
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                    }
                }
                
                Button(action: {
                    showingChat = true
                }) {
                    Image(systemName: "message.fill")
                        .foregroundStyle(.blue)
                }
            }
            .alert("确认删除", isPresented: $showingDeleteConfirmation) {
                Button("取消", role: .cancel) {}
                Button("删除", role: .destructive) {
                    deletePersona()
                }
            } message: {
                Text("确定要删除 \(persona.name) 吗？此操作无法撤销。")
            }
            .sheet(isPresented: $showingChat) {
                PersonaChatView(persona: persona)
                    .environmentObject(personaManager)
            }
            .sheet(isPresented: $showingCreatePost) {
                CreatePostView(selectedPersonaId: persona.id)
                    .environmentObject(personaManager)
            }
        }
    }
    
    // 删除Persona
    private func deletePersona() {
        // 从userPersonas和personas数组中删除
        personaManager.deleteUserPersona(persona.id)
        
        // 删除与该Persona相关的所有动态
        personaManager.posts.removeAll { $0.personaId == persona.id }
        
        // 删除与该Persona相关的聊天记录
        personaManager.chatHistory.removeValue(forKey: persona.id)
        
        // 保存聊天记录到本地存储
        personaManager.saveChatHistoryToLocalStorage()
        
        // 返回上一级页面
        dismiss()
    }
}

struct PrePersonaDetailedView: PreviewProvider {
    static var previews: some View {
        if let persona = PersonaManager.shared.getUserPersonas().first {
            PersonaDetailView(persona: persona)
                .environmentObject(PersonaManager.shared)
        }
    }
}
