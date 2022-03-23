import 'dart:developer';

import 'package:flutter/material.dart';

typedef deleteUrlCallback = void Function(String);

// ignore: must_be_immutable, camel_case_types
class listItem extends StatelessWidget {
  // void Function(String) deleteUrlCallback;
  listItem(String title, String url, Function(String) deleteCall,
      Function(String) redirectCall) {
    this.title = title;
    this.url = url;
    this.deleteCall = deleteCall;
    this.redirectCall = redirectCall;
  }

  var title;
  var url;
  var deleteCall;
  var redirectCall;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        this.deleteCall(title);
      },
      onTap: () {
        this.redirectCall(this.url);
      },
      child: ListTile(
        title: Text(this.title),
      ),
    );
  }
}
