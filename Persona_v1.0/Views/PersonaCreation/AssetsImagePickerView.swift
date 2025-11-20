//
//  AssetsImagePickerView.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/25.
//

import SwiftUI

// Assets图像选择器视图
struct AssetImagePickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedImageName: String?
    
    // Assets中的头像图像名称列表
    let assetImageNames = [
        "皮卡丘", "玉玉表情包", "银杏叶下", "星空", "猫猫头",
        "沮丧猫猫", "酒馆", "动漫", "摆烂表情包"
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("选择头像")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(assetImageNames, id: \.self) { imageName in
                            Button(action: {
                                selectedImageName = imageName
                                dismiss()
                            }) {
                                VStack {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        .shadow(radius: 3)
                                    
                                    Text(imageName)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarItems(trailing: Button("取消") {
                dismiss()
            })
        }
    }
}

// 预览
struct AssetImagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        AssetImagePickerView(selectedImageName: .constant(nil))
    }
}
