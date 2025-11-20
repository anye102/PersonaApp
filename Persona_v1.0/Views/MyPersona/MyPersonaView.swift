//
//  MyPersonaView.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/20.
//

import SwiftUI

// 我的Persona视图
struct MyPersonasView: View {
    @EnvironmentObject var personaManager: PersonaManager
    @State private var showingCreatePersona = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("创建的Persona") {
                    if personaManager.getUserPersonas().isEmpty {
                        Text("你还没有创建任何Persona")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(personaManager.getUserPersonas()) { persona in
                            NavigationLink {
                                PersonaDetailView(persona: persona)
                            } label: {
                                HStack {
                                    loadAvatar(imageName: persona.avatar)
                                    VStack(alignment: .leading) {
                                        Text(persona.name)
                                            .font(.headline)
                                        Text(persona.personality)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section("关注的Persona") {
                    if personaManager.getFollowedPersonas().isEmpty {
                        Text("你还没有关注任何Persona")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(personaManager.getFollowedPersonas()) { persona in
                            NavigationLink {
                                PersonaDetailView(persona: persona)
                            } label: {
                                HStack {
                                    loadAvatar(imageName: persona.avatar)
                                    VStack(alignment: .leading) {
                                        Text(persona.name)
                                            .font(.headline)
                                        Text(persona.personality)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section("推荐关注") {
                    let recommendedPersonas = personaManager.getPersonas().filter { !$0.isFollowed && !personaManager.getUserPersonas().contains(where: { $0.id == $0.id }) }
                    
                    if recommendedPersonas.isEmpty {
                        Text("暂无推荐Persona")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(recommendedPersonas) { persona in
                            HStack {
                                loadAvatar(imageName: persona.avatar)
                                VStack(alignment: .leading) {
                                    Text(persona.name)
                                        .font(.headline)
                                    Text(persona.personality)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button(action: {
                                    personaManager.followPersona(persona.id)
                                }) {
                                    Text("关注")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue)
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("我的Persona")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: {
                    showingCreatePersona = true
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
            .sheet(isPresented: $showingCreatePersona) {
                PersonaCreationView()
                    .environmentObject(personaManager)
            }
        }
    }
}

struct PreMyPersonasView: PreviewProvider {
    static var previews: some View {
        MyPersonasView()
            .environmentObject(PersonaManager.shared)
    }
}
