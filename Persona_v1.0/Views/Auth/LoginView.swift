//
//  LoginView.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/30.
//

import SwiftUI

// 登录视图
struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var rememberMe = false
    @State private var isRegisterMode = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoggingIn = false
    @State private var showMainContent = false
    
    @State private var showUserSelection = false
    
    @ObservedObject private var userManager = UserManager.shared
    
    // 是否从用户选择界面跳转过来
    var isFromUserSelection = false
    
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
                    
                    // 登录表单
                    VStack(spacing: 16) {
                        // 用户名
                        TextField("用户名", text: $username)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .disabled(isLoggingIn)
                        
                        // 密码
                        SecureField("密码", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .disabled(isLoggingIn)
                        
                        // 确认密码（仅注册模式）
                        if isRegisterMode {
                            SecureField("确认密码", text: $confirmPassword)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                                .disabled(isLoggingIn)
                        }
                        
                        // 记住我（仅登录模式）
                        if !isRegisterMode {
                            HStack {
                                Toggle("记住我", isOn: $rememberMe)
                                    .toggleStyle(SwitchToggleStyle(tint: .white))
                                    .foregroundColor(.white)
                                    .disabled(isLoggingIn)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        
                        // 登录/注册按钮
                        Button(action: isRegisterMode ? register : login) {
                            if isLoggingIn {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding()
                            } else {
                                Text(isRegisterMode ? "注册" : "登录")
                                    .font(.headline)
                                    .padding()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .disabled(isLoggingIn || username.isEmpty || password.isEmpty || (isRegisterMode && confirmPassword.isEmpty))
                        
                        // 切换登录/注册模式
                        Button(action: toggleMode) {
                            Text(isRegisterMode ? "已有账号？登录" : "没有账号？注册")
                                .foregroundColor(.white)
                                .underline()
                        }
                        .disabled(isLoggingIn)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 40)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                    .blur(radius: isLoggingIn ? 2 : 0)
                }
                .padding()
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showingError) {
                Alert(
                    title: Text(isRegisterMode ? "注册失败" : "登录失败"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("确定"))
                )
            }
            .fullScreenCover(isPresented: $showMainContent) {
                ContentView()
                    .environmentObject(UserManager.shared)
            }
            .fullScreenCover(isPresented: $showUserSelection) {
                UserSelectionView()
            }
        }
        .navigationBarBackButtonHidden(!isFromUserSelection)
        .toolbar {
            if isFromUserSelection {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        showUserSelection = true
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    // 切换登录/注册模式
    private func toggleMode() {
        isRegisterMode.toggle()
        password = ""
        confirmPassword = ""
        errorMessage = ""
    }
    
    // 登录
    private func login() {
        isLoggingIn = true
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let success = userManager.login(username: username, password: password, rememberMe: rememberMe)
            
            DispatchQueue.main.async {
                isLoggingIn = false
                
                if success {
                    showMainContent = true
                } else {
                    errorMessage = "用户名或密码错误"
                    showingError = true
                }
            }
        }
    }
    
    // 注册
    private func register() {
        isLoggingIn = true
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let success = userManager.register(username: username, password: password, confirmPassword: confirmPassword)
            
            DispatchQueue.main.async {
                isLoggingIn = false
                
                if success {
                    if isFromUserSelection {
                        // 从用户选择界面过来的，注册成功后返回用户选择界面
                        showUserSelection = true
                    } else {
                        // 直接注册的，注册成功后登录
                        showMainContent = true
                    }
                } else {
                    if password != confirmPassword {
                        errorMessage = "两次输入的密码不一致"
                    } else {
                        errorMessage = "用户名已存在"
                    }
                    showingError = true
                }
            }
        }
    }
}

// 预览
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
