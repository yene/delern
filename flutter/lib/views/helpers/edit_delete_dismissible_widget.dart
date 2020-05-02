import 'package:delern_flutter/views/helpers/styles.dart' as app_styles;
import 'package:flutter/material.dart';

typedef DeleteDismissibleCallback = Future<bool> Function(BuildContext context);
typedef EditDismissibleCallback = void Function(BuildContext context);

class EditDeleteDismissible extends StatelessWidget {
  final Widget child;
  final double iconSize;
  final DeleteDismissibleCallback onDelete;
  final EditDismissibleCallback onEdit;

  const EditDeleteDismissible({
    @required this.child,
    @required this.iconSize,
    @required Key key,
    this.onDelete,
    this.onEdit,
  })  : assert(child != null),
        assert(iconSize != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => Dismissible(
        direction: DismissDirection.horizontal,
        resizeDuration: const Duration(seconds: 1),
        background: (onEdit == null)
            ? null
            : Container(
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
        secondaryBackground: (onDelete == null)
            ? null
            : Container(
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
          if (direction == DismissDirection.endToStart && onDelete != null) {
            return onDelete(context);
          }
          if (onEdit != null) {
            onEdit(context);
          }
          return false;
        },
        key: key,
        child: child,
      );
}
