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

struct ChatView: View {
    let chat: ChatTrigger
    
    private var user: String? {
        chat.authentication == .basic ? UserDefaultsHelper.shared.webhookAuthParam1 : nil
    }
    
    private var password: String? {
        chat.authentication == .basic ? UserDefaultsHelper.shared.webhookAuthParam2 : nil
    }
    
    var body: some View {
        if let baseUrl = UserDefaultsHelper.shared.hostUrl,
           let url = URL(string: baseUrl) {
            let chatUrl = url
                .appendingPathComponent("webhook")
                .appendingPathComponent(chat.id)
                .appendingPathComponent("chat")
            WebView(url: chatUrl, user: user, password: password)
                .edgesIgnoringSafeArea(.bottom)
                .navigationTitle("Chat")
                .navigationBarTitleDisplayMode(.inline)
        } else {
            ContentUnavailableCompatView(
                title: "No content available",
                description: "",
                systemImage: "message"
            )
        }
    }
}

#Preview {
    ChatView(chat: ChatTrigger(id: "", authentication: .noAuth))
}
