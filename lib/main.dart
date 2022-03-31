import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// shared_preferences

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late WebViewController _controller;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  // flutter 並列処理 isolate で検索

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                _controller.goBack();
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                _controller.goForward();
              },
            ),
            IconButton(
              icon: const Icon(Icons.autorenew),
              onPressed: () {
                // https://api.flutter.dev/flutter/dart-async/Timer/Timer.periodic.html
                Timer.periodic(
                    Duration(seconds: 10),
                    (timer) {
                      _controller.reload();
                    }
                );
                // ここら辺のボタン押下でメソッドを実行すればいいのか？
              },
            ),
          ],
        ),
      ),

      body: Builder(builder: (BuildContext context) {
        return WebView(
          // onWebViewCreatedはWebViewが生成された時に行う処理を記述できます
          onWebViewCreated: (WebViewController webViewController) async {
            _controller = webViewController; // 生成されたWebViewController情報を取得する
          },
          initialUrl: 'https://yahoo.co.jp',
          userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.74 Safari/537.36',
          javascriptMode: JavascriptMode.unrestricted,
          onPageFinished: (String url) {
            print('Page finished loading: $url');
            final aaa = _controller.runJavascriptReturningResult('document.getElementsByTagName("html")[0].outerHTML;');
            aaa.then((String? result) {
              debugPrint('eval: $result');
            });
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

}
