//
//  Chat.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/26.
//
import SwiftUI

// 聊天列表视图
struct ChatView: View {
    @EnvironmentObject var personaManager: PersonaManager
    
    var body: some View {
        NavigationStack {
            List {
                // 与我的Persona聊天
                let userPersonas = personaManager.getUserPersonas()
                
                if !userPersonas.isEmpty {
                    Section("创建的Persona") {
                        ForEach(userPersonas) { userPersona in
                            NavigationLink {
                                PersonaChatView(persona: userPersona)
                                    .environmentObject(personaManager)
                            } label: {
                                ChatListItemView(persona: userPersona)
                                    .environmentObject(personaManager)
                            }
                        }
                    }
                }
                
                // 与关注的Persona聊天
                let followedPersonas = personaManager.getFollowedPersonas()
                
                if !followedPersonas.isEmpty {
                    Section("关注的Persona") {
                        ForEach(followedPersonas) { persona in
                            NavigationLink {
                                PersonaChatView(persona: persona)
                                    .environmentObject(personaManager)
                            } label: {
                                ChatListItemView(persona: persona)
                                    .environmentObject(personaManager)
                            }
                        }
                    }
                }
            }
            .navigationTitle("聊天")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if personaManager.getUserPersonas().isEmpty && personaManager.getFollowedPersonas().isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "message.slash.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("暂无聊天记录")
                            .font(.headline)
                        Text("创建或关注Persona后可以开始聊天")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
}

struct PreChatView: PreviewProvider {
    static var previews: some View {
        ChatView()
            .environmentObject(PersonaManager.shared)
    }
}
