import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:nmlt/listitem.dart';
import 'package:nmlt/store.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_easy_permission/easy_permissions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("app_settings");
  runApp(MyApp());
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    // SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }
}

class MyApp extends StatelessWidget {
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
  TextEditingController _nameFieldController = TextEditingController();
  TextEditingController _urlFieldController = TextEditingController();
  String valueText = '';
  Store store = new Store();
  late FlutterEasyPermission _easyPermission;
  static const permissionGroup = [
    PermissionGroup.MediaLibrary,
    PermissionGroup.DataNetwork,
  ];

  static const permissions = [
    Permissions.READ_EXTERNAL_STORAGE,
    Permissions.WRITE_EXTERNAL_STORAGE
  ];

  void naviate(url) {
    Future.delayed(Duration(milliseconds: 1000), () {
      controllerGlobal.loadUrl(url);
    });
  }

  @override
  void initState() {
    super.initState();
    store.load().then((v) {
      log(store.urls.toString());
      naviate(store.start);
    });
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    _easyPermission = FlutterEasyPermission()
      ..addPermissionCallback(onGranted: (requestCode, perms, perm) {
        debugPrint("android????????????:$perms");
        debugPrint("iOS????????????:$perm");
      }, onDenied: (requestCode, perms, perm, isPermanent) {
        if (isPermanent) {
          FlutterEasyPermission.showAppSettingsDialog(title: "Camera");
        } else {
          debugPrint("android????????????:$perms");
          debugPrint("iOS????????????:$perm");
        }
      }, onSettingsReturned: () {
        FlutterEasyPermission.has(perms: permissions, permsGroup: []).then(
            (value) => value
                ? debugPrint("???????????????:$permissions")
                : debugPrint("???????????????:$permissions"));
      });
  }

  // void _showInputDialog(BuildContext context) {}

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('???????????????'),
          // content: TextField(
          //   controller: _textFieldController,
          //   decoration: InputDecoration(hintText: "Text Field in Dialog"),
          // ),
          content: new Column(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  controller: _nameFieldController,
                  decoration: new InputDecoration(
                    labelText: '??????',
                  ),
                ),
              ),
              new Expanded(
                child: new TextField(
                  controller: _urlFieldController,
                  decoration: new InputDecoration(
                    labelText: '??????',
                  ),
                ),
              ),
            ],
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
                // _setUri(_textFieldController.text);
                print(_nameFieldController.text);
                print(_urlFieldController.text);
                String name = _nameFieldController.text;
                String url = _urlFieldController.text;
                store.appendUrl(name, url);
                store.store();
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void deleteUrl(String key) {
    store.deleteUrl(key);
    store.store();
    setState(() {});
  }

  void redirectUrl(String url) {
    store.startup = url;
    store.store();
    naviate(url);
    log('redirect url:' + url);
  }

  List<Widget> buildUrlListWidget() {
    List<Widget> results = [];
    for (MapEntry<String, dynamic> u in store.urls.entries) {
      results
          .add(new listItem(u.key, u.value.toString(), deleteUrl, redirectUrl));
    }
    return results;
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
            children: [
              Container(
                margin: EdgeInsets.only(top: 20),
              ),
              new TextButton(
                  onPressed: () {
                    FlutterEasyPermission.has(
                            perms: permissions, permsGroup: permissionGroup)
                        .then((value) {
                      if (!value) {
                        FlutterEasyPermission.request(
                            perms: permissions,
                            permsGroup: permissionGroup,
                            rationale: "????????????????????????");
                      }
                    });
                    _displayTextInputDialog(context);
                  },
                  child: new Text('??????')),
              SizedBox(
                  // height: 500,
                  height: MediaQuery.of(context).size.height - 150,
                  child: ListView(
                    children: buildUrlListWidget(),
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
          // initialUrl: _url,
          javascriptMode: JavascriptMode.unrestricted,
          onPageFinished: (String url) {
            print('Page finished loading:');
          },
        )));
  }

  @override
  void dispose() {
    _easyPermission.dispose();
    super.dispose();
  }
}
