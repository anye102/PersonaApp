//
//  MessageBubble.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/24.
//

import SwiftUI
import MarkdownUI

struct MessageBubble: View {
    @EnvironmentObject var personaManager: PersonaManager
    let message: Message
    
    var body: some View {
        HStack(alignment: .bottom) {
            if message.isFromUser {
                Spacer()
                
                VStack(alignment: .trailing) {
//                    Text(message.senderName)
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                        .padding(.trailing, 8)
                    
                    Text(message.content)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .cornerRadius(0, corners: .bottomRight)
                        .font(.system(size: 15))
                }
            } else {
                HStack {
                    // 显示Markdown文本消息
                    Markdown(message.content)
                        .markdownTextStyle(\.text) {
                            FontSize(15)
                            ForegroundColor(.primary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(15)
//                        .cornerRadius(0, corners: .bottomLeading)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

// 扩展实现指定角的圆角
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
