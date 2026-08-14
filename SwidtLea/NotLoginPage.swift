//
//  NotLoginPage.swift
//  SwiftNew
//
//  Created by 刘洪亮 on 2026/8/13.
//

import SwiftUI

struct NotLoginPage: View {
    @EnvironmentObject var router: Router
    let pageTitle:String
    var body: some View {
        VStack(spacing: 30){
            Text("Hi, Player")
                .font(.largeTitle)
            Text("你还没有登录，登录后查看更多精彩内容")
                .font(.title3)
                .foregroundStyle(.gray)
            QnButton(title: "去登录", type: .primary) {
                router.push(.login)
            }
            .padding(.horizontal, 30)
        }
        .padding()
            
    }
}

#Preview {
    NotLoginPage(pageTitle: "页面名称")
}
