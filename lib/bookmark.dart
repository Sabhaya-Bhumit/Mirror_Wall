import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:web_brower_app/global.dart';
import 'package:web_brower_app/main.dart';

class bookmark extends StatefulWidget {
  const bookmark({Key? key}) : super(key: key);

  @override
  State<bookmark> createState() => _bookmarkState();
}

class _bookmarkState extends State<bookmark> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Book Mark")),
        body: ListView.separated(
            separatorBuilder: (context, index) => Column(
                  children: [
                    Divider(thickness: 5, color: Colors.black),
                    SizedBox(height: 20)
                  ],
                ),
            itemCount: global.all_uri.length,
            itemBuilder: (context, i) {
              int item = i;
              item = ++item;
              return ListTile(
                leading: CircleAvatar(
                  radius: 40,
                  child: Text("${item}"),
                ),
                title: GestureDetector(
                  onTap: () {
                    inAppWebViewController.loadUrl(
                        urlRequest:
                            URLRequest(url: Uri.parse("${global.all_uri[i]}")));
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "${global.all_uri[i]}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        global.all_uri.remove(global.all_uri[i]);
                      });
                    },
                    icon: Icon(Icons.delete)),
              );
            }));
  }
}
