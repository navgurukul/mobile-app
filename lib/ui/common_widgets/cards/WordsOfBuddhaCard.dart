// import 'dart:html';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:patta/local_database/database.dart';
import 'package:patta/resources/strings.dart';
import 'package:patta/ui/common_widgets/audio_button.dart';
import 'package:patta/ui/common_widgets/bookmark_button.dart';
import 'package:patta/ui/common_widgets/pariyatti_icons.dart';
import 'package:patta/ui/common_widgets/share_button.dart';
import 'package:patta/ui/model/WordsOfBuddhaCardModel.dart';
import 'package:patta/util.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:video_player/video_player.dart';

class WordsOfBuddhaCard extends StatefulWidget {
  final WordsOfBuddhaCardModel data;
  final PariyattiDatabase database;

  WordsOfBuddhaCard(this.data, this.database, {Key? key}) : super(key: key);

  @override
  _WordsOfBuddhaCardState createState() => _WordsOfBuddhaCardState();
}

class _WordsOfBuddhaCardState extends State<WordsOfBuddhaCard> {
  final GlobalKey _renderKey = new GlobalKey();
  late VideoPlayerController _controller;
  late bool loaded;

  Future<Uint8List> _getImage() async {
    try {
      RenderRepaintBoundary boundary =
          _renderKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png) as ByteData;
      var pngBytes = byteData.buffer.asUint8List();
      return pngBytes;
    } catch (e) {
      print(e);
      throw e;
    }
    // was: return null;
  }

  @override
  void initState() {
    // Check if image is in cache in case widget gets rebuilt and the onLoaded callback doesn't respond.
    loaded = DefaultCacheManager().getFileFromMemory(widget.data.imageUrl) != null;
    initAudioController();
    super.initState();
  }

  void initAudioController() {
    _controller = VideoPlayerController.network(widget.data.audioUrl ?? "")
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        // TODO: this probably isn't necessary for audio-only? -sd
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ),
            child: Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  8.0,
                ),
              ),
              child: ClipPath(
                clipper: ShapeBorderClipper(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      8.0,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    buildHeader(),
                    buildImage(),
                    buildWords(),
                    buildButtonFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Padding buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 12.0,
      ),
      child: Text(
        widget.data.header?.toUpperCase() ?? "<header was empty>",
        style: TextStyle(
          inherit: true,
          fontSize: 14.0,
          color: Color(0xff999999),
        ),
      ),
    );
  }

  RepaintBoundary buildImage() {
    return RepaintBoundary(
                    key: _renderKey,
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      //Custom callback added to the package to know when the image is loaded.
                      //Does not give a value if widget is rebuilt. See initState for workaround.
                      onLoad: (value) {
                        setState(() {
                          loaded = value;
                        });
                      },
                      errorWidget: (context, url, error) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Icon(
                            PariyattiIcons.get(IconName.error),
                            color: Color(0xff6d695f),
                          ),
                        ),
                      ),
                      imageUrl: widget.data.imageUrl,
                      imageBuilder: (context, imageProvider) {
                        return Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              child: Image(
                                image: imageProvider,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
  }

  Padding buildWords() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        widget.data.words ?? "<words were empty>",
        style: TextStyle(
          inherit: true,
          fontSize: 20.0,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Container buildButtonFooter() {
    return Container(
      color: Color(0xffdcd3c0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          buildAudioButton(),
          buildBookmarkButton(),
          buildShareButton()
        ],
      ),
    );
  }

  AudioButton buildAudioButton() {
    return AudioButton(
      onPressed: loaded == true ? () async {
        initAudioController();
        _controller.play();
      } : null,
    );
  }

  ShareButton buildShareButton() {
    return ShareButton(onPressed: loaded == true ? () async {
      Uint8List imageData = await _getImage();
      final String extension = extractFileExtension(widget.data.imageUrl);
      await WcFlutterShare.share(
        sharePopupTitle: AppStrings.get().labelShareInspiration,
        mimeType: 'image/$extension',
        fileName: '${widget.data.header}.$extension',
        bytesOfFile: imageData,
        text: widget.data.words,
        );
    } : null);
  }

  Visibility buildBookmarkButton() {
    return Visibility(
                          visible: widget.data.isBookmarkable,
                          child: BookmarkButton(widget.data, widget.database),
                        );
  }

}