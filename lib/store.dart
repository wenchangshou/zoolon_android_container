import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Store {
  Map<String, dynamic> _urls = {};
  String _startup = "";
  Store();
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    // SharedPreferences.getInstance().then((value) {
    final s = prefs.getString("startup");
    // _startup = (s == null || s == "" ? s : 'http://www.baidu.com';
    startup = s!;
    var s2 = prefs.getString("urls");
    if (s2 != null && s2 != "") {
      _urls = jsonDecode(s2);
    }
    // });
  }

  void store() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("startup", _startup);
    String s = json.encode(_urls);
    prefs.setString("urls", s);
  }

  Map<String, dynamic> get urls {
    return _urls;
  }

  String get start {
    return _startup;
  }

  set startup(String url) {
    _startup = url;
  }

  void deleteUrl(String str) {
    urls.remove(str);
  }

  void appendUrl(String name, String val) {
    urls[name] = val;
  }
}
