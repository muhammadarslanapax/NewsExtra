import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newsextra/service/AudioPlayerModel.dart';
import 'package:provider/provider.dart';
import '../models/Radios.dart';
import '../utils/my_colors.dart';
import '../utils/TextStyles.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  _AudioPlayout createState() => _AudioPlayout();
}

class _AudioPlayout extends State<MiniPlayer> {
  @override
  Widget build(BuildContext context) {
    Provider.of<AudioPlayerModel>(context, listen: false).setContext(context);
    return Consumer<AudioPlayerModel>(
      builder: (context, audioPlayerModel, child) {
        Radios? mediaItem = audioPlayerModel.currentMedia;
        return mediaItem == null
            ? Container()
            : GestureDetector(
                onTap: () {},
                child: Container(
                  height: 65,
                  //color: Colors.grey[900],
                  child: Card(
                      color: audioPlayerModel.backgroundColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0)),
                      margin: EdgeInsets.all(0),
                      elevation: 10,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: <Widget>[
                            mediaItem == null
                                ? Container()
                                : (mediaItem.thumbnail == ""
                                    ? Icon(Icons.audiotrack)
                                    : Container(
                                        height: 50,
                                        width: 50,
                                        child: Image(
                                          image:
                                              NetworkImage(mediaItem.thumbnail!),
                                        ),
                                      )),
                            Container(
                              width: 12,
                            ),
                            Expanded(
                              child: Text(
                                mediaItem != null ? mediaItem.title! : "",
                                maxLines: 1,
                                style: TextStyles.subhead(context).copyWith(
                                    fontSize: 15, color: Colors.white),
                              ),
                            ),
                            Container(
                              margin: mediaItem.id == 0
                                  ? EdgeInsets.fromLTRB(0, 0, 15, 0)
                                  : EdgeInsets.all(0.0),
                              child: ClipOval(
                                  child: Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withAlpha(30),
                                width: 50.0,
                                height: 50.0,
                                child: IconButton(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  onPressed: () {
                                    audioPlayerModel.onPressed();
                                  },
                                  icon: audioPlayerModel.icon(),
                                ),
                              )),
                            ),
                            Container(
                              color: MyColors.primary,
                              //width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[],
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
              );
      },
    );
  }
}
