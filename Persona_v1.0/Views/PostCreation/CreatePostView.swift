//
//  CreatePostView.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/25.
//

import SwiftUI
import PhotosUI

struct CreatePostView: View {
    @State private var content = ""
    @State private var postRequirement = ""
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var postImages: [UIImage] = []
    @State private var isGenerating = false
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var personaManager: PersonaManager
    
    // 当前选中的Persona（用户可以选择用哪个Persona发布）
    @State var selectedPersonaId: UUID?
    @State private var showingCreatePersona = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // 选择发布的Persona
                personaSelectionView
                
                // 动态要求输入
                requirementInputView
                    .disabled(selectedPersonaId == nil)
                
                // AI生成按钮
                if selectedPersonaId != nil {
                    HStack {
                        Spacer()
                        Button(action: generateContentWithAI) {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding()
                            } else {
                                Label("AI生成", systemImage: "wand.and.stars")
                                    .padding()
                            }
                        }
                        .disabled(isGenerating || selectedPersonaId == nil)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.trailing)
                    }
                }
                
                // 动态内容输入
                contentInputView
                    .disabled(selectedPersonaId == nil)
                
                // 图片选择
                imageSelectionView
                    .disabled(selectedPersonaId == nil)
                
                Spacer()
            }
            .navigationTitle("发布动态")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("发布") {
                        publishPost()
                    }
                    .disabled(content.isEmpty || selectedPersonaId == nil || isGenerating)
                }
            }
            .onChange(of: selectedImages) { oldImages, newImages in
                loadImages()
            }
            .sheet(isPresented: $showingCreatePersona) {
                PersonaCreationView()
                    .environmentObject(personaManager)
            }
            .alert(isPresented: $showingError) {
                Alert(
                    title: Text("生成失败"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("确定"))
                )
            }
        }
    }
    
    // MARK: - Subviews
        
    private var personaSelectionView: some View {
        Group {
            let userPersonas = personaManager.getUserPersonas()
            if userPersonas.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "person.slash.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("你还没有创建任何Persona")
                        .font(.headline)
                    Text("请先创建一个Persona才能发布动态")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        showingCreatePersona = true
                    }) {
                        Text("创建Persona")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding()
            } else if let selectedPersonaId = selectedPersonaId,
               let persona = personaManager.getPersonaById(for: selectedPersonaId) {
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
                .padding()
            } else {
                Picker("选择发布的Persona", selection: $selectedPersonaId) {
                    ForEach(personaManager.getUserPersonas()) {
                        Text($0.name)
                            .tag(Optional($0.id))
                    }
                }
                .pickerStyle(.segmented)
                .padding()
            }
        }
    }
    
    // 动态要求输入子视图
    private var requirementInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("动态要求（可选）")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading)
            
            TextField("例如：分享今天的心情、推荐一本书、讨论一个话题...", text: $postRequirement, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .padding()
                .lineLimit(2...3)
        }
    }
    
    // 内容输入子视图
    private var contentInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("动态内容")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading)
            
            TextField("分享你的想法...", text: $content, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .padding()
                .lineLimit(5...10)
        }
    }
    
    // 图片选择子视图
    private var imageSelectionView: some View {
        VStack(spacing: 16) {
            // 图片预览
            if !postImages.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(postImages, id: \.self) { image in
                            imagePreviewCell(image: image)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // 添加图片按钮
            PhotosPicker(selection: $selectedImages, maxSelectionCount: 3, matching: .images) {
                Label("添加图片", systemImage: "photo.badge.plus")
            }
            .buttonStyle(.bordered)
            .padding()
        }
    }
    
    private func imagePreviewCell(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 100, height: 100)
            .cornerRadius(8)
            .overlay(
                Button(action: {
                    removeImage(image)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding(5),
                alignment: .topTrailing
            )
    }

    private func loadImages() {
        Task {
            postImages.removeAll()
            
            for item in selectedImages {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    postImages.append(image)
                }
            }
        }
    }
    
    private func removeImage(_ image: UIImage) {
        if let index = postImages.firstIndex(where: { $0.pngData() == image.pngData() }) {
            postImages.remove(at: index)
            // 也需要更新selectedImages，但由于PhotosPickerItem不支持直接比较，这里简化处理
            selectedImages.remove(at: min(index, selectedImages.count - 1))
        }
    }
    
    private func publishPost() {
        guard let selectedPersonaId = selectedPersonaId,
              let persona = personaManager.getPersonaById(for: selectedPersonaId) else {
            return
        }
        
        // 在实际应用中，这里会上传图片并获取URL
        // 这里简化处理，使用nil
        personaManager.createPost(persona: persona, content: content)
        
        dismiss()
    }
    
    // MARK: - AI Content Generation
    
    @State private var showingError = false
    @State private var errorMessage = ""
    
    private func generateContentWithAI() {
        guard let selectedPersonaId = selectedPersonaId,
              let persona = personaManager.getUserPersonas().first(where: { $0.id == selectedPersonaId }) else {
            return
        }
        
        isGenerating = true
        
        // 构建生成提示
        let prompt = buildGenerationPrompt()
        
        // 调用AI服务生成内容
        AIService.shared.generateContent(persona: persona, prompt: prompt) { [self] result in
            DispatchQueue.main.async {
                self.isGenerating = false
                
                switch result {
                case .success(let generatedContent):
                    self.content = generatedContent
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showingError = true
                }
            }
        }
    }
    
    private func buildGenerationPrompt() -> String {
        if postRequirement.isEmpty {
            return "请基于你的人设生成一条社交媒体动态，内容要符合你的性格特点和背景故事。语言风格要自然、生动，符合社交媒体表达习惯，适当使用表情符号。不要包含Markdown格式。"
        } else {
            return "请基于你的人设生成一条社交媒体动态，内容要求：\(postRequirement)。内容要符合你的性格特点和背景故事。语言风格要自然、生动，符合社交媒体表达习惯，适当使用表情符号。不要包含Markdown格式。"
        }
    }
}

struct PrePostCreationView: PreviewProvider {
    static var previews: some View {
        if let persona = PersonaManager.shared.getPersonas().first {
            CreatePostView(selectedPersonaId: persona.id)
                .environmentObject(PersonaManager.shared)
        }
    }
}
