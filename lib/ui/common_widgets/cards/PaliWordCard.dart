import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:patta/local_database/database.dart';
import 'package:patta/resources/strings.dart';
import 'package:patta/ui/common_widgets/bookmark_button.dart';
import 'package:patta/ui/common_widgets/card_header.dart';
import 'package:patta/ui/common_widgets/share_button.dart';
import 'package:patta/ui/model/PaliWordCardModel.dart';
import 'package:patta/ui/style.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

class PaliWordCard extends StatelessWidget {
  final PaliWordCardModel data;
  final PariyattiDatabase database;

  PaliWordCard(this.data, this.database, {Key? key}) : super(key: key);

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
              color: Theme.of(context).colorScheme.surface,
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ClipPath(
                clipper: ShapeBorderClipper(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CardHeader(context, data.header ?? "Pāli Word"),
                    buildPaliWord(context),
                    buildButtonFooter(context)
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  buildPaliWord(context) {
    return RepaintBoundary(
      child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child:
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 0.0,
                    ),
                    child: Text(
                        data.pali ?? "<pali text was empty>",
                        style: sanSerifFont(context: context, fontSize: 18.0, color: Theme.of(context).colorScheme.onSurface)
                    ),
                  )
                ),
                Container(height: 12.0),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                        AppStrings.get().labelTranslation,
                        style: sanSerifFont(context: context, fontSize: 14.0, color: Theme.of(context).colorScheme.onBackground)
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
                    child: Text(
                        data.translation ?? "<translation was empty>",
                        style: sanSerifFont(context: context, fontSize: 18.0, color: Theme.of(context).colorScheme.onSurface)
                    ),
                  )
                )
              ],
            )
        ]
      )
    );
  }

  Container buildButtonFooter(context) {
    var listOfButtons = <Widget>[];
    if (data.isBookmarkable) {
      listOfButtons.add(BookmarkButton(data, database));
    }

    listOfButtons.add(ShareButton(
      onPressed: () async {
        await WcFlutterShare.share(
          sharePopupTitle: AppStrings.get().labelSharePaliWord,
          mimeType: 'text/plain',
          text: '${data.header}: ${data.pali}\n${AppStrings.get().labelTranslation}: ${data.translation}',
        );
      },
    ));

    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: listOfButtons,
      ),
    );
  }
}
