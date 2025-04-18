//
//  ChatView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 18/4/25.
//

import SwiftUI
@preconcurrency import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        var request = URLRequest(url: url)
        let username = "user"
        let password = "password"
        if let authString = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() {
            request.setValue("Basic \(authString)", forHTTPHeaderField: "Authorization")
        }
        uiView.load(request)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        // Desafío de autenticación (por si la autenticación en cabecera no funciona)
        func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            let username = "user"
            let password = "password"
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
                let credential = URLCredential(user: username,
                                               password: password,
                                               persistence: .forSession)
                completionHandler(.useCredential, credential)
            } else {
                completionHandler(.performDefaultHandling, nil)
            }
        }
    }
}

struct ChatView: View {
    let url: URL
    
    var body: some View {
        ZStack {
            WebView(url: url)
                .edgesIgnoringSafeArea(.bottom)
                .navigationTitle("Chat")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ChatView(url: URL(string: "/webhook/c4a01150-dc0d-4340-82ab-4c79f6344a06/chat")!)
}
