import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListViewDynamicExample extends StatelessWidget {
  late List<String> mList;

  ListViewDynamicExample() {
    mList = new List<String>.generate(500, (index) => "Item $index");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "动态列表",
      home: Scaffold(
        appBar: AppBar(
          title: Text("动态列表"),
        ),
        body: ListView.builder(
          itemCount: mList.length,
          itemBuilder: (context, index) {
            return new ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text("${mList[index]}"),
            );
          },
        ),
      ),
    );
  }
}
