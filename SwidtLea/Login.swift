//
//  Login.swift
//  SwiftNew
//
//  Created by 刘洪亮 on 2026/8/13.
//

import SwiftUI
// MARK:-- 自定义输入框开始
struct QnInput: View {
    // MARK: 属性
    let placeholder: String
    @Binding var text: String
    
    let cornerRadius: CGFloat
    let height: CGFloat
    
    // MARK: 初始化
    init(
        placeholder: String,
        text: Binding<String>,
        cornerRadius: CGFloat = 48,
        height: CGFloat = 48
    ) {
        self.placeholder = placeholder
        self._text = text
        self.cornerRadius = cornerRadius
        self.height = height
    }
    
    var body: some View {
        TextField("", text: $text)
            .placeholder(when: text.isEmpty) {
                Text(placeholder)
                    .foregroundColor(.gray.opacity(0.6))
            }
            .foregroundColor(.black)
            .padding(.horizontal, 20)
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.gray.opacity(0.7), lineWidth: 1)
            )
    }
}

// MARK: 扩展：TextField placeholder 修饰器
private struct TextFieldPlaceholderModifier: ViewModifier {
    let placeholder: Text
    let show: Bool
    
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if show { placeholder }
            content
                .foregroundColor(.clear)
        }
    }
}

extension View {
    func placeholder<Content: View>(when shouldShow: Bool, alignment: Alignment = .leading, placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK:-- 自定义输入框结束

// 自定义checkbox样式开始
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .stroke(.gray, lineWidth: 1.2)
                .frame(width: 18, height: 18)
                .overlay {
                    if configuration.isOn {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            
            configuration.label
                .foregroundStyle(configuration.isOn ? .blue : .gray)
        }
        .onTapGesture {
            withAnimation{
                configuration.isOn.toggle()
            }
        }
    }
}
// 自定义checkbox结束


struct Login: View {
    @EnvironmentObject var router: Router
    
    @State private var username = "liuholy@126.com"
    @State private var password = ""
    @State private var agree = false
    @State private var loading = false
    
    @State private var errorMessage: String?
    var body: some View {
        VStack(spacing: 25) {
            Text("Hello, ")
                .font(.largeTitle)
            + Text("Player")
                .font(.largeTitle)
                .foregroundStyle(.blue)
            
            QnInput(placeholder: "请输入邮箱", text: $username)
                .padding(.top)
            QnInput(placeholder: "请输入密码", text: $password)
            HStack {
                Toggle(isOn: $agree) {
                    Text("同意使用协议")
                }
                .toggleStyle(CheckboxToggleStyle())
                .padding(.leading)
                .padding(.bottom, -10)
                
                Spacer()
            }
            QnButton(iconName: "paperplane", title: "登录", loading:loading, type: .primary, cornerRadius: 48) {
                submitLogin()
            }
//            QnButton(iconName: "paperplane", title: "获取用户信息", type: .primary, cornerRadius: 48) {
//                fetchUser()
//            }
        }
        .padding()
    }
    private func submitLogin() {
        loading = true
        errorMessage = nil
        AuthService.shared.login(username: "bGl1aG9seUAxMjYuY29t", password: "QWNlb24xMjM0NQ==") { result in
            loading = false
            print("登录成功-------")
            router.pop()
        }
        
    }
    private func fetchUser() {
        // 使用 Service
        UserService.shared.getMe() { result in
            loading = false

            switch result {
            case .success(let response):
                if response.result, let data = response.data {
                    
                } else {
                    errorMessage = response.message
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    Login()
}
