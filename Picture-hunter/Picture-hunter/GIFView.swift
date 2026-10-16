//
//  GIFView.swift
//  Picture hunter
//
//  Created by cmStudent on 2026/10/16.
//

import SwiftUI
import WebKit

struct GIFView: UIViewRepresentable {
    let name: String   // 拡張子なしのファイル名

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.isUserInteractionEnabled = false

        if let url = Bundle.main.url(forResource: name, withExtension: "gif"),
           let data = try? Data(contentsOf: url) {
            webView.load(
                data,
                mimeType: "image/gif",
                characterEncodingName: "UTF-8",
                baseURL: url.deletingLastPathComponent()
            )
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
