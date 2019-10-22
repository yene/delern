import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void showDialogWithWebView(String url, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => Dialog(child: WebViewContainer(url)));
}

class WebViewContainer extends StatefulWidget {
  final String url;

  const WebViewContainer(this.url);

  @override
  _WebViewContainerState createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) => IndexedStack(
        index: _isLoading ? 1 : 0,
        children: <Widget>[
          WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.disabled,
            onPageFinished: (v) {
              _finishLoading();
            },
          ),
          ProgressIndicatorWidget(),
        ],
      );

  void _finishLoading() {
    setState(() {
      _isLoading = false;
    });
  }
}
