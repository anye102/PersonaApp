//
//  ContentView.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/20.
//

import SwiftUI

// 主视图
struct ContentView: View {
    @StateObject private var personaManager = PersonaManager.shared
    
    var body: some View {
        TabView {
            NavigationStack{
                SocialSquareView()
            }
            .tabItem {
                Image(systemName: "house")
                Text("广场")
            }
            
            NavigationStack {
                MyPersonasView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("我的")
            }
            
            NavigationStack {
                ChatView()
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("聊天")
            }
            
            // 设置标签
            NavigationStack {
                SettingsView()
                    .environmentObject(personaManager)
            }
            .tabItem {
                Label("设置", systemImage: "gearshape.fill")
            }
            
        }
        .environmentObject(personaManager)
    }
}

#Preview {
    ContentView()
}
