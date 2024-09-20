part of '../../image_provider.dart';

class ImageProvider {
  final BuildContext _context;
  final RepositoryTypeSelectionWidget? widget;
  final RepositoryType? repositoryType;
  final CameraViewOptions options;
  final ColorScheme? colorScheme;

  ImageProvider(
    this._context, {
    this.widget,
    this.options = const CameraViewOptions(),
    this.repositoryType,
    this.colorScheme,
  }) : assert(widget != null || repositoryType != null,
            'No repository type selected or widget provided');
  ImageExport? _imageExport;

  Future<RepositoryType?> get _pickRepository async {
    if (widget != null) {
      final dialogService = DialogService();

      final result = await dialogService.showModalReturnData<RepositoryType>(
        _context,
        widget!,
      );
      return result;
    }
    if (repositoryType != null) {
      return repositoryType;
    }
    throw Exception("No repository type selected or widget provided");
  }

  Future<ImageExport?> getImages({int maxImage = 50}) async {
    if (kIsWeb) {
      await _getImagesFromFile();
      return _imageExport;
    }

    final repositoryType = await _pickRepository;

    switch (repositoryType) {
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
        builder: (_) => CameraView(options: options),
      ),
    );

    _imageExport = images;
  }

  Future<void> _getGalleryImages(int maxImage) async {
    try {
      final permissionPanager = PermissionManager();
      await permissionPanager.requestMedia(photos: true);
      await permissionPanager.requestMediaLocation();


      final ImagePicker picker = ImagePicker();


      final List<XFile> resultList = await picker.pickMultiImage(
        limit: maxImage,
      );

      final imageExport = ImageExport.gallery();

      //imageExport.imageassets = resultList;
      final paramList = List.generate(
          resultList.length,
          (index) => ImageCompressParams(
              repositoryType: RepositoryType.gallery,
              imageData: resultList.elementAt(index)));
      final compressedList = await getImageCompressedList(paramList);
      for (var compressedImg in compressedList) {
        final content =
            ContentData(extension: "jpg", data: compressedImg, path: "");
        imageExport.imgadder = content;
      }
      _imageExport = imageExport;
    } catch (_) {
      return;
    }
  }

  static Future<List<ContentData>> getCompressedImageList(
      {required List<XFile> assetimgs}) async {
    List<ContentData> contentImages = [];
    final paramList = List.generate(
        assetimgs.length,
        (index) => ImageCompressParams(
            repositoryType: RepositoryType.gallery,
            imageData: assetimgs.elementAt(index)));
    final compressedList = await getImageCompressedList(paramList);
    for (var compressedImg in compressedList) {
      final content =
          ContentData(extension: "jpg", data: compressedImg, path: "");
      contentImages.add(content);
    }
    return contentImages;
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

      for (var item in images.files) {
        final content = ContentData(
          extension: item.extension ?? "jpg",
          data: item.bytes,
          fileName: item.name,
          path: "",
        );
        imageExport.imgadder = content;
      }

      _imageExport = imageExport;
    } catch (e, str) {
      debugPrint("ERROR $e");
      debugPrint("STACKTRACE $str");
      return;
    }
  }
}
