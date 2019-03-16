import 'dart:io';

import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/views/card_create_update/pick_image_menu_widget.dart';
import 'package:flutter/material.dart';

typedef TextChangedCallback = void Function(String text);
typedef OnImageSelectedCallback = void Function(File file);

class CardSideInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final TextChangedCallback onTextChanged;
  final OnImageSelectedCallback onImageSelected;
  final FocusNode focusNode;
  final bool autofocus;
  final String hint;
  final Widget imageList;

  const CardSideInputWidget({
    @required Key key,
    @required this.controller,
    @required this.onTextChanged,
    @required this.hint,
    this.imageList,
    this.onImageSelected,
    this.focusNode,
    this.autofocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    hint,
                    style: app_styles.primaryText
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  PickImageMenuWidget(
                    onImageSelected: onImageSelected,
                  ),
                ],
              ),
              TextField(
                autofocus: autofocus,
                focusNode: focusNode,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                controller: controller,
                onChanged: onTextChanged,
                style: app_styles.primaryText,
              ),
              if (imageList != null) imageList,
            ],
          ),
        ),
      );
}
