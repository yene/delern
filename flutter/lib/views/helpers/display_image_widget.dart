import 'package:cached_network_image/cached_network_image.dart';
import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/remote/error_reporting.dart' as error_reporting;
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';

Widget buildDisplayImageWidget(String uri) => CachedNetworkImage(
      imageUrl: uri,
      placeholder: (context, url) =>
          const ImageProgressIndicatorPlaceholderWidget(),
      errorWidget: (context, url, error) {
        unawaited(
            error_reporting.report('Image loading  failed: $url', error, null));
        return Column(
          children: <Widget>[
            Icon(
              Icons.error,
              color: app_styles.kIconColor,
            ),
            Text(
              localizations.of(context).imageLoadingErrorUserMessage,
              softWrap: true,
              textAlign: TextAlign.center,
              style: app_styles.secondaryText,
            ),
          ],
        );
      },
    );
