//
//  DiscoverDetailView.swift
//  SwiftNew
//
//  Created by QIAEN on 2026/8/14.
//

import SwiftUI

/// 活动详情页（参考 Web 端 act-details.vue）
struct DiscoverDetailView: View {
    let eventId: String
    
    @State private var detail: EventDetail?
    @State private var materials: [MaterialItem] = []
    @State private var isLoading = true
    @State private var loadFailed = false
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView("加载中…")
                    .frame(maxWidth: .infinity, minHeight: 300)
            } else if let detail {
                content(detail)
            } else if loadFailed {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("加载失败")
                        .font(.headline)
                    Button("重试") {
                        Task { await loadData() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, minHeight: 300)
            }
        }
        .background(.bgLightGray)
        .navigationTitle("活动详情")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            await loadData()
        }
    }
    
    @ViewBuilder
    private func content(_ detail: EventDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // 信息卡片
            VStack(alignment: .leading, spacing: 0) {
                // Banner
                CachedAsyncImage(urlString: detail.bannerUrl) {
                    ZStack {
                        Color.gray.opacity(0.2)
                        ProgressView()
                    }
                }
                .frame(height: 180)
                .clipped()
                .overlay(alignment: .topTrailing) {
                    statusBadge(detail)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // 标题
                    Text(detail.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    // 信息列表
                    infoRow(
                        icon: "calendar",
                        title: "提交窗口",
                        value: "\(detail.startAt.toLocalTimeString()) → \(detail.endAt.toLocalTimeString())"
                    )
                    
                    infoRow(
                        icon: "globe.asia.australia",
                        title: "地区",
                        value: detail.countryScope.values.joined(separator: ", ")
                    )
                    
                    // 平台
                    if !detail.platforms.values.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("平台")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                            HStack(spacing: 8) {
                                ForEach(detail.platforms.values, id: \.self) { platform in
                                    Image(platform)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(Color(.white))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // 活动规则
            VStack(alignment: .leading, spacing: 12) {
                Text("活动规则")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)
                
                MarkdownText(text: detail.rulesText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color(.white))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            // 活动素材
            if !materials.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("活动素材")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                        spacing: 12
                    ) {
                        ForEach(materials) { material in
                            MaterialCard(material: material)
                        }
                    }
                }
                .padding(16)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    /// 状态角标
    private func statusBadge(_ detail: EventDetail) -> some View {
        Text(detail.eventStatus.displayName)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(detail.eventStatus.badgeForeground)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(detail.eventStatus.badgeBackground))
            .padding(10)
    }
    
    /// 信息行
    private func infoRow(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 13))
            }
            .foregroundStyle(.secondary)
            
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func loadData() async {
        isLoading = true
        loadFailed = false
        
        await withCheckedContinuation { continuation in
            DiscoverService.shared.getEventDetail(eventId: eventId) { result in
                switch result {
                case .success(let response):
                    if response.result, let event = response.data?.event {
                        detail = event
                    } else {
                        loadFailed = true
                    }
                case .failure(let error):
                    print("获取活动详情失败: \(error)")
                    loadFailed = true
                }
                continuation.resume()
            }
        }
        
        await withCheckedContinuation { continuation in
            DiscoverService.shared.getMaterials(eventId: eventId) { result in
                if case .success(let response) = result, response.result {
                    materials = response.data?.list ?? []
                }
                continuation.resume()
            }
        }
        
        isLoading = false
    }
}

// MARK: - 素材卡片
struct MaterialCard: View {
    let material: MaterialItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 缩略图
            if let thumb = material.thumbnailUrl, !thumb.isEmpty {
                CachedAsyncImage(urlString: thumb) {
                    placeholder
                }
                .frame(height: 90)
                .clipped()
            } else {
                placeholder
                    .frame(height: 90)
            }
            
            Text(material.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            HStack(spacing: 4) {
                Text(material.type)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                if let size = material.fileSize, size > 0 {
                    Text("·")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    Text(size.fileSizeString)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.bgLightGray))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var placeholder: some View {
        ZStack {
            Color.gray.opacity(0.15)
            Image(systemName: "doc.zipper")
                .font(.system(size: 24))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Markdown 文本组件（行级渲染，SwiftUI + Foundation 原生解析，无第三方依赖）
/// 按行拆分渲染，换行 100% 可靠；行内 markdown（粗体/斜体/行内代码/链接）用
/// `AttributedString` 的 `inlineOnlyPreservingWhitespace` 解析。
struct MarkdownText: View {
    let text: String
    var baseSize: CGFloat = 15
    var baseColor: Color = .primary

    var body: some View {
        Group {
            if text.isEmpty {
                Text("暂无规则")
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                        blockView(block)
                    }
                }
            }
        }
        .font(.system(size: baseSize))
        .foregroundStyle(baseColor)
        .textSelection(.enabled)
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: 块解析

    private enum Block {
        case heading(level: Int, text: String)
        case paragraph(text: String)
        case bullet(items: [String])
        case ordered(items: [String])
        case quote(text: String)
        case code(text: String)
        case spacer
    }

    private var blocks: [Block] {
        Self.parseBlocks(text)
    }

    /// 把 markdown 按块级语法拆分为块序列
    private static func parseBlocks(_ source: String) -> [Block] {
        let lines = source.components(separatedBy: .newlines)
        var blocks: [Block] = []
        var i = 0

        while i < lines.count {
            let trimmed = lines[i].trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else {
                blocks.append(.spacer)
                i += 1
                continue
            }

            // 代码块
            if trimmed.hasPrefix("```") {
                var codeLines: [String] = []
                i += 1
                while i < lines.count,
                      !lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                    codeLines.append(lines[i])
                    i += 1
                }
                i += 1 // 跳过结尾 ```
                blocks.append(.code(text: codeLines.joined(separator: "\n")))
                continue
            }

            // 标题
            if let level = headingLevel(trimmed) {
                let content = trimmed.dropFirst(level).trimmingCharacters(in: .whitespaces)
                blocks.append(.heading(level: level, text: content))
                i += 1
                continue
            }

            // 无序列表（连续项合并）
            if bulletMarker(trimmed) != nil {
                var items: [String] = []
                while i < lines.count, let m = bulletMarker(lines[i].trimmingCharacters(in: .whitespaces)) {
                    let t = lines[i].trimmingCharacters(in: .whitespaces)
                    items.append(String(t.dropFirst(m.count)).trimmingCharacters(in: .whitespaces))
                    i += 1
                }
                blocks.append(.bullet(items: items))
                continue
            }

            // 有序列表（连续项合并）
            if orderedMarker(trimmed) != nil {
                var items: [String] = []
                while i < lines.count, let m = orderedMarker(lines[i].trimmingCharacters(in: .whitespaces)) {
                    let t = lines[i].trimmingCharacters(in: .whitespaces)
                    items.append(String(t.dropFirst(m)).trimmingCharacters(in: .whitespaces))
                    i += 1
                }
                blocks.append(.ordered(items: items))
                continue
            }

            // 引用（连续行合并）
            if trimmed.hasPrefix(">") {
                var quoteLines: [String] = []
                while i < lines.count {
                    let t = lines[i].trimmingCharacters(in: .whitespaces)
                    guard t.hasPrefix(">") else { break }
                    quoteLines.append(String(t.dropFirst()).trimmingCharacters(in: .whitespaces))
                    i += 1
                }
                blocks.append(.quote(text: quoteLines.joined(separator: "\n")))
                continue
            }

            // 普通段落（连续普通行合并，保留换行）
            var paraLines: [String] = []
            while i < lines.count {
                let t = lines[i].trimmingCharacters(in: .whitespaces)
                if t.isEmpty || t.hasPrefix("```") || t.hasPrefix(">") ||
                    headingLevel(t) != nil || bulletMarker(t) != nil || orderedMarker(t) != nil {
                    break
                }
                paraLines.append(lines[i])
                i += 1
            }
            blocks.append(.paragraph(text: paraLines.joined(separator: "\n")))
        }
        return blocks
    }

    private static func headingLevel(_ t: String) -> Int? {
        let count = t.prefix(while: { $0 == "#" }).count
        guard (1...6).contains(count), t.count > count else { return nil }
        let rest = t.dropFirst(count)
        return rest.first == " " ? count : nil
    }

    private static func bulletMarker(_ t: String) -> String? {
        for m in ["- ", "* ", "+ "] where t.hasPrefix(m) { return m }
        return nil
    }

    private static func orderedMarker(_ t: String) -> Int? {
        guard let range = t.range(of: #"^\d+[.)]\s"#, options: .regularExpression) else { return nil }
        return t.distance(from: t.startIndex, to: range.upperBound)
    }

    // MARK: 渲染

    @ViewBuilder
    private func blockView(_ block: Block) -> some View {
        switch block {
        case .heading(let level, let text):
            Text(inline(text))
                .font(.system(size: Self.headingSize(level), weight: .bold))
                .foregroundStyle(.baseGreen)
                .padding(.top, level <= 2 ? 4 : 0)

        case .paragraph(let text):
            Text(inline(text))
                .fixedSize(horizontal: false, vertical: true)

        case .bullet(let items):
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("•")
                        Text(inline(item))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

        case .ordered(let items):
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(index + 1).")
                            .foregroundStyle(.secondary)
                        Text(inline(item))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

        case .quote(let text):
            Text(inline(text))
                .padding(.leading, 10)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(.secondary.opacity(0.4))
                        .frame(width: 3)
                }
                .fixedSize(horizontal: false, vertical: true)

        case .code(let text):
            Text(text.isEmpty ? " " : text)
                .font(.system(size: baseSize - 1, design: .monospaced))
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.black))
                .clipShape(RoundedRectangle(cornerRadius: 8))

        case .spacer:
            Color.clear.frame(height: 6)
        }
    }

    private static func headingSize(_ level: Int) -> CGFloat {
        switch level {
        case 1: return 22
        case 2: return 19
        case 3: return 17
        default: return 15
        }
    }

    /// 行内 markdown 解析：保留空白（换行不被折叠），只解析行内语法
    private func inline(_ s: String) -> AttributedString {
        (try? AttributedString(
            markdown: s,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlineOnlyPreservingWhitespace,
                failurePolicy: .returnPartiallyParsedIfPossible
            )
        )) ?? AttributedString(s)
    }
}

// MARK: - 工具扩展
extension String {
    /// UTC 时间字符串转本地时间 "yyyy-MM-dd HH:mm"，解析失败原样返回。
    /// 兼容：ISO8601（带/不带毫秒）、无时区 "yyyy-MM-dd HH:mm:ss" / "yyyy-MM-dd HH:mm"
    func toLocalTimeString() -> String {
        // ISO8601（带毫秒）
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: self) {
            return Self.formatLocal(date)
        }
        // ISO8601（无毫秒）
        let isoNoFrac = ISO8601DateFormatter()
        isoNoFrac.formatOptions = [.withInternetDateTime]
        if let date = isoNoFrac.date(from: self) {
            return Self.formatLocal(date)
        }
        // 无时区格式：视为本地时间，仅重排格式
        let local = DateFormatter()
        local.dateFormat = "yyyy-MM-dd HH:mm:ss"
        local.locale = Locale(identifier: "en_US_POSIX")
        if let date = local.date(from: self) {
            return Self.formatLocal(date)
        }
        local.dateFormat = "yyyy-MM-dd HH:mm"
        if let date = local.date(from: self) {
            return Self.formatLocal(date)
        }
        return self
    }

    /// 输出本地时间 "yyyy-MM-dd HH:mm"
    private static func formatLocal(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}

extension Double {
    /// 文件大小展示，如 1.2 MB
    var fileSizeString: String {
        ByteCountFormatter.string(fromByteCount: Int64(self), countStyle: .file)
    }
}

#Preview {
    NavigationStack {
        DiscoverDetailView(eventId: "38085bf1814144dfa66ad7e126d4d21a")
    }
}
