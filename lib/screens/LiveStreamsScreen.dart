import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import '../models/LiveStreams.dart';
import '../i18n/strings.g.dart';
import '../providers/LiveStreamsModel.dart';
import '../screens/NoitemScreen.dart';
import '../models/ScreenArguements.dart';
import '../video_player/LiveTVPlayer.dart';

class LiveStreamsScreen extends StatefulWidget {
  LiveStreamsScreen();

  @override
  LiveStreamsScreenRouteState createState() =>
      new LiveStreamsScreenRouteState();
}

class LiveStreamsScreenRouteState extends State<LiveStreamsScreen> {
  late LiveStreamsModel liveStreamsModel;
  List<LiveStreams>? items;

  onRetryClick() {
    liveStreamsModel.loadItems();
  }

  onItemClick(LiveStreams liveStreams) {
    Navigator.pushNamed(
      context,
      LiveTVPlayer.routeName,
      arguments: ScreenArguements(
        position: 0,
        object: liveStreams,
        items: items,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    liveStreamsModel = Provider.of<LiveStreamsModel>(context);
    items = liveStreamsModel.livestreams;

    if (liveStreamsModel.isLoading) {
      return Center(
          child: CupertinoActivityIndicator(
        radius: 20,
      ));
    } else if (liveStreamsModel.isError) {
      return NoitemScreen(
          title: t.oops, message: t.dataloaderror, onClick: onRetryClick);
    } else
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 25.0),
        padding: const EdgeInsets.all(10.0),
        itemCount: items!.length,
        itemBuilder: (BuildContext context, int index) {
          LiveStreams liveStreams = items![index];
          return new GridTile(
            footer: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Flexible(
                    child: new SizedBox(
                      height: 16.0,
                      width: 100.0,
                      child: new Text(
                        liveStreams.title!,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                ]),
            child: new Container(
              height: 500.0,
              padding: const EdgeInsets.only(bottom: 5.0),
              child: new GestureDetector(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    new SizedBox(
                      height: 100.0,
                      width: 100.0,
                      child: new Row(
                        children: <Widget>[
                          new Stack(
                            children: <Widget>[
                              new SizedBox(
                                child: new Container(
                                  child: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(liveStreams.coverphoto!),
                                    radius: 40.0,
                                  ),
                                  padding: const EdgeInsets.only(
                                      left: 10.0, top: 12.0, right: 10.0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  onItemClick(liveStreams);
                },
              ),
            ),
          );
        },
      );
  }
}
