import WebKit
import Foundation

class KangwonWebCoordinator: NSObject, WKNavigationDelegate {
    private let kangwonCallback: (KangwonWebStatus) -> Void
    private var kangwonDidStart = false

    init(onStatus: @escaping (KangwonWebStatus) -> Void) {
        self.kangwonCallback = onStatus
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if !kangwonDidStart { kangwonCallback(.progressing(progress: 0.0)) }
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        kangwonDidStart = false
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        kangwonCallback(.finished)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        kangwonCallback(.failure(reason: error.localizedDescription))
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        kangwonCallback(.failure(reason: error.localizedDescription))
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .other && webView.url != nil {
            kangwonDidStart = true
        }
        decisionHandler(.allow)
    }
}
