//
//  PostRowView.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/21.
//

import SwiftUI

// MARK: - 单条动态页面
struct PostRowView: View {
    @ObservedObject var post: Post
    @EnvironmentObject var personaManager: PersonaManager
    @Binding var showingChat: Bool
    @Binding var selectedPost: Post?

    // 获取当前post对应的persona
    private var persona: Persona? {
        personaManager.getPersona(for: post)
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                
                // 头像（点击头像可与之对话）
                Button (action: {
                    selectedPost = post
                    showingChat = true
                }) {
                    loadAvatar(
                        imageName: persona?.avatar ?? ""
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // 名称、性格（点击名称可与之对话）
                VStack(alignment: .leading, spacing: 2) {
                    // 名称 - 点击名称也打开聊天
                    Button(action: {
                        selectedPost = post
                        showingChat = true
                    }) {
                        Text(persona?.name ?? "未知用户")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    
                    // 性格
                    Text(persona?.personality ?? "未知个性")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()
                
                // 关注键
                Button(action: {
                    personaManager.followPersona(post.personaId)
                }) {
                    Text(personaManager.getPersonaById(for: post.personaId)?.isFollowed ?? false ? "已关注" : "关注")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(personaManager.getPersonaById(for: post.personaId)?.isFollowed ?? false ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // 动态内容
            Text(post.content)
            
            // 动态菜单
            HStack(spacing: 0) {
                
                // 点赞按钮
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        post.isLiked.toggle()
                        post.likeCount += post.isLiked ? 1 : -1
                    }
                }) {
                    HStack {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(post.isLiked ? .blue : .gray)
                        Text("\(post.likeCount)")
                    }
                    .frame(width: 60, alignment: .leading)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 70)
                
                // 收藏按钮
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        post.isMarked.toggle()
                        post.markCount += post.isMarked ? 1 : -1
                    }
                }) {
                    HStack {
                        Image(systemName: post.isMarked ? "bookmark.fill" : "bookmark")
                            .foregroundColor(post.isMarked ? .black : .gray)
                        Text("\(post.markCount)")
                    }
                    .frame(width: 60, alignment: .leading)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Text(post.formatDate(post.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .background(Color.white)
    }
}
