import 'package:flutter/material.dart';
import 'package:newsextra/service/AudioPlayerModel.dart';
import 'package:provider/provider.dart';
import '../providers/RadioModel.dart';
import '../models/Radios.dart';
import '../i18n/strings.g.dart';
import '../utils/TextStyles.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/cupertino.dart';

class RadiosScreen extends StatefulWidget {
  RadiosScreen();

  @override
  RadiosScreenRouteState createState() => new RadiosScreenRouteState();
}

class RadiosScreenRouteState extends State<RadiosScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0), () {
      Provider.of<RadioModel>(context, listen: false).fetchOnFirstLoad();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<Radios> items = [];
    final radioModel = Provider.of<RadioModel>(context);
    items = radioModel.items;

    void _onRefresh() async {
      radioModel.fetchRadio();
    }

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      header: WaterDropHeader(),
      controller: radioModel.refreshController,
      onRefresh: _onRefresh,
      child: (radioModel.isError == true && radioModel.items.length == 0)
          ? Center(
              child: Text(t.articlesloaderrormsg,
                  textAlign: TextAlign.center,
                  style: TextStyles.medium(context)),
            )
          : Column(
              children: <Widget>[
                Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(height: 1, color: Colors.grey),
                    itemBuilder: (context, index) {
                      return Container(
                          height: 70,
                          child: RadioItems(
                            radio: items[index],
                            radioModel: radioModel,
                            items: items,
                          ));
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class RadioItems extends StatelessWidget {
  const RadioItems({
    Key? key,
    required this.radio,
    required this.radioModel,
    required this.items,
  }) : super(key: key);

  final Radios radio;
  final RadioModel radioModel;
  final List<Radios> items;

  @override
  Widget build(BuildContext context) {
    //print("i am called here");
    return InkWell(
      child: ListTile(
          //contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(radio.thumbnail!),
          ),
          title: Text(
            radio.title!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

          subtitle: Text(
            radio.interest!,
          ),
          trailing: Icon(Icons.keyboard_arrow_right, size: 30.0)),
      onTap: () {
        List<Radios?> _mediaList = [radio];

        Provider.of<AudioPlayerModel>(context, listen: false)
            .preparePlaylist(_mediaList, radio);
      },
    );
  }
}
