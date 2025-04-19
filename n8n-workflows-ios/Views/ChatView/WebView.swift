//
//  WebView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 19/4/25.
//

import SwiftUI
@preconcurrency import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    var user: String?
    var password: String?
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let user, let password else {
            uiView.load(URLRequest(url: url))
            return
        }
        var request = URLRequest(url: url)
        if let authString = "\(user):\(password)".data(using: .utf8)?.base64EncodedString() {
            request.setValue("Basic \(authString)", forHTTPHeaderField: "Authorization")
        }
        uiView.load(request)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic,
                  let user = parent.user,
                  let password = parent.password else {
                completionHandler(.performDefaultHandling, nil)
                return
            }
            let credential = URLCredential(user: user,
                                           password: password,
                                           persistence: .forSession)
            completionHandler(.useCredential, credential)
        }
    }
}
