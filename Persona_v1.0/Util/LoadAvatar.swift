//
//  LoadAvatar.swift
//  Persona_v1.0
//
//  Created by 邹坤 on 2025/11/21.
//

import SwiftUI


func loadAvatarFromAssets(imageName: String) -> Image {
    
    let placeholderSystemImage: String = "person.circle.fill"
    
    let imageExists = UIImage(named: imageName) != nil
    
    if imageExists {
        return Image(imageName)
    } else {
        // 加载失败返回默认图标
        return Image(systemName: placeholderSystemImage)
    }
}


///- Parameters:
/// - imageName: 头像图片的名称
/// - size: 头像尺寸，默认为 40x40
///- Returns: 包含头像的 SwiftUI 视图
func loadAvatar (
    imageName: String,
    size: CGFloat = 40
) -> some View {
    
    loadAvatarFromAssets(imageName: imageName)
        .resizable ()
        .scaledToFill ()
        .frame (width: size, height: size)
        .clipShape (Circle ())
        .overlay (Circle ().stroke (Color.white, lineWidth: 2))
        .shadow (radius: 3)
        .accessibilityLabel ("用户头像")
}
