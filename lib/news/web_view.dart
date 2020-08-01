import 'package:chrona_1/news/model/news.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
class WebView extends StatefulWidget {
  final String url;
 // final Source source;
  final String src;
 // WebView.account(this.url,this.src,);


  WebView(this.url, this.src);

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebView> {


  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      appBar: AppBar(
        title: Text(widget.src),
        // backgroundColor: Colors.black,
      ),
      url: widget.url,
    );
  }


}
