import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_provider/app/enums.dart';

class RepositoryTypeSelectionWidget extends StatelessWidget {
  final Text title;
  final Text cameraOption;
  final Text galleryOption;
  final Text backButton;
  final Text localOption;
  final bool showLocalOption;
  const RepositoryTypeSelectionWidget({
    Key key,
    @required this.title,
    @required this.cameraOption,
    @required this.galleryOption,
    @required this.backButton,
    this.showLocalOption = false,
    this.localOption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: title,
      actions: [
        CupertinoDialogAction(
          child: cameraOption,
          onPressed: () => Navigator.pop(context, RepositoryType.Camera),
        ),
        CupertinoDialogAction(
          child: galleryOption,
          onPressed: () => Navigator.pop(context, RepositoryType.Gallery),
        ),
        if (showLocalOption)
          CupertinoDialogAction(
            child: localOption,
            onPressed: () => Navigator.pop(context, RepositoryType.Local),
          ),
        CupertinoDialogAction(
          isDefaultAction: true,
          child: backButton,
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }
}
