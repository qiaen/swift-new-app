//
//  ZStackTest.swift
//  SwidtLea
//
//  Created by Qiaen on 2026/8/13.
//

import SwiftUI
// 自定义按钮 开始
struct QnButton: View {
    // MARK: - 枚举
    enum ButtonType {
        case `default`  // 默认：灰色边框，白色文字，透明背景
        case primary    // 主要：蓝色背景，蓝色边框，白色文字
        
        var backgroundColor: Color {
            switch self {
            case .default:
                return .clear
            case .primary:
                return .blue
            }
        }
        
        var borderColor: Color {
            switch self {
            case .default:
                return .gray.opacity(0.8)
            case .primary:
                return .blue
            }
        }
        
        var textColor: Color {
            switch self {
            case .default:
                return .white
            case .primary:
                return .white
            }
        }
    }
    
    // MARK: - 属性
    let iconName: String?
    let title: String
    let loading: Bool
    let type: ButtonType
    let cornerRadius: CGFloat
    let action: () -> Void
    
    // MARK: - 初始化
    init(
        iconName: String? = nil,
        title: String,
        loading: Bool = false,
        type: ButtonType = .default,
        cornerRadius: CGFloat = 8,
        action: @escaping () -> Void
    ) {
        self.iconName = iconName
        self.title = title
        self.loading = loading
        self.type = type
        self.cornerRadius = cornerRadius
        self.action = action
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if loading == true {
                    // 加载动画
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: type.textColor))
                        .scaleEffect(0.8)
                        .frame(width: 20, height: 20)
                } else if let iconName = iconName {
                    // 正常图标
                    Image(systemName: iconName)
                        .font(.body)
                }
                Text(title)
                    .font(.body)
            }
            .foregroundStyle(type.textColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(minHeight: 48)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(type.backgroundColor)
                    .stroke(type.borderColor, lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
            .opacity(loading == true ? 0.8 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(loading == true)
    }
}
// 自定义按钮 结束


struct OauthBox: View {
    @State private var loading = false
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack(spacing: 0) {
            HStack{
                Text("Hi Games")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
            }
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .background(.blue)
            
            VStack {
                Text("Hi Games")
                    .font(.title)
                    .foregroundStyle(.gray)
                    .padding(.top, 60)
                Text("Thank you for auth the game")
                    .font(.headline)
                    .foregroundStyle(.gray)
                    .padding(.top, 10)
                HStack(spacing: 16){
                    QnButton(iconName: "paperplane", title: "确认", loading: loading) {
                        withAnimation {
                            loading = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                loading = false
                            }
                        }
                    }
                    QnButton(title: "回首页", type: .primary) {
                        print("hello")
                        router.popRoot()
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
                
            }
            .frame(minHeight: 160)
            .frame(maxWidth: .infinity)
            .background(.black)
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding()
        .overlay(alignment:.top){
            Image(systemName: "livephoto.play")
                .foregroundStyle(.blue)
                .font(.largeTitle)
                .padding(14)
                .background(
                    Circle()
                        .fill(.white)
                        .stroke(.black, lineWidth:5)
                        .shadow(color: .blue, radius: 6)
                )
                .offset(y: 140)
        }
    }
}
struct ZStackTest: View {
    let userId: Int
    
    
    var body: some View {
        ScrollView {
            OauthBox()
                
        }
//            .frame(maxWidth: .infinity)
        .navigationTitle("层叠")
//        .background(.black.opacity(0.1))
    }
}


#Preview {
    ContentView()
}
