import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:web_brower_app/bookmark.dart';
import 'package:web_brower_app/global.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const home(),
        'bookmark': (context) => const bookmark(),
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
bool isforword = false;
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
          title: const Text("Web Brower App"),
          actions: [
            IconButton(
                onPressed: () async {
                  await inAppWebViewController.loadUrl(
                      urlRequest: URLRequest(
                          url: Uri.parse("https://www.google.co.in")));
                },
                icon: const Icon(Icons.home)),
            (isback)
                ? IconButton(
                    onPressed: () async {
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
            (isforword)
                ? IconButton(
                    onPressed: () async {
                      if (await inAppWebViewController.canGoForward()) {
                        await inAppWebViewController.goForward();
                      }
                    },
                    icon: const Icon(Icons.arrow_forward_ios_sharp))
                : Container()
          ],
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
            Container(
              height: height * 0.8,
              child: InAppWebView(
                initialOptions: InAppWebViewGroupOptions(
                    android:
                        AndroidInAppWebViewOptions(useHybridComposition: true)),
                pullToRefreshController: pullToRefreshController,
                initialUrlRequest:
                    URLRequest(url: Uri.parse("https://www.google.co.in/")),
                onWebViewCreated: (val) {
                  inAppWebViewController = val;
                },
                onProgressChanged: (controller, progress) async {
                  setState(() {
                    _progress = progress / 100;
                  });
                  iscanback();
                  if (await inAppWebViewController.canGoForward()) {
                    setState(() {
                      isforword = true;
                    });
                  } else {
                    setState(() {
                      isforword = false;
                    });
                  }
                },
                onLoadStop: (context, uri) async {
                  await pullToRefreshController.endRefreshing();
                },
              ),
            ),
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
