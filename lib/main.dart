// 导入包
import 'dart:developer';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:hello_world/disease_search.dart';

// 应用入口，主要用来启动flutter 应用
void main() => runApp(
        // MultiProvider(
        //   providers: [
        //     ChangeNotifierProvider<Messages>.value(
        //       notifier: Messages(),
        //     ),
        //     ChangeNotifierProvider<Diseases>.value(
        //       notifier: Diseases(),
        //     ),
        //   ],
        //   child: new MyApp(),
        // )
        ChangeNotifierProvider<Messages>.value(
      child: new MyApp(),
      notifier: Messages(),
    ));

class MyApp extends StatelessWidget {
  // MyApp 是一个flutter 应用

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // 在Flutter中，大多数东西都是widget，包括对齐(alignment)、填充(padding)和布局(layout)。
    // Flutter在构建页面时，会调用组件的build方法，widget的主要工作是提供一个build()方法来描述如何构建UI界面（通常是通过组合、拼装其它基础widget）
    // MaterialApp 是Material库中提供的Flutter APP框架，通过它可以设置应用的名称、主题、语言、首页及路由列表等。MaterialApp也是一个widget。
    return new MaterialApp(
      title: 'AI医生',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InputPage(), //home 为Flutter应用的首页，它也是一个widget

      // 注册命名路由
      routes: {
        'new_page': (context) => NewRoute(),
        'new_page2': (context) => ArgsRoute(),
        'random_words': (context) => RandomWords(),
        'input_page': (context) => InputPage(),
        'search_page': (context) => RetrivePage(),
      },
    );
  }
}

// MyHomePage 是应用的首页，它继承自StatefulWidget类，表示它是一个有状态的widget
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

// _MyHomePageState类是MyHomePage类对应的状态类
class _MyHomePageState extends State<MyHomePage> {
  int _couter = 0; // 状态

  // 状态改变函数
  void _incrementCounter() {
    setState(() {
      // setState方法的作用是通知Flutter框架，有状态发生了改变，Flutter框架收到通知后，会执行build方法来根据新的状态重新构建界面
      _couter++;
    });
  }

  // 当MyHomePage第一次创建时，_MyHomePageState类会被创建，当初始化完成后，
  // Flutter框架会调用Widget的build方法来构建widget树，最终将widget树渲染到设备屏幕上
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // Scaffold 是Material库中提供的页面脚手架，
    // 它包含导航栏和Body以及FloatingActionButton（如果需要的话）。 本书后面示例中，路由默认都是通过Scaffold创建。
    // 提供了默认的导航栏、标题和包含主屏幕widget树的body属性。widget树可以很复杂
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
          elevation: 0,
        ),
        drawer: new Drawer(child: DrawerBuild.drawer(context)),
        body: InputPage());
  }
}

class NewRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text('新的页面'),
      ),
      body: new Center(
        child: Text('新的页面'),
      ),
    );
  }
}

// 带参数的路由
class ArgsRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 通过以下方式，获取路由参数
    String args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      body: new Center(
          child: new Text(
        args,
      )),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _textStyle = const TextStyle(fontSize: 18.0);
  final _saved = new Set<WordPair>();

  Widget _buildListRow(WordPair pair) {
    final _alreadySaved = _saved.contains(pair);
    return new ListTile(
      title: new Text(
        pair.asPascalCase,
        style: _textStyle,
      ),
      trailing: new Icon(
        _alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: _alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (_alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }

  Widget _buildSugList() {
    // ListView类提供了一个builder属性，itemBuilder 值是一个匿名回调函数， 接受两个参数- BuildContext和行迭代器i

    return new ListView.builder(
      itemBuilder: (context, i) {
        // 对于List中的每个元素，都会调用itemBuilder函数一次
        if (i.isOdd) return new Divider(); // 奇数行，添加一个分割线

        //偶数行
        final index = i ~/ 2; // 获取当前位置
        if (index >= _suggestions.length) {
          // 如果是最后一个，则插入新的
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildListRow(_suggestions[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text('随机单词'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildSugList(), // scaffold -> body -> list -> listtile
    );
  }
}

// 侧边栏
class DrawerBuild {
  static Widget drawer(BuildContext context) {
    return new ListView(
      padding: const EdgeInsets.only(),
      children: <Widget>[
        _header(),
        new ClipRect(
          child: new ListTile(
            leading: new Icon(Icons.home),
            title: new Text('患者自诊'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('input_page');
            },
          ),
        ),
        ListTile(
          leading: new Icon(Icons.search),
          title: new Text('知识检索'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('search_page');
          },
        ),
        new AboutListTile(
          icon: new Icon(Icons.apps),
          child: new Text("关于"),
          applicationName: "随身医生",
          applicationVersion: "1.0",
          applicationIcon: new Image.asset(
            "images/1.jpg",
            width: 64.0,
            height: 64.0,
          ),
          applicationLegalese: "applicationLegalese",
          aboutBoxChildren: <Widget>[
            new Text("Blalalt@163.com"),
            new Text("！！！！")
          ],
        ),
      ],
    );
  }

  static Widget _header() {
    return new UserAccountsDrawerHeader(
      accountEmail: Text(''),
      accountName: Text(''),
      decoration: new BoxDecoration(
        // //用一个BoxDecoration装饰器提供背景图片
        image: new DecorationImage(
            fit: BoxFit.cover, image: ExactAssetImage('images/1.jpg')),
      ),
    );
  }
}

// 聊天页
class InputPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('智能问诊'),
      ),
      drawer: new Drawer(child: DrawerBuild.drawer(context)),
      body: Container(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
          child: Column(children: <Widget>[
            Expanded(child: ChatMessage(), flex: 9),
            ChatInput()
          ])),
    );
  }
}

class ChatInput extends StatefulWidget {
  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _textController = new TextEditingController();

  void _handleSubmitted(BuildContext context, String text) {
    _textController.clear();
    Provider.of<Messages>(context).add({'data': text, 'type': '1'});
  }

  bool inputByText = true;

  void _changeInputForm() {
    setState(() {
      inputByText = !inputByText;
    });
  }

  Widget _getInputForm() {
    if (inputByText) {
      return new TextField(
        onChanged: (val) {
          print(val);
        },
        controller: _textController,

        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            /*边角*/
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            borderSide: BorderSide(
              color: Colors.grey[400],
              width: 2, //边线宽度为2
            ),
          ),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
            color: Colors.blue, //边框颜色为绿色
            width: 2, //宽度为5
          )),
        ),
        // decoration: new InputDecoration.collapsed(
        //   hintText: "Send a message"
        // ),
      );
    } else {
      return new OutlineButton(
        color: Colors.white,
        child: Text('按住讲话'),
        onPressed: () {
          print('push');
        },
      );
    }
    // return new FlatButton(
    //     child: Text('按住讲话'),);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: EdgeInsets.all(10.0),
        child: Row(
          // mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            new Expanded(
              child: new Container(
                child: new IconButton(
                  icon: Icon(Icons.volume_up),
                  onPressed: () {
                    _changeInputForm();
                  },
                  color: Colors.blue,
                ),
              ),
              flex: 1,
            ),
            new Expanded(
              child: new Container(
                child: _getInputForm(),
              ),
              flex: 5,
            ),
            new Expanded(
              child: new Container(
                child: new IconButton(
                  icon: Icon(Icons.arrow_upward),
                  color: Colors.blue,
                  onPressed: () =>
                      _handleSubmitted(context, _textController.text),
                ),
              ),
              flex: 1,
            ),
          ],
        ));
  }
}

class ChatMessage extends StatefulWidget {
  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  // var _messages = Provider.of<Messages>(context).messages;

  Widget _buildMessageUI(info) {
    if (info['type'] == '2') {
      // 回复
      return ResponseUI(Text(
        info['data'],
        textAlign: TextAlign.start,
      ));
    } else if (info['type'] == '1') {
      // 发送
      return SendUI(
        Text(
          info['data'],
          textAlign: TextAlign.end,
        ),
      );
    } else if (info['type'] == '3') {
      // 症状选择
      List<String> radio_list = info['radio_list'].toString().split(',');
      Map<String, bool> map = new Map.fromIterable(radio_list,
            key: (item) => item.toString(),
            value: (item) => false);
      return ResponseUI(SymptomInput(map));
    } else if (info['type'] == '4') {
      //疾病信息
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new CircleAvatar(
            backgroundImage: AssetImage('images/2.jpg'),
            radius: 20.0,
          ),
          Card(
              margin: EdgeInsets.only(left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    // padding: EdgeInsets.all(10),
                    width: 200,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      info['title'],
                      textAlign: TextAlign.left,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  ),
                  Container(
                    width: 200,
                    child: Text(
                      info['desc'],
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.blueGrey[300]),
                      maxLines: 2,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  Container(
                    width: 200,
                    child: FlatButton(
                      // padding: EdgeInsets.all(0),
                      child: Text(
                        '查看',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w700,
                            fontSize: 14),
                      ),
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  DiseaseDetail(int.parse(info['id'])))),
                    ),
                    alignment: Alignment.centerRight,
                  ),
                ],
              ))
        ],
      );
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: ListView.builder(
            // padding: EdgeInsets.symmetric(vertical: 2),
            // itemExtent: 40,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if (index >= Provider.of<Messages>(context).messages.length) {
                return null;
              }
              return Column(
                children: <Widget>[
                  _buildMessageUI(
                      Provider.of<Messages>(context).messages[index]),
                  Container(
                    height: 10,
                  ),
                ],
              );
            }));
  }
}

class Messages with ChangeNotifier {
  var _messages = <Map<String, String>>[
    {
      'data': '你好啊',
      'type': '2',
      'time': '2019年6月12',
    },
    {
      'data': '你好',
      'type': '1',
      'time': '2019年6月12',
    },
    {
      'title': '小儿发烧',
      'desc':
          '2017年4月28日 - Flutter有一个丰富的布局控件库,但我们只学习最常用的一些,目的是使你可以尽快开始...ListTile最常用于Card或ListView,还可以在别的地方使用。展开阅',
      'type': '4',
      'time': '2019年6月12',
      'id': '1'
    },
    {
      'data': '',
      'radio_list': '发烧,咳嗽,感冒,流鼻涕',
      'type': '3',
      'time': '2019年6月12',
      'desc': '请问您是否还有以下症状呢?'
    }
  ];
  void add(Map<String, String> data) {
    _messages.add(data);
    notifyListeners();
  }

  get messages => _messages;
}

class ResponseUI extends StatelessWidget {
  Widget child;
  ResponseUI(this.child);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new CircleAvatar(
          backgroundImage: AssetImage('images/2.jpg'),
          radius: 20.0,
        ),
        Container(
          constraints: BoxConstraints(
            maxWidth: 250,
          ),
          margin: EdgeInsets.only(left: 10),
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              color: Colors.white,
              border: new Border.all(width: 0.0, color: Colors.black12),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10.0))),
          child: child,
        ),
      ],
    );
  }
}

class SendUI extends StatelessWidget {
  Widget child;
  SendUI(this.child);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(
              right: 10,
            ),
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: Colors.lightGreenAccent,
                border: new Border.all(width: 0.0, color: Colors.black12),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(2.0),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10.0))),
            child: child),
        new CircleAvatar(
          backgroundImage: AssetImage('images/1.jpg'),
          radius: 20.0,
        )
      ],
    );
  }
}

class SymptomInput extends StatefulWidget {
  Map<String, bool> tiles;
  SymptomInput(this.tiles);
  @override
  _SymptomInputState createState() => _SymptomInputState(tiles);
}

class _SymptomInputState extends State<SymptomInput> {
  Map<String,bool> tiles;
  bool alreadyUp = false;
  String checked = '';
  _SymptomInputState(this.tiles);
  List<Widget> _buildTile() {
    var radioListTiles = <Widget>[];
    radioListTiles.add(Text(
      '请问您是否还有以下症状呢?',
      softWrap: true,
    ));
    for (var tile in tiles.keys) {
      radioListTiles.add( ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: 150, height: 35.0),
      child: CheckboxListTile(
        // dense: true,
        value: tiles[tile],
        // groupValue: Text(tile),
        activeColor: Colors.blue,
        title: Text(tile),
        onChanged: (value) {
          setState(() {
            tiles[tile] = !tiles[tile]; 
          });
        },
      )));
    }
    radioListTiles.add(
      Container(
        width: 150,
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.all(0),
        child: FlatButton(
          // padding: EdgeInsets.all(0),
          disabledTextColor: Colors.grey,
          child: Text(
            '确定',
            style: TextStyle(
                color: Colors.blue, fontWeight: FontWeight.w700, fontSize: 14),
          ),
          onPressed: (){
            if (alreadyUp) return null;
            alreadyUp = true;
            var symptomList = <String>[];
            for (var t in tiles.keys) {
              if (tiles[t]) symptomList.add(t);
            }
            var symptomStr = symptomList.join(',');
            Provider.of<Messages>(context).add({'data': symptomStr, 'type': '1'});
          }
        ),
        alignment: Alignment.centerRight,
      ),
    );
    return radioListTiles;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _buildTile(),
    );
  }
}
