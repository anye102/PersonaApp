//
//  UserSelectionView.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/30.
//

import SwiftUI

// 用户选择界面
struct UserSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var userManager = UserManager.shared
    @State private var showingLoginView = false
    @State private var selectedUser: User?
    @State private var showingMainContent = false
    @State private var rememberMe = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                // 内容
                VStack(spacing: 20) {
                    // 应用Logo和名称
                    VStack(spacing: 10) {
                        Image(systemName: "person.3.sequence.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        
                        Text("Persona")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 40)
                    
                    // 用户列表
                    if !userManager.allUsers.isEmpty {
                        VStack(spacing: 16) {
                            Text("选择用户")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            ScrollView {
                                VStack(spacing: 10) {
                                    ForEach(userManager.getAllUsers()) { user in
                                        Button(action: {
                                            selectedUser = user
                                        }) {
                                            HStack(spacing: 15) {
                                                userManager.getAvatarImage(for: user)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 50, height: 50)
                                                    .cornerRadius(25)
                                                    .clipped()
                                                    .font(.system(size: 50))
                                                    .foregroundColor(.white)
                                                Text(user.username)
                                                    .font(.system(size: 30))
                                                    .foregroundColor(.white)
                                                
                                                Spacer()
                                                
                                                if selectedUser?.id == user.id {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.system(size: 20))
                                                        .foregroundColor(.black)
                                                }
                                            }
                                            .padding()
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(15)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // 自动登录按钮
                            HStack {
                                Toggle("记住我", isOn: $rememberMe)
                                    .toggleStyle(SwitchToggleStyle(tint: .white))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            // 登录按钮
                            Button(action: loginSelectedUser) {
                                Text("登录")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .foregroundColor(.blue)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                            .disabled(selectedUser == nil)
                        }
                        .padding(.vertical, 40)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                        .padding(.horizontal, 30)
                    }
                    
                    // 分隔线
                    if !userManager.allUsers.isEmpty {
                        VStack {
                            Text("或者")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                        }
                    }
                    
                    // 新建用户按钮
                    Button(action: {
                        showingLoginView = true
                    }) {
                        Text("新建用户")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 30)
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showingLoginView) {
                LoginView(isFromUserSelection: true)
            }
            .fullScreenCover(isPresented: $showingMainContent) {
                ContentView()
                    .environmentObject(userManager)
            }
        }
    }
    
    // 格式化日期
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // 登录选中的用户
    private func loginSelectedUser() {
        guard let user = selectedUser else {
            return
        }
        
        userManager.switchUser(to: user, rememberMe: rememberMe)
        
        showingMainContent = true
    }
}

// 预览
struct UserSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        UserSelectionView()
    }
}
