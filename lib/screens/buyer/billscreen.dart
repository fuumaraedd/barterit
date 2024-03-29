import 'dart:async';

import 'package:flutter/material.dart';
import 'package:barterit/models/user.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BillScreen extends StatefulWidget {
  final User user;

  final double totalprice;

  const BillScreen({super.key, required this.user, required this.totalprice});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Bill"),
        ),
        body: Center(
          child: WebView(
            initialUrl:
                'https://fuumaraed.com/barteritV2/php/payment.php?sellerid=${widget.user.id}&userid=${widget.user.id}&email=${widget.user.email}&phone=${widget.user.phone}&name=${widget.user.name}&amount=${widget.totalprice}',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            onProgress: (int progress) {},
            onPageStarted: (String url) {},
            onPageFinished: (String url) {
              setState(() {});
            },
          ),
        ));
  }
}
