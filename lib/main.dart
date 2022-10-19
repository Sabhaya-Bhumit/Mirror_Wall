import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ott_platforms/bookmark.dart';
import 'package:ott_platforms/global.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: Color(0xff588157),
        primary: Color(0xff3a5a40),
        onSecondary: Color(0xffffffff),
      )),
      routes: {
        '/': (context) => home(),
        'bookmark': (context) => bookmark(),
      },
    ),
  );
}

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}

late InAppWebViewController inAppWebViewController;
late PullToRefreshController pullToRefreshController;
bool isback = false;
bool isforwer = false;
int select = 0;
int onselect = 0;
double _progress = 0;

class _homeState extends State<home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        if (Platform.isAndroid) {
          await inAppWebViewController.reload();
        } else {
          Uri? uri = await inAppWebViewController.getUrl();
          await inAppWebViewController.loadUrl(
              urlRequest: URLRequest(url: uri));
        }
      },
      options: PullToRefreshOptions(color: Colors.lightBlue),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Color(0xff3a5a40),
          title: Text("OTT websites", style: TextStyle(fontSize: 15)),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () async {
                  await inAppWebViewController.loadUrl(
                      urlRequest: URLRequest(
                          url: Uri.parse("${global.all_websites[0]['uri']}")));
                },
                icon: const Icon(Icons.home)),
            (isback == true)
                ? IconButton(
                    onPressed: () async {
                      select = 0;
                      onselect = 0;
                      if (await inAppWebViewController.canGoBack()) {
                        await inAppWebViewController.goBack();
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios))
                : Container(),
            IconButton(
                onPressed: () async {
                  if (Platform.isIOS) {
                    Uri? uri = await inAppWebViewController.getUrl();
                    await inAppWebViewController.loadUrl(
                        urlRequest: URLRequest(url: uri));
                  } else {
                    await inAppWebViewController.reload();
                  }
                },
                icon: const Icon(Icons.refresh)),
            (isforwer == true)
                ? IconButton(
                    onPressed: () async {
                      if (await inAppWebViewController.canGoForward()) {
                        await inAppWebViewController.goForward();
                      }
                    },
                    icon: const Icon(Icons.arrow_forward_ios_sharp))
                : Container(),
          ],
        ),
        drawer: Drawer(
          child: Column(
            children: [
              Expanded(
                  child: Container(
                width: double.infinity,
                color: Color(0xff588157),
                alignment: Alignment.center,
                child: Text(
                  "\n\n\nEducational websites",
                  style: TextStyle(fontSize: 29, fontWeight: FontWeight.bold),
                ),
              )),
              SizedBox(height: 10),
              Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    color: Color(0xffa3b18a),
                    child: ListView.separated(
                        separatorBuilder: (context, index) => Column(
                              children: [
                                Divider(thickness: 5, color: Colors.black),
                                SizedBox(height: 3)
                              ],
                            ),
                        itemCount: global.all_websites.length,
                        itemBuilder: (context, i) => InkWell(
                              onTap: () {
                                setState(() {
                                  select = i;

                                  inAppWebViewController.loadUrl(
                                      urlRequest: URLRequest(
                                          url: Uri.parse(
                                              global.all_websites[i]['uri'])));
                                  Navigator.of(context).pop();
                                });
                              },
                              child: Container(
                                height: 100,
                                alignment: Alignment.center,
                                child: Text(
                                  "${global.all_websites[i]['name']}",
                                  style: TextStyle(
                                      color: (select == i)
                                          ? Colors.white
                                          : Colors.black),
                                ),
                              ),
                            )),
                  )),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
                heroTag: null,
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text("Search"),
                            content: TextFormField(
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder()),
                              onChanged: (val) {
                                inAppWebViewController.loadUrl(
                                    urlRequest: URLRequest(
                                        url: Uri.parse(
                                            "https://www.google.co.in/search?q=$val")));
                              },
                            ),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("save"))
                            ],
                          ));
                },
                child: const Icon(Icons.search)),
            const SizedBox(width: 10),
            FloatingActionButton(
                heroTag: null,
                onPressed: () async {
                  Uri? uri = await inAppWebViewController.getUrl();
                  global.all_uri.add(uri.toString());
                },
                child: const Icon(Icons.bookmark_add)),
            const SizedBox(width: 10),
            FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  Navigator.of(context).pushNamed('bookmark');
                },
                child: const Icon(Icons.bookmark)),
            const SizedBox(width: 10),
            FloatingActionButton(
                heroTag: null,
                onPressed: () async {
                  await inAppWebViewController.stopLoading();
                },
                child: const Icon(Icons.cancel)),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            _progress < 1
                ? SizedBox(
                    height: 3,
                    child: LinearProgressIndicator(
                      value: _progress,
                    ),
                  )
                : SizedBox(),
            SizedBox(height: 5),
            Container(
                height: height * 0.87,
                child: InAppWebView(
                  initialOptions: InAppWebViewGroupOptions(
                      android: AndroidInAppWebViewOptions(
                          useHybridComposition: true)),
                  pullToRefreshController: pullToRefreshController,
                  initialUrlRequest: URLRequest(
                      url: Uri.parse("${global.all_websites[0]['uri']}")),
                  onWebViewCreated: (val) async {
                    inAppWebViewController = val;
                  },
                  onProgressChanged: (controller, i) async {
                    setState(() {
                      _progress = i / 100;
                    });
                    iscanback();

                    if (await inAppWebViewController.canGoForward()) {
                      setState(() {
                        isforwer = true;
                      });
                    } else {
                      setState(() {
                        isforwer = false;
                      });
                    }
                  },
                  onLoadStop: (context, uri) async {
                    await pullToRefreshController.endRefreshing();
                  },
                ))
          ],
        ));
  }

  iscanback() async {
    if (await inAppWebViewController.canGoBack()) {
      setState(() {
        isback = true;
      });
    } else {
      setState(() {
        isback = false;
      });
    }
  }
}
