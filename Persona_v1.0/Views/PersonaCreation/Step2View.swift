//
//  Step2View.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/24.
//

import SwiftUI

struct Step2View: View {
    @Binding var backgroundStory: String
    @Binding var interests: [String]
    var prevStep: () -> Void
    var nextStep: () -> Void
    
    @State private var newInterest = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("第二步：背景故事与兴趣")
                .font(.title)
                .fontWeight(.bold)
            
            ZStack(alignment: .topLeading) {
                // 占位符（仅当为空时显示）
                if backgroundStory.isEmpty {
                    Text("输入Persona的背景故事与兴趣...")
//                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false) // 允许点击穿透
                }

                // 多行文本编辑器
                TextEditor(text: $backgroundStory)
                    .padding(8)
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.3))
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
            }
            
//            VStack(spacing: 10) {
//                HStack {
//                    TextField("添加兴趣", text: $newInterest)
//                        .textFieldStyle(.roundedBorder)
//                    
//                    Button(action: addInterest) {
//                        Text("添加")
//                            .padding()
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                    .disabled(newInterest.isEmpty)
//                }
//                
//                if !interests.isEmpty {
//                    ScrollView(.horizontal) {
//                        HStack(spacing: 10) {
//                            ForEach(interests, id: \.self) { interest in
//                                HStack {
//                                    Text(interest)
//                                        .padding(8)
//                                        .background(Color.gray.opacity(0.2))
//                                        .cornerRadius(20)
//                                    
//                                    Button(action: {
//                                        removeInterest(interest)
//                                    }) {
//                                        Image(systemName: "xmark.circle.fill")
//                                            .foregroundColor(.gray)
//                                    }
//                                }
//                            }
//                        }
//                        .padding(.vertical, 5)
//                    }
//                }
//            }
//            .padding()
            
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
                
                Button(action: nextStep) {
                    Text("下一步")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
    
//    private func addInterest() {
//        guard !newInterest.isEmpty else { return }
//        
//        if !interests.contains(newInterest) {
//            interests.append(newInterest)
//        }
//        
//        newInterest = ""
//    }
//    
//    private func removeInterest(_ interest: String) {
//        interests.removeAll { $0 == interest }
//    }
}

// 占位符扩展
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
