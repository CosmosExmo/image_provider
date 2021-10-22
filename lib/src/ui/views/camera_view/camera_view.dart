part of image_provider;

class CameraView extends StatefulWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CameraViewModel(),
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
    WidgetsBinding.instance!.addObserver(this);
    context.read<CameraViewModel>().getData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
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
        Positioned.fill(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
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
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Selector<CameraViewModel, String?>(
                      shouldRebuild: (a, b) => a != b,
                      selector: (_, model) => model.lastImage,
                      builder: (context, value, child) {
                        return CircleAvatar(
                          radius: 25.0,
                          backgroundImage:
                              value != null ? AssetImage(value) : null,
                        );
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
          left: 0,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: _FlashToggleButton(),
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
                        return CircleAvatar(
                          radius: 25.0,
                          backgroundImage:
                              value != null ? AssetImage(value) : null,
                        );
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

                            final _offset =
                                context.read<CameraViewModel>().tabOffset;
                            final _rect = Rect.fromCenter(
                                center: _offset, width: 200, height: 200);

                            return Positioned.fromRect(
                              rect: _rect,
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
  final Axis axis;
  const _SpacingWidget({Key? key, this.axis = Axis.vertical}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (axis == Axis.horizontal) {
      return const SizedBox(width: 30);
    }

    return const SizedBox(height: 30);
  }
}
