// new Center(
//         // Center 可以将其子widget树对齐到屏幕中心
//         child: new Column(
//           // Column的作用是将其所有子widget沿屏幕垂直方向依次排列
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             new Text('多按几次'),
//             new Text(
//               '$_couter',
//               style: Theme.of(context).textTheme.display1,
//             ),
//             FlatButton(
//               child: Text('跳转新的路由'),
//               textColor: Colors.blue,
//               onPressed: () {
//                 // 导航到新路由
//                 //方法一
//                 Navigator.push(context,
//                     new MaterialPageRoute(builder: (context) {
//                   return new NewRoute();
//                 }));
//                 // MaterialPageRoute继承自PageRoute类，PageRoute类是一个抽象类，
//                 // 表示占有整个屏幕空间的一个模态路由页面，它还定义了路由构建及切换时过渡动画的相关接口及属性

//                 // 参数 builder 是一个WidgetBuilder类型的回调函数，它的作用是构建路由页面的具体内容，返回值是一个widget。
//                 // 我们通常要实现此回调，返回新路由的实例。

//                 // 方法二
//                 // 命名路由 见 MyApp -> MaterialApp -> routes;
//                 // Navigator.pushNamed(context, 'new_page');
//               },
//             ),
//             FlatButton(
//               child: Text('传递参数的路由'),
//               textColor: Colors.red,
//               onPressed: () {
//                 Navigator.of(context).pushNamed('new_page2', arguments: "我是参数");
//               },
//             ),
//             FlatButton(
//               child: Text('随机无限单词列表'),
//               textColor: Colors.green,
//               onPressed: () {
//                 Navigator.of(context).pushNamed('random_words');
//               },
//             ),
//             FlatButton(
//               child: Text('聊天'),
//               textColor: Colors.black,
//               onPressed: () {
//                 Navigator.of(context).pushNamed('chat');
//               },
//             ),
//             FlatButton(
//               child: Text('输入'),
//               textColor: Colors.pink,
//               onPressed: () {
//                 Navigator.of(context).pushNamed('input_page');
//               },
//             )
//           ],
//         ),
//       ),
//       // floatingActionButton是页面右下角的带“➕”的悬浮按钮，
//       // 它的onPressed属性接受一个回调函数，代表它被点击后的处理器，本例中直接将_incrementCounter作为其处理函数
//       floatingActionButton: new FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: '增加',
//         child: new Icon(Icons.add),
//       ),



///////////////////////// type==3 card
///// return ResponseUI(Card(
      //     // elevation: 5.0,
      //     // color: Colors.white,
      //     child: Column(
      //   mainAxisAlignment: MainAxisAlignment.start,
      //   children: <Widget>[
      //     Container(
      //       // padding: EdgeInsets.all(10),
      //       width: 160,
      //       alignment: Alignment.centerLeft,
      //       child: Text(
      //         info['title'],
      //         // textAlign: TextAlign.left,
      //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      //       ),
      //       padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      //     ),
      //     Container(
      //       width: 160,
      //       child: Text(
      //         info['desc'],
      //         overflow: TextOverflow.ellipsis,
      //         style: TextStyle(color: Colors.blueGrey[300]),
      //         maxLines: 2,
      //       ),
      //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      //     ),
      //     Container(
      //       width: 160,
      //       child: FlatButton(
      //         // padding: EdgeInsets.all(0),
      //         child: Text(
      //           '查看',
      //           style: TextStyle(
      //               color: Colors.blue,
      //               fontWeight: FontWeight.w700,
      //               fontSize: 14),
      //         ),
      //         onPressed: () => Navigator.of(context).push(MaterialPageRoute(
      //             builder: (context) => DiseaseDetail(int.parse(info['id'])))),
      //       ),
      //       alignment: Alignment.centerRight,
      //     ),
      //   ],
      // )));


      ////////////////////////////