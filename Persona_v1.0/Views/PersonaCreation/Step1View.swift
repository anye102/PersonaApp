//
//  Step1View.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/24.
//

import SwiftUI

struct Step1View: View {
    @Binding var name: String
    @Binding var personality: String
    var nextStep: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("第一步：基本信息")
                .font(.title)
                .fontWeight(.bold)
            
            TextField("Persona名称", text: $name)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            TextField("性格特点", text: $personality)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: nextStep) {
                    Text("下一步")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(name.isEmpty || personality.isEmpty)
            }
            .padding()
        }
    }
}
