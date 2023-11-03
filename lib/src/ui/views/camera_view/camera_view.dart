// ignore_for_file: unused_element

part of image_provider;

class CameraView extends StatelessWidget {
  const CameraView(
    this._options, {
    Key? key,
  }) : super(key: key);
  final CameraViewOptions? _options;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CameraViewModel(_options),
      builder: (context, child) {
        return const Scaffold(
          body: _PageLoadingWidget(),
        );
      },
    );
  }
}

class _PageLoadingWidget extends StatefulWidget {
  const _PageLoadingWidget({Key? key}) : super(key: key);

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
  const _ViewWidgets({Key? key}) : super(key: key);

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
  const _CameraViewContent({Key? key}) : super(key: key);

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
  const _NoPermissionView({Key? key}) : super(key: key);

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
  const _PortraitContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _CameraWidget(turns: 0)),
        Positioned(
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
                    Selector<CameraViewModel, String?>(
                      shouldRebuild: (a, b) => a != b,
                      selector: (_, model) => model.lastImage,
                      builder: (context, value, child) {
                        if (value != null) {
                          final file = File(value);
                          return CircleAvatar(
                            radius: 25.0,
                            backgroundImage:
                                MemoryImage(file.readAsBytesSync()),
                          );
                        }
                        return const CircleAvatar(radius: 25.0);
                      },
                    ),
                    const _SpacingWidget(),
                    InkWell(
                      onTap: context.read<CameraViewModel>().captureImage,
                      child: const Icon(Icons.camera, size: 60),
                    ),
                    const _SpacingWidget(),
                    InkWell(
                      onTap: () =>
                          context.read<CameraViewModel>().returnData(context),
                      child: const Icon(Icons.check, size: 50),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (!context.watch<CameraViewModel>().showPhotosButton)
          Positioned(
            bottom: 0,
            right: 0,
            top: 0,
            child: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 25, right: 5, left: 10),
                  child: _RollingGalleryShowCase(
                      photoCheckerMap:
                          context.watch<CameraViewModel>().photoCheckerMap)),
            ),
          ),
        const Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: _FlashToggleButton(),
            ),
          ),
        ),
        if (context.watch<CameraViewModel>().hasTitle())
          Positioned(
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
                        (context
                            .watch<CameraViewModel>()
                            .currentItem!
                            .value
                            .title!),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: context.read<CameraViewModel>().textColor),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
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
        ),
      ],
    );
  }
}

class _LandscapeContent extends StatelessWidget {
  const _LandscapeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _CameraWidget(turns: 1)),
        Positioned(
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
                    Selector<CameraViewModel, String?>(
                      shouldRebuild: (a, b) => a != b,
                      selector: (_, model) => model.lastImage,
                      builder: (context, value, child) {
                        if (value != null) {
                          final file = File(value);
                          return CircleAvatar(
                            radius: 25.0,
                            backgroundImage:
                                MemoryImage(file.readAsBytesSync()),
                          );
                        }
                        return const CircleAvatar(radius: 25.0);
                      },
                    ),
                    const _SpacingWidget(),
                    InkWell(
                      onTap: context.read<CameraViewModel>().captureImage,
                      child: const Icon(Icons.camera, size: 70),
                    ),
                    const _SpacingWidget(),
                    InkWell(
                      onTap: () =>
                          context.read<CameraViewModel>().returnData(context),
                      child: const Icon(Icons.check, size: 50),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: _FlashToggleButton(),
            ),
          ),
        ),
        Positioned(
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
        ),
      ],
    );
  }
}

class _FlashToggleButton extends StatelessWidget {
  const _FlashToggleButton({Key? key}) : super(key: key);

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
  const _CameraWidget({Key? key, required this.turns}) : super(key: key);

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
  const _SpacingWidget({Key? key, this.axis = Axis.vertical}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (axis == Axis.horizontal) {
      return const SizedBox(width: 30);
    }

    return const SizedBox(height: 30);
  }
}

class _RollingGalleryShowCase extends StatefulWidget {
  final Map<int, CameraItemMetadata> photoCheckerMap;
  final IconData? suffixIcon;
  final Icon? prefixIcon;
  final int animationDurationInMilli;

  const _RollingGalleryShowCase({
    Key? key,
    this.suffixIcon = Icons.photo_library_sharp,
    this.prefixIcon,
    this.animationDurationInMilli = 375,
    required this.photoCheckerMap,
  }) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _RollingGalleryShowCaseBarState createState() =>
      _RollingGalleryShowCaseBarState();
}

class _RollingGalleryShowCaseBarState extends State<_RollingGalleryShowCase>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    context.read<CameraViewModel>().setAnimationController(AnimationController(
          vsync: this,
          duration: Duration(milliseconds: widget.animationDurationInMilli),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      alignment: Alignment.centerRight,
      children: [
        context.watch<CameraViewModel>().toggle == 1
            ? const SizedBox.shrink()
            : Material(
                color: context.read<CameraViewModel>().cardColor ??
                    Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(30.0),
                child: IconButton(
                  splashRadius: 19.0,
                  iconSize: 60,
                  color: Colors.transparent.withOpacity(0),
                  icon: widget.prefixIcon != null
                      ? context.watch<CameraViewModel>().toggle == 1
                          ? Icon(
                              Icons.arrow_back_ios,
                              color:
                                  context.read<CameraViewModel>().iconColor ??
                                      Colors.white,
                            )
                          : widget.prefixIcon!
                      : Icon(
                          context.watch<CameraViewModel>().toggle == 1
                              ? Icons.arrow_back_ios
                              : widget.suffixIcon,
                          color: context.read<CameraViewModel>().iconColor ??
                              Colors.white,
                          size: 35.0,
                        ),
                  onPressed: () {
                    if (context.read<CameraViewModel>().toggle == 0) {
                      context.read<CameraViewModel>().setToggle(1);
                      context
                          .read<CameraViewModel>()
                          .animationController
                          .forward();
                      return;
                    }

                    context.read<CameraViewModel>().setToggle(0);
                    context
                        .read<CameraViewModel>()
                        .animationController
                        .reverse();
                  },
                ),
              ),
        AnimatedContainer(
          duration: Duration(milliseconds: widget.animationDurationInMilli),
          height: (context.watch<CameraViewModel>().toggle == 0)
              ? 0
              : MediaQuery.of(context).size.height * 0.4,
          width: (context.watch<CameraViewModel>().toggle == 0)
              ? 0
              : MediaQuery.of(context).size.width * 0.6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.grey.shade800.withOpacity(0.8),
          ),
          child: Stack(
            fit: StackFit.loose,
            children: [
              GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(20),
                children: [
                  if (context.watch<CameraViewModel>().toggle == 1)
                    ...widget.photoCheckerMap.entries.map((item) {
                      if (item.value.contentData == null) return Container();
                      final data = item.value.contentData;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              fit: StackFit.loose,
                              children: [
                                Builder(builder: (context) {
                                  // ignore: prefer_typing_uninitialized_variables
                                  late final image;
                                  if (data?.path != null) {
                                    final file = File(data!.path!);
                                    image = MemoryImage(file.readAsBytesSync());
                                  } else {
                                    image = const AssetImage(
                                        'image_provider_assets/imgs/placeholder.jpg',
                                        package: 'image_provider');
                                  }
                                  return ImageHolder(
                                      images: [DecorationImage(image: image)],
                                      child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .aspectRatio *
                                              175,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .aspectRatio *
                                              175,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              image: DecorationImage(
                                                  image: image,
                                                  fit: BoxFit.fill))));
                                }),
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: GestureDetector(
                                      onTap: () => context
                                          .read<CameraViewModel>()
                                          .removeImageByIndex(item.key),
                                      child: const Icon(Icons.cancel,
                                          color: Colors.red, size: 18)),
                                ),
                              ],
                            ),
                            Text(item.value.title!,
                                style: context
                                    .read<CameraViewModel>()
                                    .galleryPhotoTitleTextStyle),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
              Positioned(
                top: -6,
                left: -6,
                child: IconButton(
                    onPressed: () {
                      if (context.read<CameraViewModel>().toggle == 0) {
                        context.read<CameraViewModel>().setToggle(1);
                        context
                            .read<CameraViewModel>()
                            .animationController
                            .forward();
                        return;
                      }
                      context.read<CameraViewModel>().setToggle(0);
                      context
                          .read<CameraViewModel>()
                          .animationController
                          .reverse();
                    },
                    icon: const Icon(Icons.cancel)),
              )
            ],
          ),
        ),
      ],
    );
  }
}
