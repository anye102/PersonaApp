//
//  UserManager.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/30.
//
import Foundation
internal import Combine
import SwiftUI

//MARK: - 用户管理器
class UserManager: ObservableObject {
    static let shared = UserManager()
    private init() {
        loadAllUsers()
    }
    
    @Published var currentUser: User?
    @Published var allUsers: [User] = []
    
    private let userDefaults = UserDefaults.standard
    private let usersKey = "allUsers"
    private let currentUserIdKey = "currentUserId"
    private let autoLoginKey = "autoLogin"
    private let lastLoginUserIdKey = "lastLoginUserId"
    
    // 检查是否已登录
    var isLoggedIn: Bool {
        return currentUser != nil
    }
    
    // 检查是否启用自动登录
    var isAutoLoginEnabled: Bool {
        return userDefaults.bool(forKey: autoLoginKey)
    }
    
    // 尝试自动登录
    func tryAutoLogin() -> Bool {
        guard isAutoLoginEnabled else {
            return false
        }
        
        // 获取上次登录的用户ID
        guard let lastLoginUserId = userDefaults.string(forKey: lastLoginUserIdKey),
              let userId = UUID(uuidString: lastLoginUserId),
              let user = allUsers.first(where: { $0.id == userId }) else {
            return false
        }
        
        // 登录该用户
        currentUser = user
        saveCurrentUser()
        return true
    }
    
    // 登录
    func login(username: String, password: String, rememberMe: Bool) -> Bool {
        
        // 查找用户
        if let user = allUsers.first(where: { $0.username == username }) {
            // 验证密码
            if user.password == password {
                currentUser = user
                saveCurrentUser()
                
                // 更新自动登录设置
                if rememberMe {
                    enableAutoLogin(userId: user.id)
                } else {
                    disableAutoLogin()
                }
                
                return true
            } else {
                return false
            }
        } else {
            // 创建新用户
            let newUser = User(username: username, password: password)
            currentUser = newUser
            allUsers.append(newUser)
            saveAllUsers()
            saveCurrentUser()
            
            // 更新自动登录设置
            if rememberMe {
                enableAutoLogin(userId: newUser.id)
            } else {
                disableAutoLogin()
            }
            
            return true
        }
    }
    
    // 注册新用户
    func register(username: String, password: String, confirmPassword: String) -> Bool {
        guard password == confirmPassword else {
            return false
        }
        
        // 检查用户名是否已存在
        if allUsers.contains(where: { $0.username == username }) {
            return false
        }
        
        let newUser = User(username: username, password: password)
        currentUser = newUser
        allUsers.append(newUser)
        saveAllUsers()
        saveCurrentUser()
        return true
    }
    
    // 切换用户
    func switchUser(to user: User, rememberMe: Bool) {
        currentUser = user
        saveCurrentUser()
        
        // 如果启用了自动登录，更新上次登录用户
        if rememberMe {
            enableAutoLogin(userId: user.id)
        }
    }
    
    // 获取所有用户
    func getAllUsers() -> [User] {
        return allUsers
    }
    
    // 删除用户
    func deleteUser(_ user: User) {
        // 不能删除当前登录的用户
        guard currentUser?.id != user.id else {
            return
        }
        
        allUsers.removeAll { $0.id == user.id }
        saveAllUsers()
        
        // 如果删除的是自动登录的用户，取消自动登录
        if let lastLoginUserId = userDefaults.string(forKey: lastLoginUserIdKey),
           let userId = UUID(uuidString: lastLoginUserId),
           userId == user.id {
            disableAutoLogin()
        }
    }
    
    // 更新用户信息
    func updateUserInfo() {
        guard let user = currentUser, let userId = currentUser?.id else {
            return
        }
        
        // 更新用户列表中的用户信息
        if let index = allUsers.firstIndex(where: { $0.id == userId }) {
            allUsers[index] = user
            saveAllUsers()
        }
        
        saveCurrentUser()
    }
    
    // 更新头像
    func updateAvatar(_ avatar: String?) {
        guard var user = currentUser, let userId = currentUser?.id else {
            return
        }
        user.avatar = avatar
        currentUser = user
        
        // 更新用户列表中的用户信息
        if let index = allUsers.firstIndex(where: { $0.id == userId }) {
            allUsers[index] = user
            saveAllUsers()
        }
        
        saveCurrentUser()
    }
    
    // 退出登录
    func logout() {
        currentUser = nil
        userDefaults.set(false, forKey: autoLoginKey)
        userDefaults.removeObject(forKey: currentUserIdKey)
    }
    
    // 保存所有用户到本地
    private func saveAllUsers() {
        do {
            let data = try JSONEncoder().encode(allUsers)
            userDefaults.set(data, forKey: usersKey)
        } catch {
            print("保存所有用户失败: \(error)")
        }
    }
    
    // 加载所有用户
    private func loadAllUsers() {
        guard let data = userDefaults.data(forKey: usersKey) else {
            return
        }
        
        do {
            allUsers = try JSONDecoder().decode([User].self, from: data)
        } catch {
            print("加载所有用户失败: \(error)")
        }
    }
    
    // 保存当前用户
    private func saveCurrentUser() {
        guard let user = currentUser else {
            return
        }
        
        userDefaults.set(user.id.uuidString, forKey: currentUserIdKey)
    }
    
    // 启用自动登录
    private func enableAutoLogin(userId: UUID) {
        userDefaults.set(true, forKey: autoLoginKey)
        userDefaults.set(userId.uuidString, forKey: lastLoginUserIdKey)
    }
    
    // 禁用自动登录
    func disableAutoLogin() {
        userDefaults.set(false, forKey: autoLoginKey)
        userDefaults.removeObject(forKey: lastLoginUserIdKey)
    }
    
    // 获取用户头像
    func getAvatarImage(for user: User? = nil) -> Image {
        let targetUser = user ?? currentUser
        
        if let avatar = targetUser?.avatar, !avatar.isEmpty {
            return Image(avatar)
        }
        return Image(systemName: "person.circle.fill")
    }
}
