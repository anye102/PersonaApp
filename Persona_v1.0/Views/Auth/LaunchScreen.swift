//
//  LaunchScreen.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/30.
//

import SwiftUI

// 启动屏视图
struct LaunchScreen: View {
    @State private var isLoading = true
    @State private var showLogin = false
    @State private var showUserSelection = false
    @State private var showMainContent = false
    
    @ObservedObject private var userManager = UserManager.shared
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            // 内容
            VStack(spacing: 20) {
                // 应用Logo
                Image(systemName: "person.3.sequence.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                // 应用名称
                Text("Persona")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                
                // 加载指示器
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            // 模拟加载过程
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                checkLoginStatus()
            }
        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
        }
        .fullScreenCover(isPresented: $showUserSelection) {
            UserSelectionView()
        }
        .fullScreenCover(isPresented: $showMainContent) {
            ContentView()
                .environmentObject(userManager)
        }
    }
    
    // 检查登录状态
    private func checkLoginStatus() {
        
        if userManager.tryAutoLogin() {
            // 已登录或自动登录成功，显示主内容
            showMainContent = true
        } else {
            // 自动登录失败，根据用户数量决定显示哪个界面
            if userManager.allUsers.count > 1 {
                // 有多个用户，显示用户选择界面
                showUserSelection = true
            } else {
                // 只有一个用户或没有用户，显示登录界面
                showLogin = true
            }
        }
        
        isLoading = false
    }
}

// 预览
struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
