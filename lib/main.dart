import 'package:flutter/material.dart';
import 'package:loadmore/loadmore/load_more.dart';
import 'package:loadmore/loadmore/pull_refresh.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PullRefreshBox(
        onRefresh: () async => Future.delayed(Duration(seconds: 2)),
        child: LoadMoreBox(
          onLoad: () async => Future.delayed(Duration(seconds: 2)),
          child: ListView.separated(
            /// 设置physics属性
            /// 在条目比较少不足满屏时，刷新、加载将被禁止 条目较多满屏时不影响 扔可以 刷新和加载 。
//            physics: ClampingScrollPhysics(),
            itemCount: 5,
            itemBuilder: (ctx, index) => ListTile(
                  title: Text("$index"),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                ),
            separatorBuilder: (ctx, index) => Divider(
                  color: Colors.green,
                  height: 0.5,
                ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
