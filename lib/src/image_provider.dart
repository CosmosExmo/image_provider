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
    if (kIsWeb) {
      await _getImagesFromFile();
      return _imageExport;
    }

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
          final value = await getImageCompressed(_params);
          final _content = ContentData.fromData("jpg", value);
          imageExport.images?.add(_content);
        }),
      ));

      _imageExport = imageExport;
    } on NoImagesSelectedException catch (_) {
      return;
    }
  }

  Future<void> _getImagesFromFile() async {
    try {
      final images = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf'],
        allowMultiple: true,
        withData: true,
      );

      if (images == null) {
        return;
      }

      final imageExport = ImageExport.files();

      await Future.wait<void>(List.from(
        images.files.map<Future<void>>((item) async {
          final _content = ContentData.fromData(
            item.extension,
            item.bytes,
            fileName: item.name,
          );
          imageExport.images?.add(_content);
        }),
      ));

      _imageExport = imageExport;
    } on NoImagesSelectedException catch (_) {
      return;
    }
  }
}
