import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

typedef AccessTypeFilter = bool Function(AccessType t);
typedef AccessTypeCallback = void Function(AccessType t);

class DeckAccessDropdownWidget extends StatefulWidget {
  final AccessType value;
  final AccessTypeCallback valueChanged;
  final AccessTypeFilter filter;

  const DeckAccessDropdownWidget(
      {@required this.value,
      @required this.valueChanged,
      @required this.filter})
      : assert(filter != null),
        assert(valueChanged != null);

  @override
  State<StatefulWidget> createState() => _DropdownState();
}

class _DropdownState extends State<DeckAccessDropdownWidget> {
  @override
  Widget build(BuildContext context) => DropdownButtonHideUnderline(
          child: DropdownButton<AccessType>(
        // Provide default value.
        value: widget.value,
        items: [...AccessType.orderedValues, null]
            .where(widget.filter)
            .map((value) => DropdownMenuItem<AccessType>(
                  value: value,
                  child: buildDropdownItem(value),
                ))
            .toList(),
        onChanged: (newValue) {
          setState(() {
            widget.valueChanged(newValue);
          });
        },
      ));

  Widget buildDropdownItem(AccessType access) {
    // TODO(dotdoom): split this into a separate widget. Framework will then
    //                call build() separately for positioning the item in the
    //                value field and drop-down menu. We can detect our position
    //                by scanning the widget tree. In the value field, we will
    //                build as icon only.
    //                Unsolved problem is positioning the drop down menu to
    //                avoid overflow.

    String text;
    Icon icon;
    if (access == null) {
      text = localizations.of(context).noAccess;
      icon = const Icon(Icons.clear);
    } else {
      switch (access) {
        case AccessType.write:
          text = localizations.of(context).canEdit;
          icon = const Icon(Icons.edit);
          break;
        case AccessType.read:
          text = localizations.of(context).canView;
          icon = const Icon(Icons.remove_red_eye);
          break;
        case AccessType.owner:
          text = localizations.of(context).owner;
          icon = const Icon(Icons.person);
          break;
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          text,
          style: app_styles.secondaryText,
        ),
        icon,
      ],
    );
  }
}
