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
      case RepositoryType.Camera:
        print('Kamera');
        await _getCameraImages();
        break;
      case RepositoryType.Gallery:
        print('Galeri');
        await _getGalleryImages(maxImage);
        break;
      case RepositoryType.Local:
        print('Local');
        break;
      default:
        print('Default');
    }

    return this._imageExport;
  }

  Future<void> _getCameraImages() async {
    final images = await Navigator.push<ImageExport>(
      _context,
      MaterialPageRoute(
        builder: (_) => CameraView(),
      ),
    );

    this._imageExport = images;
  }

  Future<void> _getGalleryImages(int maxImage) async {
    try {
      final images = await MultiImagePicker.pickImages(
        maxImages: maxImage,
      );

      final imageExport = ImageExport.gallery();

      for (var item in images) {
        final byteData = await getImageCompressed(RepositoryType.Gallery, item);
        imageExport.images!.add(byteData);
      }

      this._imageExport = imageExport;
    } on NoImagesSelectedException catch (e) {
      print(e);
      return;
    }
  }
}
