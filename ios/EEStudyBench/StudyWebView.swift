import SwiftUI
import UIKit
import WebKit
import UniformTypeIdentifiers

/// Serves the bundled `www` folder under the custom `eebench://` scheme.
/// A fixed origin means localStorage (progress, saved mistakes, exam history,
/// theme) persists between launches, exactly as it does in a browser.
final class BundleSchemeHandler: NSObject, WKURLSchemeHandler {
    static let scheme = "eebench"
    private let root: URL

    init(root: URL) {
        self.root = root.standardizedFileURL
    }

    func webView(_ webView: WKWebView, start task: WKURLSchemeTask) {
        guard let url = task.request.url else {
            task.didFailWithError(URLError(.badURL))
            return
        }
        var path = url.path
        if path.isEmpty || path == "/" { path = "/index.html" }
        let file = root.appendingPathComponent(String(path.dropFirst())).standardizedFileURL
        guard file.path.hasPrefix(root.path), let data = try? Data(contentsOf: file) else {
            task.didFailWithError(URLError(.fileDoesNotExist))
            return
        }
        var mime = UTType(filenameExtension: file.pathExtension)?.preferredMIMEType ?? "application/octet-stream"
        if file.pathExtension == "webmanifest" { mime = "application/manifest+json" }
        if mime.hasPrefix("text/") { mime += "; charset=utf-8" }
        let headers = ["Content-Type": mime, "Content-Length": String(data.count), "Cache-Control": "no-cache"]
        guard let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers) else {
            task.didFailWithError(URLError(.cannotParseResponse))
            return
        }
        task.didReceive(response)
        task.didReceive(data)
        task.didFinish()
    }

    func webView(_ webView: WKWebView, stop task: WKURLSchemeTask) {}
}

/// Full-screen web view that runs the study app.
struct StudyWebView: UIViewRepresentable {

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        guard let root = Bundle.main.url(forResource: "www", withExtension: nil) else {
            fatalError("The www folder is missing from the app bundle.")
        }

        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(BundleSchemeHandler(root: root), forURLScheme: BundleSchemeHandler.scheme)
        config.websiteDataStore = .default()

        // Light haptic feedback when an answer is marked right or wrong.
        let haptics = """
        new MutationObserver(function (list) {
          for (const m of list) for (const n of m.addedNodes) {
            if (!(n instanceof Element)) continue;
            const pill = n.matches('.pill') ? n : n.querySelector('.pill');
            if (pill && window.webkit && webkit.messageHandlers.haptic) {
              webkit.messageHandlers.haptic.postMessage(pill.classList.contains('ok') ? 'success' : 'error');
            }
          }
        }).observe(document.documentElement, { childList: true, subtree: true });
        """
        let controller = WKUserContentController()
        controller.addUserScript(WKUserScript(source: haptics, injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        controller.add(context.coordinator, name: "haptic")
        config.userContentController = controller

        let webView = WKWebView(frame: .zero, configuration: config)
        let background = UIColor(named: "LaunchBackground") ?? .systemBackground
        webView.isOpaque = false
        webView.backgroundColor = background
        webView.scrollView.backgroundColor = background
        webView.scrollView.contentInsetAdjustmentBehavior = .never   // the page handles safe areas itself
        webView.allowsBackForwardNavigationGestures = false
        webView.navigationDelegate = context.coordinator
        if #available(iOS 16.4, *) {
            webView.isInspectable = true   // allows Safari > Develop debugging
        }

        if let start = URL(string: "\(BundleSchemeHandler.scheme)://app/index.html") {
            webView.load(URLRequest(url: start))
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        private let notify = UINotificationFeedbackGenerator()

        func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "haptic", let kind = message.body as? String else { return }
            notify.notificationOccurred(kind == "success" ? .success : .error)
        }

        /// Keep the app on its own pages; open any outside link in Safari.
        func webView(_ webView: WKWebView,
                     decidePolicyFor action: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = action.request.url else { return decisionHandler(.cancel) }
            if url.scheme == BundleSchemeHandler.scheme || url.scheme == "about" {
                decisionHandler(.allow)
            } else {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            }
        }

        /// Reload if iOS ends the web content process while the app is in the background.
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            webView.reload()
        }
    }
}
