import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SafeWebView extends StatelessWidget {
  // const SafeWebView({super.key});
  String? url;
  SafeWebView({this.url});
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: WebView(initialUrl:url,));
  }
}
