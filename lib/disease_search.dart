import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

void getData(String search_text, int page) async {
  try {
    Response response =
        await Dio().get("http://www.baidu.com", queryParameters: {
      'text': search_text,
      'page': page,
    });
    print(response);
  } catch (e) {
    print(e);
  }
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
              icon: Icon(Icons.search),
              onPressed: () {
                print('按下');
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
  Widget buildTextField() {
    // theme设置局部主题
    return Theme(
      data: new ThemeData(primaryColor: Colors.grey),
      child: new TextField(
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
      child: buildTextField(),
    );
  }
}

class Diseases with ChangeNotifier {
  int page = 1;
  String text = '';
  var _diseases = <Map<String, String>>[
    {
      'id': '1',
      'title': '小儿发烧',
      'desc':
          '之前快速过了一些Flutter里的主要概念。比如Card，主要是用于将一组信息和动作放入一张卡片中，一般来说在超过三行就不适合列表了，可以考虑卡片。卡片也很灵活，它不仅可以包含图片、动作，也可以把不同类型的内容通过多张卡片在一个页面来展示给用户。'
    }
  ];
  void refresh(String text) {
    // 网络请求
    _diseases = null;
    notifyListeners();
  }

  void init() {
    getData('', page);

    // _diseases = getData('', page);
  }

  void search(String search_text) {
    text = search_text;
    getData(text, page);
    // _diseases = getData(text, page);
    notifyListeners();
  }

  void loadMore() {
    page = page + 1;
    if (text != '') {
      search(text);
    } else {
      init();
    }
  }

  get diseases => _diseases;
}

class DiseaseList extends StatefulWidget {
  @override
  _DiseaseListState createState() => _DiseaseListState();
}

class _DiseaseListState extends State<DiseaseList> {
  Widget _buildDieasesCard(Map<String, String> data) {
    return new Container(
        child: Card(
      elevation: 4.0,
      color: Colors.white,
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          //   new Container(
          //     child: Text(data['title']),
          //     padding: EdgeInsets.only(left: 10, top: 20, bottom: 20),
          //   ),
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
                  builder: (context) => DiseaseDetail(int.parse(data['id']))));
            },
          ),
        ],
      ),
    ));
  }

  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();
  @override
  Widget build(BuildContext context) {
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
          child: new ListView.builder(
              //ListView的Item
              itemBuilder: (context, index) {
            if (index >= Provider.of<Diseases>(context).diseases.length) {
              return null;
            }
            return _buildDieasesCard(
                Provider.of<Diseases>(context).diseases[index]);
          }),
          loadMore: () async {
            await new Future.delayed(const Duration(seconds: 1), () {
              Provider.of<Diseases>(context).loadMore();
            });
          },
        ));
  }
}

class DiseaseDetail extends StatefulWidget {
  int id;
  DiseaseDetail(this.id);
  @override
  _DiseaseDetailState createState() => _DiseaseDetailState(id);
}

class _DiseaseDetailState extends State<DiseaseDetail> 
  with SingleTickerProviderStateMixin {
  int id;
  String title;
  TabController _tabController;
  _DiseaseDetailState(this.id);
  Map<String, String> detail;

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
    detail = getDetail(this.id);
    title = detail.remove('title');
    _tabController = TabController(length: detail.keys.length, vsync: this);
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
      views.add(Text(detail[i]));
    }
    return views;
  }

  @override
  Widget build(BuildContext context) {
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

Map<String, String> getDetail(int id) {
  return {'描述': '暂无', '并发症': '咳嗽', '治疗': '吃饭喝水', 'title': '小儿发烧'};
}
