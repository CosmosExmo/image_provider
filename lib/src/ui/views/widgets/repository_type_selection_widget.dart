part of '../../../../image_provider.dart';

class RepositoryTypeSelectionWidget extends StatelessWidget {
  final Text title;
  final Text cameraOption;
  final Text galleryOption;
  final Text backButton;
  final Text? localOption;
  final bool showLocalOption;
  const RepositoryTypeSelectionWidget({
    super.key,
    required this.title,
    required this.cameraOption,
    required this.galleryOption,
    required this.backButton,
    this.showLocalOption = false,
    this.localOption,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: title,
      actions: [
        CupertinoDialogAction(
          child: cameraOption,
          onPressed: () => Navigator.pop(context, RepositoryType.camera),
        ),
        CupertinoDialogAction(
          child: galleryOption,
          onPressed: () => Navigator.pop(context, RepositoryType.gallery),
        ),
        if (showLocalOption)
          CupertinoDialogAction(
            child: localOption!,
            onPressed: () => Navigator.pop(context, RepositoryType.local),
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
