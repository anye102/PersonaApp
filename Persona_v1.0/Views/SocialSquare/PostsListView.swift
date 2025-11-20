//
//  PostsListView.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/24.
//

import SwiftUI

struct PostsListView: View {
    let posts: [Post]
    let title: String
    let emptyMessage: String
    let emptySubmessage: String
    let emptyImage: String
    
    @EnvironmentObject var personaManager: PersonaManager
    @State private var showingChat = false
    @State private var selectedPost: Post?
    
    // 页面滚动相关状态
    @State private var scrollOffset: CGFloat = 0
    @State private var showScrollToTopButton = false
    @State private var scrollProgress: CGFloat = 0
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                List {
                    if posts.isEmpty {
                        // 如果没有帖子，显示提示
                        VStack(spacing: 20) {
                            Image(systemName: emptyImage)
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            Text(emptyMessage)
                                .font(.headline)
                            Text(emptySubmessage)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
//                        .listRowInsets(EdgeInsets())
                    } else {
                        ForEach(Array(posts.enumerated()), id: \.element.id) { index, post in
                            PostRowView(
                                post: post,
                                showingChat: $showingChat,
                                selectedPost: $selectedPost
                            )
                            .id("post_\(index)")
                            .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.1), value: index)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGray6))
                .onChange(of: scrollOffset) { oldValue, newValue in
                    // 更新滚动进度
                    scrollProgress = min(max(newValue / 2000, 0), 1)
                    
                    // 控制滚动到顶部按钮的显示/隐藏
                    showScrollToTopButton = newValue > 300
                }
                .background(
                    // 2. 滚动位置监听
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
                    }
                )
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                    scrollOffset = -offset
                }
                
                // 2. 滚动进度指示器
                GeometryReader { proxy in
                    Color.blue
                        .frame(height: 2)
                        .frame(maxWidth: proxy.size.width * scrollProgress)
                        .edgesIgnoringSafeArea(.top)
                }
            }
            .onAppear {
                // 初始动画：从下往上进入
                withAnimation(.easeInOut(duration: 0.8)) {
                    scrollOffset = 0
                }
            }
            .sheet(isPresented: $showingChat) {
                // 根据selectedPost显示聊天页面
                if let selectedPost = selectedPost,
                   let persona = personaManager.getPersonaById(for: selectedPost.personaId){
                    PersonaChatView(persona: persona)
                        .id(selectedPost.personaId)
                        .environmentObject(personaManager)
                }
            }
        }
    }
}
