import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:flutter/material.dart';

typedef DeleteCallback = Future<bool> Function();
typedef EditCallback = Function();

class EditDeleteDismissible extends StatelessWidget {
  final Widget child;
  final double iconSize;
  final DeleteCallback onDelete;
  final EditCallback onEdit;

  const EditDeleteDismissible(
      {@required this.child,
      @required this.iconSize,
      @required this.onDelete,
      @required this.onEdit,
      @required key})
      : assert(child != null),
        assert(iconSize != null),
        assert(onDelete != null),
        assert(onEdit != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => Dismissible(
        direction: DismissDirection.horizontal,
        resizeDuration: const Duration(seconds: 1),
        background: Container(
          color: app_styles.kEditDismissibleColor,
          child: Align(
            alignment: Alignment.centerLeft,
            child: AspectRatio(
              aspectRatio: 1,
              child: Icon(
                Icons.edit,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ),
        ),
        secondaryBackground: Container(
          color: app_styles.kDeleteDismissibleColor,
          alignment: Alignment.centerRight,
          child: AspectRatio(
            aspectRatio: 1,
            child: Icon(
              Icons.delete,
              color: Colors.white,
              size: iconSize,
            ),
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            return onDelete();
          }
          onEdit();
          return false;
        },
        key: key,
        child: child,
      );
}
