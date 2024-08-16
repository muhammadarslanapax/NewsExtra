import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/TextStyles.dart';
import '../i18n/strings.g.dart';
import '../models/Search.dart';
import '../providers/AppStateNotifier.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';
import '../providers/SearchModel.dart';
import '../viewholders/SearchListView.dart';

class SearchScreen extends StatelessWidget {
  static String routeName = "/search";

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SearchModel()),
        ChangeNotifierProvider(create: (_) => AppStateNotifier()),
      ],
      child: SearchScreenBody(),
    );
  }
}

class SearchScreenBody extends StatefulWidget {
  SearchScreenBody();

  @override
  SearchScreenRouteState createState() => new SearchScreenRouteState();
}

class SearchScreenRouteState extends State<SearchScreenBody> {
  late BuildContext context;

  bool finishLoading = true;
  bool showClear = false;
  final TextEditingController inputController = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    List<Search> items = [];
    final appState = Provider.of<AppStateNotifier>(context);
    final searchModel = Provider.of<SearchModel>(context);
    items = searchModel.items;

    void _onLoading() async {
      searchModel.fetchMoreArticles();
    }

    void onItemClick(int indx) {}

    return new Scaffold(
      appBar: AppBar(
        title: TextField(
          maxLines: 1,
          controller: inputController,
          style: new TextStyle(fontSize: 18, color: Colors.white),
          keyboardType: TextInputType.text,
          onSubmitted: (query) {
            searchModel.searchArticles(query);
          },
          onChanged: (term) {
            setState(() {
              showClear = (term.length > 2);
            });
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: t.searchhint,
            hintStyle: TextStyle(fontSize: 20.0, color: Colors.white70),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          showClear
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                  ),
                  onPressed: () {
                    inputController.clear();
                    showClear = false;
                    searchModel.cancelSearch();
                  },
                )
              : Container(),
        ],
      ),
      body: SmartRefresher(
          enablePullDown: false,
          enablePullUp: searchModel.items.length > 20 ? true : false,
          header: WaterDropHeader(),
          footer: CustomFooter(
            builder: (BuildContext context, LoadStatus? mode) {
              Widget body;
              if (mode == LoadStatus.idle) {
                body = Text(t.pulluploadmore);
              } else if (mode == LoadStatus.loading) {
                body = CupertinoActivityIndicator();
              } else if (mode == LoadStatus.failed) {
                body = Text(t.loadfailedretry);
              } else if (mode == LoadStatus.canLoading) {
                body = Text(t.releaseloadmore);
              } else {
                body = Text(t.nomoredata);
              }
              return Container(
                height: 55.0,
                child: Center(child: body),
              );
            },
          ),
          controller: searchModel.refreshController,
          onLoading: _onLoading,
          child:
              buildContent(context, searchModel, appState, items, onItemClick)),
    );
  }

  Widget buildContent(BuildContext context, SearchModel searchModel,
      AppStateNotifier appState, List<Search> items, Function onItemClick) {
    if (searchModel.isLoading) {
      return Align(
        child: Container(
          height: 150,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CupertinoActivityIndicator(
                radius: 30,
              ),
              Container(height: 5),
              Text(
                t.performingsearch,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        alignment: Alignment.center,
      );
    } else if (searchModel.isError) {
      return Align(
        child: Container(
          width: 180,
          height: 100,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(t.nosearchresult,
                  style: TextStyles.caption(context)
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
              Container(height: 5),
              Text(t.nosearchresulthint,
                  textAlign: TextAlign.center,
                  style: TextStyles.medium(context).copyWith(fontSize: 13)),
            ],
          ),
        ),
        alignment: Alignment.center,
      );
    } else if (searchModel.isIdle) {
      return Align(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.search,
                size: 80,
              ),
              Container(height: 5),
            ],
          ),
        ),
        alignment: Alignment.center,
      );
    } else {
      return buildSearchListView(searchModel, appState, items);
    }
  }
}
