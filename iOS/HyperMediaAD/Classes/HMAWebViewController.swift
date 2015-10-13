import UIKit


/// MARK: - HMAWebViewController
class HMAWebViewController: UIViewController {

    /// MARK: - property

    /// URL
    var initialURL: NSURL?

    // indicator view
    var indicatorView: TYMActivityIndicatorView!
    /// webview
    @IBOutlet weak var webView: UIWebView!


    /// MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.initialURL != nil {
            let request: NSURLRequest = NSURLRequest(URL: self.initialURL!)
            self.webView.loadRequest(request)
        }

        // indicator
        self.indicatorView = TYMActivityIndicatorView(activityIndicatorStyle: TYMActivityIndicatorViewStyle.Normal)
        self.indicatorView.hidesWhenStopped = true
        self.indicatorView.stopAnimating()
        self.indicatorView.center = self.webView.center
        self.webView.addSubview(self.indicatorView)
    }


    /// MARK: - event listener
    @IBAction func touchedUpInside(barButtonItem barButtonItem: UIBarButtonItem) {
        self.navigationController!.dismissViewControllerAnimated(true, completion: {})
    }

}



/// MARK: - UIWebViewDelegate
extension HMAWebViewController: UIWebViewDelegate {

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }

    func webViewDidStartLoad(webView: UIWebView) {
        self.indicatorView.startAnimating()
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        self.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        self.indicatorView.stopAnimating()
    }

    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.title = ""
        self.indicatorView.stopAnimating()
    }
}
