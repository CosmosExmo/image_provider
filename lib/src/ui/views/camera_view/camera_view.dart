part of '../../../../image_provider.dart';

class CameraView extends StatelessWidget {
  const CameraView({
    this.options = const CameraViewOptions(),
    this.compressionOptions = const CompressionOptions(),
    super.key,
  });
  final CameraViewOptions options;
  final CompressionOptions compressionOptions;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CameraViewModel(options, compressionOptions),
      builder: (context, child) {
        return const _ViewWidgets();
      },
    );
  }
}

class _ViewWidgets extends StatelessWidget {
  const _ViewWidgets();

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) {
            return Positioned.fill(
              child: CameraAwesomeBuilder.awesome(
                saveConfig: SaveConfig.photo(),
                previewAlignment: Alignment.center,
                previewFit: CameraPreviewFit.cover,
                onMediaCaptureEvent:
                    context.read<CameraViewModel>().onPictureCapture,
                onMediaTap: (_) => context
                    .read<CameraViewModel>()
                    .openCameraRollBottomSheet(context),
                topActionsBuilder: (state) {
                  return AwesomeTopActions(
                    state: state,
                    children: (state is VideoRecordingCameraState
                        ? [const SizedBox.shrink()]
                        : [
                            AwesomeFlashButton(state: state),
                            if (state is PhotoCameraState)
                              AwesomeAspectRatioButton(state: state),
                            if (state is PhotoCameraState)
                              AwesomeLocationButton(
                                state: state,
                                iconBuilder: (value) {
                                  return AwesomeCircleWidget.icon(
                                    icon: Icons.check,
                                  );
                                },
                                onLocationTap: (_, __) => context
                                    .read<CameraViewModel>()
                                    .returnData(context),
                              ),
                          ]),
                  );
                },
              ),
            );
          },
        ),
        OverlayEntry(
          builder: (context) {
            return const _ImageMetadataTitleWidget();
          },
        ),
        OverlayEntry(
          builder: (context) {
            return const _ImageOverlayContentWidget();
          },
        ),
      ],
    );
  }
}

class _ImageMetadataTitleWidget extends StatelessWidget {
  const _ImageMetadataTitleWidget();

  (
    double? top,
    double? bottom,
    double? left,
    double? right,
    Alignment alignment
  ) setPositionAndAlignment({
    required DeviceType deviceType,
    required NativeDeviceOrientation orientation,
  }) {
    final bool isTablet = deviceType == DeviceType.tablet;
    final adjustedOrientation = (isTablet && Platform.isAndroid)
        ? _mapTabletOrientation(orientation)
        : orientation;

    double? top, bottom, left, right;
    Alignment alignment;

    switch (adjustedOrientation) {
      case NativeDeviceOrientation.portraitUp:
        top = 70;
        bottom = null;
        left = 0;
        right = 0;
        alignment = Alignment.topCenter;
        break;
      case NativeDeviceOrientation.portraitDown:
        top = 140;
        bottom = null;
        left = 0;
        right = 0;
        alignment = Alignment.bottomCenter;
        break;
      case NativeDeviceOrientation.landscapeLeft:
        top = 0;
        bottom = 0;
        left = null;
        right = 5;
        alignment = Alignment.centerLeft;
        break;
      case NativeDeviceOrientation.landscapeRight:
        top = 0;
        bottom = 0;
        left = 5;
        right = null;
        alignment = Alignment.centerRight;
        break;
      default:
        top = 70;
        bottom = null;
        left = 0;
        right = 0;
        alignment = Alignment.topCenter;
    }

    return (top, bottom, left, right, alignment);
  }

  NativeDeviceOrientation _mapTabletOrientation(
      NativeDeviceOrientation orientation) {
    switch (orientation) {
      case NativeDeviceOrientation.portraitUp:
        return NativeDeviceOrientation.landscapeLeft;
      case NativeDeviceOrientation.portraitDown:
        return NativeDeviceOrientation.landscapeRight;
      case NativeDeviceOrientation.landscapeLeft:
        return NativeDeviceOrientation.portraitDown;
      case NativeDeviceOrientation.landscapeRight:
        return NativeDeviceOrientation.portraitUp;
      default:
        return orientation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NativeDeviceOrientationReader(
      useSensor: true,
      builder: (context) {
        final orientation = NativeDeviceOrientationReader.orientation(context);

        // Determine positioning based on orientation
        double? top, bottom, left, right;
        Alignment alignment = Alignment.topCenter;

        final deviceType = getDeviceType();

        final values = setPositionAndAlignment(
          deviceType: deviceType,
          orientation: orientation,
        );

        top = values.$1;
        bottom = values.$2;
        left = values.$3;
        right = values.$4;
        alignment = values.$5;

        final capturingImageMetaData =
            context.watch<CameraViewModel>().capturingImageMetaData;
        return Visibility(
          visible: capturingImageMetaData.title != null &&
              capturingImageMetaData.title!.isNotEmpty,
          child: Stack(
            children: [
              Positioned(
                top: top,
                bottom: bottom,
                left: left,
                right: right,
                child: AwesomeOrientedWidget(
                  rotateWithDevice: true,
                  child: Align(
                    alignment: alignment,
                    child: SafeArea(
                      child: Card(
                        color: context.read<CameraViewModel>().cardColor ??
                            Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            (capturingImageMetaData.title ?? ""),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                    color: context
                                        .read<CameraViewModel>()
                                        .textColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ImageOverlayContentWidget extends StatelessWidget {
  const _ImageOverlayContentWidget();

  @override
  Widget build(BuildContext context) {
    final capturingImageMetaData =
        context.watch<CameraViewModel>().capturingImageMetaData;

    if (capturingImageMetaData.overlayContent == null) {
      return const SizedBox.shrink();
    }

    return AwesomeOrientedWidget(
      rotateWithDevice: true,
      child: IgnorePointer(
        child: Center(
          child: capturingImageMetaData.overlayContent!.source ==
                  OverlayContentSource.network
              ? Image.network(
                  capturingImageMetaData.overlayContent!.content,
                  fit: BoxFit.fitWidth,
                )
              : Image.file(
                  capturingImageMetaData.overlayContent!.content,
                  fit: BoxFit.fitWidth,
                ),
        ),
      ),
    );
  }
}

class CameraRollContentWidget extends StatelessWidget {
  final CameraViewModel provider;
  const CameraRollContentWidget(this.provider, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: SliverPadding(
        padding: const EdgeInsets.all(8.0),
        sliver: Selector<CameraViewModel, List<ContentData>>(
          selector: (_, model) => model.contentDataList,
          builder: (context, contentDataList, _) {
            final maxWidth = MediaQuery.of(context).size.width;
            const cSize = 150;
            final cCount = (maxWidth ~/ cSize).toInt();

            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cCount,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == contentDataList.length) return const SizedBox();

                  final item = contentDataList[index];
                  final file = File(item.path);
                  final image = MemoryImage(file.readAsBytesSync());

                  return SafeArea(
                    child: Stack(
                      fit: StackFit.loose,
                      children: [
                        ImageHolder(
                          images: [DecorationImage(image: image)],
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: GestureDetector(
                            onTap: () => context
                                .read<CameraViewModel>()
                                .removeImageByIndex(index),
                            child: const Icon(
                              Icons.cancel,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        if (item.metadata != null &&
                            (item.metadata!.title?.isNotEmpty ?? false))
                          Positioned(
                            left: 1,
                            right: 1,
                            bottom: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white38,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    item.metadata?.title ?? "",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
                childCount: contentDataList.length + 1,
              ),
            );
          },
        ),
      ),
    );
  }
}
