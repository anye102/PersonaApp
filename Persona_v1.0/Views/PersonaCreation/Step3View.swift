import SwiftUI

struct Step3View: View {
    @Binding var selectedAssetImageName: String?
    var prevStep: () -> Void
    var createPersona: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("第三步：上传头像")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                if let selectedAssetImageName = selectedAssetImageName {
                    // 显示从Assets中选择的图像
                    Image(selectedAssetImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10)
                } else {
                    Circle()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                        )
                }
                
                NavigationLink {
                    AssetImagePickerView(selectedImageName: $selectedAssetImageName)
                } label: {
                    Label("从Assets选择头像", systemImage: "photo.badge.plus")
                }
                .buttonStyle(.bordered)
                
                Text("或")
                    .foregroundColor(.gray)
                
                Button(action: {
                    selectedAssetImageName = nil
                }) {
                    Label("使用默认头像", systemImage: "person.circle")
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
            
            HStack {
                Button(action: prevStep) {
                    Text("上一步")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Spacer()
                
                Button(action: createPersona) {
                    Text("创建Persona")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}
