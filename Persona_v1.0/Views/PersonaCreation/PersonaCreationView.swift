import SwiftUI
import PhotosUI
import Photos

// 辅助类，用于处理图片保存回调
class ImageSaver: NSObject {
    private var completion: ((Error?) -> Void)?
    
    func saveImage(image: UIImage, completion: @escaping (Error?) -> Void) {
        self.completion = completion
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        completion?(error)
    }
}

struct PersonaCreationView: View {
    @State private var name = ""
    @State private var personality = ""
    @State private var backstory = ""
    @State private var interests: [String] = []
    @State private var selectedAssetImageName: String?
    @State private var avatarImage: UIImage?
    @State private var isCreating = false
    @State private var errorMessage: String? = nil
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var personaManager: PersonaManager
    
    // 步骤管理
    @State private var currentStep = 1
    
    var body: some View {
        NavigationStack {
            VStack {
                // 进度指示器
                ProgressView(value: Float(currentStep), total: 3)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .padding()
                
                if currentStep == 1 {
                    Step1View(
                        name: $name,
                        personality: $personality,
                        nextStep: { currentStep = 2 }
                    )
                } else if currentStep == 2 {
                    Step2View(
                        backgroundStory: $backstory,
                        interests: $interests,
                        prevStep: { currentStep = 1 },
                        nextStep: { currentStep = 3 }
                    )
                } else if currentStep == 3 {
                    Step3View(
                        selectedAssetImageName: $selectedAssetImageName,
                        prevStep: { currentStep = 2 },
                        createPersona: createPersona
                    )
                }
            }
            .navigationTitle("创建Persona")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
//            .alert(item: $errorMessage) { message in
//                Alert(
//                    title: Text("创建失败"),
//                    message: Text(message),
//                    dismissButton: .default(Text("确定"))
//                )
//            }
            .overlay(
                // AI辅助生成按钮（在所有步骤中都显示）
                VStack {
                    Spacer()
                    AIAssistantView(
                        name: $name,
                        personality: $personality,
                        backgroundStory: $backstory,
                        interests: $interests
                    )
                }
            )
        }
    }
    
    private func createPersona() {
        // 验证输入
        guard !name.isEmpty else {
            errorMessage = "请输入名称"
            return
        }
        
        guard !personality.isEmpty else {
            errorMessage = "请输入性格"
            return
        }
        
        // 获取当前用户id
        guard let currentUserId = UserManager.shared.currentUser?.id else {
            errorMessage = "无法获取用户信息，请重新登录"
            return
        }
        
        // 创建新Persona
        let newPersona = Persona(
            name: name,
            avatar: selectedAssetImageName ?? "",
            personality: personality,
            backstory: backstory,
            userId: currentUserId
        )
//        newPersona.isFollowed = false
        
        // 显示加载状态
        isCreating = true
        
        // 添加到PersonaManager
        personaManager.addUserPersona(newPersona) { [self] result in
                        
            // 隐藏加载状态
            self.isCreating = false
            
            switch result {
            case .success:
                // 关闭创建界面
                self.dismiss()
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }

        }
        
        // 关闭创建界面
        dismiss()
    }
}

struct PrePersonaCreationView: PreviewProvider {
    static var previews: some View {
        PersonaCreationView()
            .environmentObject(PersonaManager.shared)
    }
}
