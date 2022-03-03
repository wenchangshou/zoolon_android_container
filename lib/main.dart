import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("app_settings");
  runApp(MyApp());
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  // String url = "http://www.baidu.com";
  String url = GlobalConfiguration().getValue("startup");
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      home: MyHomePage(title: 'vd control page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebViewController controllerGlobal;
  TextEditingController _textFieldController = TextEditingController();
  // var _url = 'http://192.168.1.33:6070/control.html';
  String _url = GlobalConfiguration().getValue("startup");
  String valueText = '';

  void naviate(url) {
    Future.delayed(Duration(milliseconds: 1000), () {
      controllerGlobal.loadUrl(url);
    });
  }

  Future<void> _setUri(url) async {
    print('seturl:' + url);
    // obtain shared preferences
    // final prefs = await SharedPreferences.getInstance();
    GlobalConfiguration().updateValue("startup", url);
    naviate(url);
  }

  @override
  void initState() {
    super.initState();
    // loadUrl();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  // void _showInputDialog(BuildContext context) {}

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('设置启动页'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Text Field in Dialog"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                _setUri(_textFieldController.text);
                print(_textFieldController.text);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return new Scaffold(
        // appBar: new AppBar(title: new Text('Welcome to flutter222')),
        drawer: new Drawer(
          child: new Column(
            // padding: EdgeInsets.zero,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              new TextButton(
                  onPressed: () {
                    _displayTextInputDialog(context);
                  },
                  child: new Text('跳转')),
              SizedBox(
                  height: 100,
                  child: ListView(
                    children: [
                      ListTile(
                        title: const Text('百度'),
                        onTap: () {
                          // Update the state of the app
                          // ...
                          // Then close the drawer
                          _setUri('http://www.baidu.com');
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('雅虎'),
                        onTap: () {
                          // Update the state of the app
                          // ...
                          // Then close the drawer
                          _setUri('http://www.163.com');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ))
            ],
          ),
        ),
        body: Container(
            // width: double.infinity,

            child: WebView(
          onWebViewCreated: (webViewController) {
            controllerGlobal = webViewController;
          },
          onWebResourceError: (WebResourceError webviewerrr) {
            print("Handle your Error Page here");
          },
          initialUrl: _url,
          javascriptMode: JavascriptMode.unrestricted,
          onPageFinished: (String url) {
            print('Page finished loading:');
          },
        )));
  }
}
