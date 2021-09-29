part of image_provider;

class ImageProvider {
  final BuildContext _context;
  final RepositoryTypeSelectionWidget _widget;

  ImageProvider(this._context, this._widget);

  ImageExport? _imageExport;

  Future<RepositoryType?> get _pickRepository async {
    final _dialogService = DialogService();

    final result = await _dialogService.showModalReturnData<RepositoryType>(
      _context,
      _widget,
    );

    return result;
  }

  Future<ImageExport?> getImages({int maxImage = 50}) async {
    final _repositoryType = await _pickRepository;

    switch (_repositoryType) {
      case RepositoryType.camera:
        await _getCameraImages();
        break;
      case RepositoryType.gallery:
        await _getGalleryImages(maxImage);
        break;
      case RepositoryType.local:
        break;
      default:
    }

    return _imageExport;
  }

  Future<void> _getCameraImages() async {
    final images = await Navigator.push<ImageExport>(
      _context,
      MaterialPageRoute(
        builder: (_) => const CameraView(),
      ),
    );

    _imageExport = images;
  }

  Future<void> _getGalleryImages(int maxImage) async {
    try {
      final images = await MultiImagePicker.pickImages(
        maxImages: maxImage,
      );

      final imageExport = ImageExport.gallery();

      await Future.wait<void>(List.from(
        images.map<Future<void>>((item) async {
          final _params = ImageCompressParams(
              repositoryType: RepositoryType.gallery, imageData: item);
          final value = await compute(getImageCompressed, _params);
          imageExport.images?.add(value);
        }),
      ));

      /* for (var item in images) {
        final byteData = await getImageCompressed(RepositoryType.Gallery, item);
        imageExport.images!.add(byteData);
      } */

      _imageExport = imageExport;
    } on NoImagesSelectedException catch (_) {
      return;
    }
  }
}
