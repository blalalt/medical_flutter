// 导入包
import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:hello_world/disease_search.dart';
import 'package:dio/dio.dart';
import 'package:hello_world/http.dart';




class MyGlobals {
  GlobalKey _scaffoldKey;
  MyGlobals() {
    _scaffoldKey = GlobalKey();
  }
  GlobalKey get scaffoldKey => _scaffoldKey;
}

MyGlobals myGlobals = new MyGlobals();

// 应用入口，主要用来启动flutter 应用
void main() {
  runApp(
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
  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle =
    SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

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
        primaryColor: Colors.amberAccent,
      ),
      home: InputPage(), //home 为Flutter应用的首页，它也是一个widget
      debugShowCheckedModeBanner: false, // 去除DEBUG
      // 注册命名路由
      routes: {
        'input_page': (context) => InputPage(),
        'search_page': (context) => RetrivePage(),
      },
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
            title: new Text('自助服务'),
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
          applicationName: "小医",
          applicationVersion: "1.0",
          applicationIcon: new Image.asset(
            "images/1.jpg",
            width: 64.0,
            height: 64.0,
          ),
          applicationLegalese: "applicationLegalese",
          aboutBoxChildren: <Widget>[
            new Text("创新大赛作品!"),
//            new Text("！！！！")
          ],
        ),
      ],
    );
  }

  static Widget _header() {
    return new UserAccountsDrawerHeader(
      accountEmail: Text('150*******'),
      accountName: Text('XXX 女 22岁'),
      decoration: new BoxDecoration(
        // //用一个BoxDecoration装饰器提供背景图片
        image: new DecorationImage(
            fit: BoxFit.cover, image: ExactAssetImage('images/2.jpg')),
      ),
    );
  }
}


// 聊天页
class InputPage extends StatelessWidget {

  final List<String> schemas = ['闲聊模式', '问诊模式', "导诊模式", "问答模式"];

  @override
  Widget build(BuildContext context) {
    var headerTitle = schemas[int.parse(Provider.of<Messages>(context).schema)-1];
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 50),
        child: AppBar(
        toolbarOpacity: 0.7,
        elevation: 1,
        centerTitle: true,
        title: Text(headerTitle),
        actions: <Widget>[
          new PopupMenuButton(
            onSelected: (String value){
               Provider.of<Messages>(context).changeSchema(value);
            },
              itemBuilder: (BuildContext context) =><PopupMenuItem<String>>[
                new PopupMenuItem(
                    value:"1",
                    child: new Text("小医闲聊")
                ),
                new PopupMenuItem(
                  value: "2",
                    child: new Text("小医问诊")
                ),
                new PopupMenuItem(
                  value: "3",
                    child: new Text("小医导诊")
                ),
                new PopupMenuItem(
                  value: "4",
                    child: new Text("小医问答")
                )
              ]
          )
        ],
      )),
      drawer: new Drawer(child: DrawerBuild.drawer(context)),
      key: myGlobals.scaffoldKey,
      body: GestureDetector(
              onTap: (){
                // 点击空白页面关闭键盘
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child:  Container(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Flexible(child: ChatMessage()),
                      new Divider(height: 1.0),
                  Container(
                      decoration: new BoxDecoration(
                        color: Theme.of(context).cardColor,
                      ),
                      child: ChatInput(),
                  )

                ]))
              ),
    );
  }
}

Future<Map> getResp(String msg, String type, BuildContext context) async {
  var context = myGlobals.scaffoldKey.currentContext;

  var res;
  try {
    Response response =
    await dio.get("/chat", queryParameters: {
      'msg': msg,
      'type': type,
    });
    res = response.data;
    print('origin get resp: ');
    print(res);
//    return res;
    Provider.of<Messages>(context).add(res['data']);
  } catch (e) {
    print(e);
  }
  return res;
}


class ChatInput extends StatefulWidget {
  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _textController = new TextEditingController();

  void _handleSubmitted(BuildContext context, String text) { // 发送消息
    _textController.clear();
    Provider.of<Messages>(context).add({'data': text, 'type': '0'});
    var textType = Provider.of<Messages>(context).schema;
    getResp(text, textType, context);//.then((result){
//      print(result);
//      print('getResp: ');
//      print(result);
//      Provider.of<Messages>(context).addMany([{'data': text, 'type': '0'}, result['data']]);
//    });
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
//          print(val);
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
  var _choices = <Widget>[];
  Widget _buildBottomSheet(List<String> args, bool multi) {
    for (var index=0; index < args.length; index++) {
      var inp = ChipInputSelect(index: index, choice: args[index], multi: multi, widget: null,);
      _choices.add(inp);
    }

    return GestureDetector(
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Flexible(
                                child: Wrap(
                                  children: _choices,
                                ),
                                flex: 9,
                              ),
                              RaisedButton(
                                child: Text('确定'),
                                textColor: Colors.white,
                                color: Colors.blue,
                                onPressed: () {}
                              )
                            ],
                          ),
                        ),
                        onTap: () => false,
    );
  }

  Widget _buildMessageUI(context, info) {
    var context = myGlobals.scaffoldKey.currentContext;
    if (info['type'] == '2') {
      print('info_type==2');
      print(info);
      // 回复
      return ResponseUI(Text(
        info['data'],
        textAlign: TextAlign.start,
      ));
    } else if (info['type'] == '5') {
      // 问诊结果
//      Provider.of<Messages>(context).add({'type': '2', 'data': '小医正在为您生成结果，请稍等～'});
      // 暂停一秒
      print('into type == 5: ');
      print(info);
      var syptoms = info['data']['syptoms'];
      var diseases = info['data']['diseases'];

      var resultPgeLink = GestureDetector(
        onTap: ()=> Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) =>
                    ResultPage(syptoms: syptoms, result: diseases))),
        child: Text("点击查看诊断结果"),
      );
      return ResponseUI(resultPgeLink);
//      Provider.of<Messages>(context).add({'type': '2', 'data': '小医正在为您生成结果，请稍等～'});
    } else if (info['type'] == '0') {
      // 发送
      return SendUI(
        Text(
          info['data'],
          textAlign: TextAlign.end,
        ),
      );
    } else if (info['type'] == '3') {
      print('type==3');
      print(info);
      print('info_data');
      print(info['data']);
      // 症状选择
//      List<String> radio_list = info['data'];
      bool multi = info['multi'];
      // return _buildBottomSheet(radio_list, multi);
      Map<String, bool> map = new Map.fromIterable(info['data'],
            key: (item) => item.toString(),
            value: (item) => false);
      return ResponseUI(SymptomInput(map, info['msg']));
    } else if (info['type'] == '1') {
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
                                  DiseaseDetail(info['id']))),
                    ),
                    alignment: Alignment.centerRight,
                  ),
                ],
              ))
        ],
      );
      
    }
    else if (info['type'] == '4') {// 切换信息
      return Column( 
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
          width: 200,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: RichText(
            text: TextSpan(
              text: '您已切换到',
              style: TextStyle(color: Colors.white),
              children: [
                TextSpan(text: info['data'], 
                  style: TextStyle(color: Colors.red[900], fontSize: 15)
                )
              ]
            ),
          ),
        )]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 3),
        child: ListView.builder(
            // padding: EdgeInsets.symmetric(vertical: 2),
            // itemExtent: 40,
            shrinkWrap: false,
            reverse: true,
            itemBuilder: (context, index) {
              var length = Provider.of<Messages>(context).messages.length;
              if (index >= length) {
                return null;
              }
              var info = Provider.of<Messages>(context).messages[length-1-index];
              return Column(
                  verticalDirection: VerticalDirection.up,
                  // crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    _buildMessageUI(context, info),
                    Container(
                      height: 10,
                    ),
                  ],
              );
              // if (info['type'] == '3') {
              //   showBottomSheet(context: context, builder: (context) { 
              //     List<String> radio_list = info['radio_list'].toString().split(',');
              //     bool multi = info['multi'];
              //     return  _buildBottomSheet(radio_list, multi);});
              //   return null;
              // }
              // else {return Column(
              //     verticalDirection: VerticalDirection.up,
              //     // crossAxisAlignment: CrossAxisAlignment.end,
              //     children: <Widget>[
              //       _buildMessageUI(context, info),
              //       Container(
              //         height: 10,
              //       ),
              //     ],
              // );}
            }));
  }
}

class Messages with ChangeNotifier {

  /*******************************聊天信息*************************************************** */

  // schemas
  // 1.闲聊模式  2. 问诊模式  3. 导诊模式   4. 问答模式
  final List<String> schemas = ['闲聊模式', '问诊模式', "导诊模式", "问答模式"];

  // message
  // 0. 发送的消息   1. 回复(疾病概念)  2. 回复(普通文字回复)
  // 3. 回复(问诊选择症状)  4. 系统消息
  var _messages = <Map<String, dynamic>>[
    {
      'data': '您好,我是小医~',
      'type': '2',
      'time': '2019年6月12',
    },
//    {
//      'data': '有点发烧怎么办',
//      'type': '0',
//      'time': '2019年6月12',
//    },
//    {
//      'title': '小儿发烧',
//      'desc': '发热（fever）是指体温超过正常范围高限，是小儿十分常见的一种症状。正常小儿腋表体温为36℃～37℃（肛表测得的体温比口表高约0.3℃，口表测得的体温比腋表高约0.4℃），腋表如超过37.4℃可认为是发热。在多数情况下，发热是身体对抗入侵病原的一种保护性反应，是人体正在发动免疫系统抵抗感染的一个过程。体温的异常升高与疾病的严重程度不一定成正比，但发热过高或长期发热可影响机体各种调节功能，从而影响小儿的身体健康，因此，对确认发热的孩子，应积极查明原因，针对病因进行治疗。',
//      'type': '1',
//      'time': '2019年6月12',
//      // 'id': '1'
//    },
//    {
//      'data': ['头痛','头晕','咳嗽','流鼻涕'],
//      'type': '3',
//      'time': '2019年6月12',
//      'desc': '请问您是否还有以下症状呢?'
//    }
  ];
  String schema = '1'; // 闲聊模式
  void changeSchema(String value) {
    if (schema == value){ return null; }
    schema = value;
    add({'data': schemas[int.parse(schema)-1], 'type': '4'});
  }
  void addMany(List<Map<String, dynamic>>many) {
    print(many);
    _messages.addAll(many);
    notifyListeners();
  }
  void add(Map<String, dynamic> data) {
    _messages.add(data);
    notifyListeners();
  }

  get messages => _messages;

  /*******************************聊天信息*************************************************** */



  /*******************************用户信息(导诊)*************************************************** */

  Map<String, String> userInfo;
  /*******************************用户信息(导诊)*************************************************** */


  /*******************************症状输入(问诊)*************************************************** */
  List<bool> thisStepSelected = []; // 下标代表元素， true代表选中
  List<String> thisChoices = [];

  void initChoice(List<String> symptoms) {
    for (var i=0; i<symptoms.length; i++) {
      thisChoices[i] = symptoms[i];
      thisStepSelected[i] = false;
    }
  }

  void onSelectedChanged(int index, {bool multi: false}) {
    if (multi) { // 支持多选
      // 如果已经选中，取消操作, 否则选中
      thisStepSelected[index] = !thisStepSelected[index];
    
    }else { // 单选
      // 把其他选项全置0，表示未选中
      for(var i=0; i<thisStepSelected.length; i++) {
        thisStepSelected[i] = false;
      }
      thisStepSelected[index] = true;
    }
    notifyListeners();
  }

  bool isSelected(int index) {
    return thisStepSelected[index];
  }
  /*******************************症状输入(问诊)*************************************************** */
}

class ChipInputSelect extends StatelessWidget {
  const ChipInputSelect(
      {@required this.index,
      @required this.widget,
      @required this.choice,
      @required this.multi})
      : super();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ChoiceChip(
          label: Text(choice),
          //未选定的时候背景
          selectedColor: Color(0xff182740),
          //被禁用得时候背景
          disabledColor: Colors.grey[300],
          labelStyle: TextStyle(fontWeight: FontWeight.w200, fontSize: 15.0),
          labelPadding: EdgeInsets.only(left: 8.0, right: 8.0),
          materialTapTargetSize: MaterialTapTargetSize.padded,
          onSelected: (bool value) {
            Provider.of<Messages>(context).onSelectedChanged(index, multi: this.multi);
          },
          selected: Provider.of<Messages>(context).isSelected(index)),
    );
  }

  final int index;
  final widget;
  final String choice;
  final bool multi;
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
  String msg;
  SymptomInput(this.tiles, this.msg);
  @override
  _SymptomInputState createState() => _SymptomInputState(tiles, msg);
}

class _SymptomInputState extends State<SymptomInput> {
  Map<String,bool> tiles;
  String msg;
  bool alreadyUp = false;
  String checked = '';
  _SymptomInputState(this.tiles, this.msg);

  List<Widget> _buildTile(BuildContext context) {
    var radioListTiles = <Widget>[];
    radioListTiles.add(Text(
      msg,
      softWrap: true,
    ));
    for (var tile in tiles.keys) {
      radioListTiles.add( ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: 170, height: 35.0),
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
            var textType = Provider.of<Messages>(context).schema;

            Provider.of<Messages>(context).add({'data': symptomStr, 'type': '0'});
            print('after provider: ');
            print(symptomStr);
            getResp(symptomStr, textType, context);
//                .then((result){
//              Provider.of<Messages>(context).addMany([{'data': symptomStr, 'type': '0'}, result['data']]);
//            });
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
      children: _buildTile(context),
    );
  }
}

class ResultPage extends StatelessWidget {
  final List<dynamic> syptoms;
  final List<dynamic> result;

  const ResultPage({@required this.syptoms, @required this.result}) : super();

  List<Widget> _buildPage(BuildContext context) {
    var syptoms_str = syptoms.join('、');
    var pageElements = <Widget>[];

    var headerInfo = RichText(
      text: TextSpan(
          text: '主诉',
          style: TextStyle(color: Colors.redAccent),
          children: [
            TextSpan(text: syptoms_str),
          ]),
    );

    pageElements.add(headerInfo);
    print(result);
    print(syptoms_str);
    for(var i=0; i<result.length; i++) {
      var title = (i+1).toString()+'.'+result[i]['title'];
      pageElements.add(
          Card(
            elevation: 4.0,
            color: Colors.white,
            child: Text(title, style: TextStyle(fontWeight: FontWeight.bold),),
          )
      );
    }
    return pageElements;
  }

  Widget _buildCard(info, index) {
    var context = myGlobals.scaffoldKey.currentContext;
    print('_buildCard(info): ');
    print(info);
    return new Container(
        child: Card(
          elevation: 2.0,
          color: Colors.white,
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                dense: false,
                title: Container(
                  child: Text(
                    (index+1).toString() + '. ' + info['title'],
                    style: TextStyle(fontSize: 18),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                subtitle: Container(
                  child: Text(
                    info['data'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                onTap: ()=> Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) =>
                            DiseaseDetail(info['id']))),
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    var syptoms_str = syptoms.join('、');
    return Scaffold(
        appBar: AppBar(
          title: Text('小医问诊结果'),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: Column(

          children: [
            Container(
              child: RichText(
                text: TextSpan(
                    text: '主诉: ',
                    style: TextStyle(color: Colors.redAccent, fontSize: 20),
                    children: [
                      TextSpan(text: syptoms_str, style: TextStyle(color: Colors.black, fontSize: 16)),
                    ]),
              ),
            ),

            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                //ListView的Item
                  itemBuilder: (context, index) {
                    if (index >= result.length) {
                      return null;
                    }
                    return _buildCard(result[index], index);
                  }),
            )

        ])
        )
    );
  }
}
