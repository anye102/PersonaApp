//
//  AIAssistantView.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/24.
//

import SwiftUI
import PhotosUI

struct AIAssistantView: View {
    @Binding var name: String
    @Binding var personality: String
    @Binding var backgroundStory: String
    @Binding var interests: [String]
    
    @State private var isGenerating = false
    
    var body: some View {
        Button(action: generatePersona) {
            HStack {
                Text("AI辅助生成")
                if isGenerating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.7)
                }
            }
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
    
    private func generatePersona() {
        isGenerating = true
        
        // 模拟API调用延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // 模拟生成结果
            name = [
                "星际旅行者",
                "时间守护者",
                "梦境编织者",
                "量子诗人",
                "数字游民",
                "心灵捕手",
                "自然观察者",
                "未来预言家"
            ].randomElement()! + String(Int.random(in: 100...999))
            
            personality = [
                "探索精神强烈，充满好奇心",
                "沉稳内敛，思考深邃",
                "热情洋溢，富有创造力",
                "理性与感性并存",
                "乐观开朗，善于沟通",
                "深思熟虑，洞察敏锐",
                "温和友善，充满同理心",
                "勇敢无畏，敢于创新"
            ].randomElement()!
            
            backgroundStory = [
                "来自遥远星系的旅行者，穿越时空寻找宇宙真理",
                "守护时间线的神秘存在，见证过无数历史瞬间",
                "能够进入他人梦境的特殊能力者，记录人类潜意识的奥秘",
                "掌握量子计算的天才诗人，用算法创作美丽诗篇",
                "不受地域限制的数字游民，在网络世界中寻找自我",
                "拥有读取他人情感能力的心灵捕手，帮助人们解决情感困扰",
                "热爱大自然的观察者，记录地球上即将消失的美好",
                "能够预见未来的预言家，试图引导人类走向光明"
            ].randomElement()!
            
            let allInterests = [
                "宇宙探索", "哲学思考", "艺术创作", "科学研究",
                "历史文化", "数字技术", "心灵成长", "自然保护",
                "文学阅读", "音乐欣赏", "旅行冒险", "美食烹饪",
                "摄影艺术", "编程开发", "环境保护", "社会公益"
            ]
            
            interests = allInterests.shuffled().prefix(3).map { $0 }
            
            isGenerating = false
        }
    }
}
