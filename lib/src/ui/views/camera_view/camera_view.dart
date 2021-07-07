part of image_provider;

class CameraView extends StatefulWidget {
  CameraView({Key? key}) : super(key: key);

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<CameraViewModel>(
        future: CameraViewModel().init,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ChangeNotifierProvider(
            create: (_) => snapshot.data,
            builder: (context, child) {
              return _CameraViewContent();
            },
          );
        },
      ),
    );
  }
}

class _CameraViewContent extends StatelessWidget {
  const _CameraViewContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final permissionStatus = context
        .select<CameraViewModel, bool>((model) => model.hasCameraPermission);
    if (permissionStatus) {
      return NativeDeviceOrientationReader(
        builder: (context) {
          final orientation =
              NativeDeviceOrientationReader.orientation(context);
          switch (orientation) {
            case NativeDeviceOrientation.landscapeLeft:
              return _LandscapeContent();
              break;
            case NativeDeviceOrientation.landscapeRight:
              return _LandscapeContent();
              break;
            case NativeDeviceOrientation.portraitUp:
              return _PortraitContent();
              break;
            case NativeDeviceOrientation.portraitDown:
              return _PortraitContent();
              break;
            default:
              return _PortraitContent();
          }
        },
      );
    } else {
      return _NoPermissionView();
    }
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
            children: [
              Text(
                "Kamerayı kullanabilmek için gerekli izinlerin verilmesi gerekmektedir!",
              ),
              _SpacingWidget(),
              ElevatedButton(
                onPressed:
                    context.read<CameraViewModel>().requestCameraPermission,
                child: Text(
                  "İzinleri Al",
                ),
              )
            ],
          ),
        )),
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
                    CircleAvatar(
                      radius: 25.0,
                      backgroundColor: Colors.transparent,
                    ),
                    _SpacingWidget(),
                    InkWell(
                      onTap: () {},
                      child: Icon(
                        Icons.camera,
                        size: 70,
                        color: Colors.transparent,
                      ),
                    ),
                    _SpacingWidget(),
                    InkWell(
                      onTap: () =>
                          context.read<CameraViewModel>().returnData(context),
                      child: Icon(Icons.arrow_back, size: 50),
                    ),
                  ],
                ),
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
        Positioned.fill(child: _CameraWidget()),
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
                    _SpacingWidget(),
                    InkWell(
                      onTap: context.read<CameraViewModel>().captureImage,
                      child: Icon(Icons.camera, size: 70),
                    ),
                    _SpacingWidget(),
                    InkWell(
                      onTap: () =>
                          context.read<CameraViewModel>().returnData(context),
                      child: Icon(Icons.check, size: 50),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
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
        Positioned.fill(child: _CameraWidget()),
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
                    _SpacingWidget(),
                    InkWell(
                      onTap: context.read<CameraViewModel>().captureImage,
                      child: Icon(Icons.camera, size: 70),
                    ),
                    _SpacingWidget(),
                    InkWell(
                      onTap: () =>
                          context.read<CameraViewModel>().returnData(context),
                      child: Icon(Icons.check, size: 50),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
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
    return Selector<CameraViewModel, FlashType?>(
      selector: (_, model) => model.flashType,
      builder: (context, value, widget) {
        return RadialMenu(
          icon: _getFlashIcon(value),
          entries: [
            RadialMenuEntry(
              icon: Icons.flash_auto,
              onTap: () {
                final type = FlashType.auto;
                context.read<CameraViewModel>().setFlashMode(type);
              },
            ),
            RadialMenuEntry(
              icon: Icons.flash_on,
              onTap: () {
                final type = FlashType.on;
                context.read<CameraViewModel>().setFlashMode(type);
              },
            ),
            RadialMenuEntry(
              icon: Icons.flash_off,
              onTap: () {
                final type = FlashType.off;
                context.read<CameraViewModel>().setFlashMode(type);
              },
            ),
          ],
        );
      },
    );
  }

  IconData _getFlashIcon(FlashType? type) {
    switch (type) {
      case FlashType.auto:
        return Icons.flash_auto;
        break;
      case FlashType.on:
        return Icons.flash_on;
        break;
      case FlashType.off:
        return Icons.flash_off;
        break;
      default:
        return Icons.flash_auto;
    }
  }
}

class _CameraWidget extends StatelessWidget {
  const _CameraWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<CameraViewModel, FlashType?>(
      selector: (_, model) => model.flashType,
      builder: (context, value, child) {
        return AdvCamera(
          initialCameraType: CameraType.rear,
          cameraPreviewRatio: CameraPreviewRatio.r16_9,
          cameraSessionPreset: CameraSessionPreset.photo,
          focusRectColor: Theme.of(context).primaryColor,
          flashType: value!,
          onCameraCreated: context.read<CameraViewModel>().setCameraController,
          onImageCaptured: context.read<CameraViewModel>().onCapture,
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
      return SizedBox(width: 30);
    }

    return SizedBox(height: 30);
  }
}
