import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:hello_world/http.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget loading() {
  return new Stack(
    children: <Widget>[
      new Padding(
        padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 35.0),
        child: new Center(
          child: SpinKitFadingCircle(
            color: Colors.blueAccent,
            size: 30.0,
          ),
        ),
      ),
      new Padding(
        padding: new EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
        child: new Center(
          child: new Text('正在加载中，莫着急哦~'),
        ),
      ),
    ],
  );
}

Future<Map> getSearchData(String searchText, int page) async {
  var res;
  try {
    Response response = await dio.get("/search", queryParameters: {
      'query': searchText,
      'page': page,
    });
    res = response.data;
  } catch (e) {
    print(e);
  }
  return res;
}

Future<Map> getDiseasDetail(String id) async {
  var res;
  try {
    Response response = await dio.get("/disease/" + id);
    res = response.data;
//    print(res);
  } catch (e) {
    print(e);
  }
  return res;
}

class RetrivePage extends StatefulWidget {
  @override
  _RetrivePageState createState() => _RetrivePageState();
}

class _RetrivePageState extends State<RetrivePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Diseases>.value(
      notifier: Diseases(),
      child: Scaffold(
        appBar: AppBar(
          title: TextFieldWidget(),
          actions: <Widget>[
            IconButton(
              // 搜索按钮
              icon: Icon(Icons.search),
              onPressed: () {
                Provider.of<Diseases>(context).search();
              },
            ),
          ],
        ),
        body: DiseaseList(),
      ),
    );
  }
}

class TextFieldWidget extends StatelessWidget {
  final TextEditingController _textController = new TextEditingController();

  Widget buildTextField(BuildContext context) {
    // theme设置局部主题
    return Theme(
      data: new ThemeData(primaryColor: Colors.grey),
      child: new TextField(
        onChanged: (value) {
          Provider.of<Diseases>(context).text = value;
        },
        controller: _textController,
        cursorColor: Colors.grey,
        // 默认设置
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
            border: InputBorder.none,
            icon: Icon(
              Icons.search,
              size: 16.0,
            ),
            hintText: "疾病名",
            hintStyle: new TextStyle(
                fontSize: 12, color: Color.fromARGB(50, 0, 0, 0))),
        style: new TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 修饰搜索框, 白色背景与圆角
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.all(new Radius.circular(5.0)),
      ),
      alignment: Alignment.center,
      height: 36,
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      child: buildTextField(context),
    );
  }
}

class Diseases with ChangeNotifier {
  int page = 1;
  String text = '';
  var _diseases = <dynamic>[];

  void refresh(String text) {
    // 网络请求
    _diseases = null;
    notifyListeners();
  }

  void init({bool loadmore: false}) async {
    await getSearchData('', page).then((res) {
      if (loadmore) {
        _diseases.addAll(res['data']);
      }
      _diseases = res['data'];
    });
    notifyListeners();
  }

  void search({bool loadmore: false}) async {
    if (text == '') return null;
    await getSearchData(text, page).then((res) {
      if (loadmore) {
        _diseases.addAll(res['data']);
      }
      _diseases = res['data'];
    });
    // _diseases = getData(text, page);
    notifyListeners();
  }

  void loadMore() {
    page = page + 1;
    if (text != '') {
      search(loadmore: true);
    } else {
      init(loadmore: true);
    }
  }

  get diseases => _diseases;
}

class DiseaseList extends StatefulWidget {
  @override
  _DiseaseListState createState() => _DiseaseListState();
}

class _DiseaseListState extends State<DiseaseList> {
  List diseases = [];

  @override
  void initState() {
    super.initState();
  }

  Widget _buildDieasesCard(Map<String, dynamic> data) {
    return new Container(
        child: Card(
      elevation: 4.0,
      color: Colors.white,
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            dense: false,
            title: Container(
              child: Text(
                data['title'],
                style: TextStyle(fontSize: 18),
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            subtitle: Container(
              child: Text(
                data['desc'],
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DiseaseDetail(data['id'])));
            },
          ),
        ],
      ),
    ));
  }

  Widget listBuilder(BuildContext context) {
    if (diseases.length == 0) {
      return loading();
    } else {
      return new ListView.builder(
          //ListView的Item
          itemBuilder: (context, index) {
        if (index >= diseases.length) {
          return null;
        }
        return _buildDieasesCard(diseases[index]);
      });
    }
  }

  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();

  @override
  Widget build(BuildContext context) {
    if (diseases.length == 0) {
      Provider.of<Diseases>(context).init();
      setState(() {
        diseases = Provider.of<Diseases>(context).diseases;
      });
    }
    print(diseases);
    print(diseases.length);
    return Container(
        padding: EdgeInsets.all(10),
        child: new EasyRefresh(
          key: _easyRefreshKey,
          autoLoad: false,
          behavior: ScrollOverBehavior(),
          refreshFooter: ClassicsFooter(
            key: _footerKey,
            loadText: '上拉刷新',
            loadedText: '加载成功',
            loadReadyText: '松开加载',
            loadingText: '加载中',
            noMoreText: '已经到底了',
            moreInfo: '',
            bgColor: Colors.transparent,
            textColor: Colors.black87,
            moreInfoColor: Colors.black54,
            showMore: true,
          ),
          child: listBuilder(context),
          loadMore: () async {
            await new Future.delayed(const Duration(seconds: 1), () {
              Provider.of<Diseases>(context).loadMore();
            });
          },
        ));
  }
}

class DiseaseDetail extends StatefulWidget {
  String id;

  DiseaseDetail(this.id);

  @override
  _DiseaseDetailState createState() => _DiseaseDetailState(id);
}

class _DiseaseDetailState extends State<DiseaseDetail>
    with SingleTickerProviderStateMixin {
  String id;
  String title;
  TabController _tabController;

  _DiseaseDetailState(this.id);

  Map<String, dynamic> detail;

  getDetailData() async {
    await getDiseasDetail(id).then((res) {
      setState(() {
        // print(res);
        detail = res['data'];
        title = res['name'];
        _tabController = TabController(length: detail.keys.length, vsync: this);
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDetailData();
  }

  List<Tab> _getTabs() {
    var tabs = <Tab>[];
    for (var i in detail.keys) {
      tabs.add(Tab(
        text: i,
      ));
    }
    return tabs;
  }

  List<Widget> _getTabView() {
    var views = <Widget>[];
    for (var i in detail.keys) {
      views.add(ListView(
        padding: EdgeInsets.only(left: 20, right: 20, top: 15),
        children: <Widget>[
          Text(
            '        ' + detail[i],
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.left,
            softWrap: true,
          ),
        ],
      ));
//      views.add(Container(
//        margin: EdgeInsets.only(left: 20, right: 20, top: 15),
//        child: Text(
//          detail[i],
//          style: TextStyle(fontSize: 18,),
//          overflow: TextOverflow.visible,
//        ),
//      ));
//      views.add(Text(detail[i]));
    }
    return views;
  }

  @override
  Widget build(BuildContext context) {
    if ((detail == null) || (title == null)) {
      return Scaffold(
        body: loading(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: new TabBar(
          tabs: _getTabs(),
          indicator: UnderlineTabIndicator(),
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        children: _getTabView(),
        controller: _tabController,
      ),
    );
  }
}
