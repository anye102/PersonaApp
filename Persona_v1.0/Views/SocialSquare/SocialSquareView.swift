//
//  SocialSquareView.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/20.
//

import SwiftUI
import Foundation

// MARK: - 滚动位置偏好键
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - 社交广场图
struct SocialSquareView: View {
    @EnvironmentObject var personaManager: PersonaManager
    @State private var showingChat = false
    @State private var selectedPost: Post?
    @State private var showingCreatePost = false
    
    // 滚动相关状态
    @State private var scrollOffset: CGFloat = 0
    @State private var showScrollToTopButton = false
    @State private var scrollProgress: CGFloat = 0
    
    // 当前选中的标签页
    @State private var selectedTab: Int = 0
    
    // 获取所有已关注的Persona的帖子
    private var followerPosts: [Post] {
        let followedPersonaIds = personaManager.getFollowedPersonas().map { $0.id }
        return personaManager.posts.filter { followedPersonaIds.contains( $0.personaId )}
    }
    
    // 获取所有自创建的Persona的帖子
    private var userPosts: [Post] {
        let userPersonaIds = personaManager.getUserPersonas().map { $0.id }
        return personaManager.posts.filter { userPersonaIds.contains( $0.personaId )}
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // 顶部导航栏
                    ZStack {
                        
                        // 中间分段控制器
                        Picker("选择页面", selection: $selectedTab) {
                            Label("推荐", systemImage: "star")
                                .tag(0)
                            Label("关注", systemImage: "heart.fill")
                                .tag(1)
                            Label("我的", systemImage: "heart.fill")
                                .tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 200) // 固定宽度，使其居中
                    }
//                    .background(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                    
                    // 根据选中的标签的不同来显示不同的页面
                    Group {
                        if selectedTab == 0 {
                            // 推荐页面
                            PostsListView(
                                posts: personaManager.posts,
                                title: "推荐",
                                emptyMessage: "暂无推荐内容",
                                emptySubmessage: "刷新页面获取更多动态",
                                emptyImage: "star.slash"
                            )
                        } else if selectedTab == 1 {
                            // 关注页面
                            PostsListView(
                                posts: followerPosts,
                                title: "关注",
                                emptyMessage: "还没有关注任何人",
                                emptySubmessage: "关注感兴趣的Persona，获取他们的最新动态",
                                emptyImage: "persona.badge.plus"
                            )
                        } else {
                            // 我的页面
                            PostsListView(
                                posts: userPosts,
                                title: "关注",
                                emptyMessage: "创建的Persona还没有发布任何动态",
                                emptySubmessage: "利用Persona发布有趣的动态吧",
                                emptyImage: "persona.badge.plus"
                            )
                        }
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .navigationTitle("社交广场")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: {
                    showingCreatePost = true
                }) {
                    Circle()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .overlay(
                            Image(systemName: "plus")
                                .foregroundColor(.blue)
                                .font(.headline)
                        )
                }
            }
            .sheet(isPresented: $showingCreatePost) {
                CreatePostView()
                    .environmentObject(personaManager)
            }
        }
    }
}

struct PreSocialSquareView: PreviewProvider {
    static var previews: some View {
        SocialSquareView()
            .environmentObject(PersonaManager.shared)
    }
}
