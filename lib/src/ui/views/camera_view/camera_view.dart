part of '../../../../image_provider.dart';

class CameraView extends StatelessWidget {
  const CameraView({
    this.options = const CameraViewOptions(),
    super.key,
  });
  final CameraViewOptions options;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CameraViewModel(options),
      builder: (context, child) {
        return const Scaffold(
          body: _PageLoadingWidget(),
        );
      },
    );
  }
}

class _PageLoadingWidget extends StatefulWidget {
  const _PageLoadingWidget();

  @override
  __PageLoadingWidgetState createState() => __PageLoadingWidgetState();
}

class __PageLoadingWidgetState extends State<_PageLoadingWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<CameraViewModel>().getData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        context.read<CameraViewModel>().resumeCamera();
      }
    } else {
      context.read<CameraViewModel>().pauseCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewDidLoad =
        context.select<CameraViewModel, bool>((value) => value.viewDidLoad);

    return !viewDidLoad
        ? const Center(child: CircularProgressIndicator())
        : const _ViewWidgets();
  }
}

class _ViewWidgets extends StatelessWidget {
  const _ViewWidgets();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _CameraViewContent(),
        IgnorePointer(
          child: Selector<CameraViewModel, bool>(
            selector: (_, model) => model.showPictureTakenWidget,
            builder: (context, value, _) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                height: double.infinity,
                width: double.infinity,
                color: value ? Colors.black : Colors.transparent,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CameraViewContent extends StatelessWidget {
  const _CameraViewContent();

  @override
  Widget build(BuildContext context) {
    return Selector<CameraViewModel, PermissionStatus>(
      selector: (_, model) => model.cameraPermissionStatus,
      builder: (context, value, _) {
        if (value == PermissionStatus.granted) {
          return NativeDeviceOrientationReader(
            builder: (context) {
              final orientation =
                  NativeDeviceOrientationReader.orientation(context);
              switch (orientation) {
                case NativeDeviceOrientation.landscapeLeft:
                  return const _LandscapeContent();
                case NativeDeviceOrientation.landscapeRight:
                  return const _LandscapeContent();
                default:
                  return const _PortraitContent();
              }
            },
          );
        } else {
          return const _NoPermissionView();
        }
      },
    );
  }
}

class _NoPermissionView extends StatelessWidget {
  const _NoPermissionView();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Kamerayı kullanabilmek için gerekli izinlerin verilmesi gerekmektedir. Lütfen cihazınızın ayarlar menüsünden gerekli izinlerin verildiğine emin olun.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )),
        Positioned(
          top: 50,
          left: 40,
          child: SafeArea(
            child: Center(
              child: InkWell(
                onTap: () =>
                    context.read<CameraViewModel>().returnData(context),
                child: const BackButtonIcon(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PortraitContent extends StatelessWidget {
  const _PortraitContent();

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) {
            return const Positioned.fill(child: _CameraWidget(turns: 0));
          },
        ),
        OverlayEntry(
          builder: (context) {
            return Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black38,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const _CameraRollWidget(),
                        const _SpacingWidget(),
                        InkWell(
                          onTap: context.read<CameraViewModel>().captureImage,
                          child: const Icon(Icons.camera, size: 60),
                        ),
                        const _SpacingWidget(),
                        InkWell(
                          onTap: () => context
                              .read<CameraViewModel>()
                              .returnData(context),
                          child: const Icon(Icons.check, size: 50),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        OverlayEntry(
          builder: (context) {
            return const Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: _FlashToggleButton(),
                ),
              ),
            );
          },
        ),
        OverlayEntry(
          builder: (context) {
            return Selector<CameraViewModel, ImageMetadata?>(
              selector: (_, model) => model.capturingImageMetaData,
              builder: (context, capturingImageMetaData, _) {
                return Visibility(
                  visible: capturingImageMetaData != null &&
                      capturingImageMetaData.title != null &&
                      capturingImageMetaData.title!.isNotEmpty,
                  child: Positioned(
                    top: 0,
                    right: 0,
                    left: 0,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Card(
                            color: context.read<CameraViewModel>().cardColor ??
                                Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                (capturingImageMetaData?.title ?? ""),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
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
                );
              },
            );
          },
        ),
        OverlayEntry(
          builder: (context) {
            return Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    context.read<CameraViewModel>().getCurrentVersion,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
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

class _LandscapeContent extends StatelessWidget {
  const _LandscapeContent();

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) {
            return const Positioned.fill(child: _CameraWidget(turns: 1));
          },
        ),
        OverlayEntry(
          builder: (context) {
            return Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Container(
                color: Colors.black38,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const _CameraRollWidget(),
                        const _SpacingWidget(),
                        InkWell(
                          onTap: context.read<CameraViewModel>().captureImage,
                          child: const Icon(Icons.camera, size: 70),
                        ),
                        const _SpacingWidget(),
                        InkWell(
                          onTap: () => context
                              .read<CameraViewModel>()
                              .returnData(context),
                          child: const Icon(Icons.check, size: 50),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        OverlayEntry(
          builder: (context) {
            return const Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: _FlashToggleButton(),
                ),
              ),
            );
          },
        ),
        OverlayEntry(
          builder: (context) {
            return Selector<CameraViewModel, ImageMetadata?>(
              selector: (_, model) => model.capturingImageMetaData,
              builder: (context, capturingImageMetaData, _) {
                return Visibility(
                  visible: capturingImageMetaData != null &&
                      capturingImageMetaData.title != null &&
                      capturingImageMetaData.title!.isNotEmpty,
                  child: Positioned(
                    top: 0,
                    right: 0,
                    left: 0,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Card(
                            color: context.read<CameraViewModel>().cardColor ??
                                Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                (capturingImageMetaData?.title ?? ""),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
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
                );
              },
            );
          },
        ),
        OverlayEntry(
          builder: (context) {
            return Positioned(
              bottom: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Text(
                      context.read<CameraViewModel>().getCurrentVersion,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            );
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

class _FlashToggleButton extends StatelessWidget {
  const _FlashToggleButton();

  @override
  Widget build(BuildContext context) {
    return Selector<CameraViewModel, FlashMode?>(
      selector: (_, model) => model.flashType,
      builder: (context, value, widget) {
        return RadialMenu(
          icon: _getFlashIcon(value),
          entries: [
            RadialMenuEntry(
              icon: Icons.flash_auto,
              onTap: () {
                const type = FlashMode.auto;
                context.read<CameraViewModel>().setFlashMode(type);
              },
            ),
            RadialMenuEntry(
              icon: Icons.flash_on,
              onTap: () {
                const type = FlashMode.always;
                context.read<CameraViewModel>().setFlashMode(type);
              },
            ),
            RadialMenuEntry(
              icon: Icons.flash_off,
              onTap: () {
                const type = FlashMode.off;
                context.read<CameraViewModel>().setFlashMode(type);
              },
            ),
          ],
        );
      },
    );
  }

  IconData _getFlashIcon(FlashMode? type) {
    switch (type) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.off:
        return Icons.flash_off;
      default:
        return Icons.flash_auto;
    }
  }
}

class _CameraWidget extends StatelessWidget {
  final int turns;
  const _CameraWidget({required this.turns});

  @override
  Widget build(BuildContext context) {
    return Selector<CameraViewModel, CameraController?>(
      selector: (_, model) => model.controller,
      builder: (context, value, child) {
        if (value == null) {
          return const SizedBox();
        }

        double? height = turns == 0
            ? value.value.previewSize?.width
            : value.value.previewSize?.flipped.width;
        double? width = turns == 0
            ? value.value.previewSize?.height
            : value.value.previewSize?.flipped.height;

        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: width,
            height: height,
            child: Listener(
              onPointerDown: (_) =>
                  context.read<CameraViewModel>().onPointerDown(),
              onPointerUp: (_) => context.read<CameraViewModel>().onPointerUp(),
              child: CameraPreview(
                value,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Selector<CameraViewModel, bool>(
                          selector: (_, model) => model.showFocusWidget,
                          builder: (context, value, _) {
                            if (!value) {
                              return const SizedBox();
                            }

                            final offset =
                                context.read<CameraViewModel>().tabOffset;
                            final rect = Rect.fromCenter(
                                center: offset, width: 200, height: 200);

                            return Positioned.fromRect(
                              rect: rect,
                              child: Container(
                                height: 300,
                                width: 300,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                    width: 5,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onScaleStart:
                              context.read<CameraViewModel>().handleScaleStart,
                          onScaleUpdate:
                              context.read<CameraViewModel>().handleScaleUpdate,
                          onTapDown: (details) => context
                              .read<CameraViewModel>()
                              .onViewFinderTap(details, constraints),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SpacingWidget extends StatelessWidget {
  final Axis? axis;
  // ignore: unused_element
  const _SpacingWidget({this.axis = Axis.vertical});

  @override
  Widget build(BuildContext context) {
    if (axis == Axis.horizontal) {
      return const SizedBox(width: 30);
    }

    return const SizedBox(height: 30);
  }
}

class _CameraRollWidget extends StatelessWidget {
  const _CameraRollWidget();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.read<CameraViewModel>().openCameraRollBottomSheet(context),
      child: Selector<CameraViewModel, String?>(
        shouldRebuild: (a, b) => a != b,
        selector: (_, model) => model.lastImage,
        builder: (context, value, child) {
          if (value != null) {
            final file = File(value);
            return InkWell(
              child: CircleAvatar(
                radius: 25.0,
                backgroundImage: MemoryImage(file.readAsBytesSync()),
              ),
            );
          }
          return const CircleAvatar(radius: 25.0);
        },
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Selector<CameraViewModel, List<ContentData>>(
            selector: (_, model) => model.contentDataList,
            builder: (context, contentDataList, _) {
              final maxWidth = MediaQuery.of(context).size.width;
              const cSize = 150;
              final cCount = (maxWidth ~/ cSize).toInt();
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cCount,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemCount: contentDataList.length + 1,
                itemBuilder: (context, index) {
                  if (index == contentDataList.length) {
                    return const SizedBox();
                  }

                  final item = contentDataList[index];
                  return SizedBox(
                    child: Stack(
                      fit: StackFit.loose,
                      children: [
                        Builder(
                          builder: (context) {
                            late final dynamic image;
                            final file = File(item.path);
                            image = MemoryImage(file.readAsBytesSync());
                            return ImageHolder(
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
                            );
                          },
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
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ImageOverlayContentWidget extends StatelessWidget {
  const _ImageOverlayContentWidget();

  @override
  Widget build(BuildContext context) {
    return Selector<CameraViewModel, ImageMetadata?>(
      selector: (_, model) => model.capturingImageMetaData,
      builder: (context, capturingImageMetaData, _) {
        if (capturingImageMetaData == null ||
            capturingImageMetaData.overlayContent == null) {
          return const SizedBox.shrink();
        }
        return IgnorePointer(
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
        );
      },
    );
  }
}
