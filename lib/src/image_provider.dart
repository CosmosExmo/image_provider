part of image_provider;

class ImageProvider {
  final BuildContext _context;
  final RepositoryTypeSelectionWidget? widget;
  final RepositoryType? repositoryType;
  final CameraViewOptions? options;
  final ColorScheme? colorScheme;

  ImageProvider(this._context,
      {this.widget, this.options, this.repositoryType, this.colorScheme})
      : assert(widget != null || repositoryType != null,
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
        builder: (_) => CameraView(options),
      ),
    );

    _imageExport = images;
  }

  Future<void> _getGalleryImages(int maxImage) async {
    try {
      final permissionPanager = PermissionManager();
      await permissionPanager.requestMedia(photos: true);
      await permissionPanager.requestMediaLocation();

      final ColorScheme colorSchemeTheme =
          // ignore: use_build_context_synchronously
          colorScheme ?? Theme.of(_context).colorScheme;

      List<Asset> resultList = <Asset>[];

      const AlbumSetting albumSetting = AlbumSetting(
        fetchResults: {
          PHFetchResult(
            type: PHAssetCollectionType.smartAlbum,
            subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary,
          ),
          PHFetchResult(
            type: PHAssetCollectionType.smartAlbum,
            subtype: PHAssetCollectionSubtype.smartAlbumFavorites,
          ),
          PHFetchResult(
            type: PHAssetCollectionType.album,
            subtype: PHAssetCollectionSubtype.albumRegular,
          ),
          PHFetchResult(
            type: PHAssetCollectionType.smartAlbum,
            subtype: PHAssetCollectionSubtype.smartAlbumSelfPortraits,
          ),
          PHFetchResult(
            type: PHAssetCollectionType.smartAlbum,
            subtype: PHAssetCollectionSubtype.smartAlbumPanoramas,
          ),
          PHFetchResult(
            type: PHAssetCollectionType.smartAlbum,
            subtype: PHAssetCollectionSubtype.smartAlbumVideos,
          ),
        },
      );
      SelectionSetting selectionSetting = SelectionSetting(
        min: 1,
        max: maxImage,
        unselectOnReachingMax: true,
      );
      const DismissSetting dismissSetting = DismissSetting(
        enabled: true,
        allowSwipe: true,
      );
      final ThemeSetting themeSetting = ThemeSetting(
        backgroundColor: colorSchemeTheme.background,
        selectionFillColor: colorSchemeTheme.primary,
        selectionStrokeColor: colorSchemeTheme.onPrimary,
        previewSubtitleAttributes: const TitleAttribute(fontSize: 12.0),
        previewTitleAttributes: TitleAttribute(
          foregroundColor: colorSchemeTheme.primary,
        ),
        albumTitleAttributes: TitleAttribute(
          foregroundColor: colorSchemeTheme.primary,
        ),
      );
      const ListSetting listSetting = ListSetting(
        spacing: 5.0,
        cellsPerRow: 4,
      );
      final CupertinoSettings iosSettings = CupertinoSettings(
        fetch: const FetchSetting(album: albumSetting),
        theme: themeSetting,
        selection: selectionSetting,
        dismiss: dismissSetting,
        list: listSetting,
      );

      /// PICK MULTIPLE IMAGES FROM GALLERY
      resultList = await MultiImagePicker.pickImages(
        selectedAssets: resultList,
        cupertinoOptions: CupertinoOptions(
          doneButton: UIBarButtonItem(
              title: 'Onayla', tintColor: colorSchemeTheme.primary),
          cancelButton: UIBarButtonItem(
              title: 'İptal', tintColor: colorSchemeTheme.primary),
          albumButtonColor: colorSchemeTheme.primary,
          settings: iosSettings,
        ),
        materialOptions: MaterialOptions(
          actionBarColor: colorSchemeTheme.primary,
          actionBarTitleColor: colorSchemeTheme.onPrimary,
          statusBarColor: colorSchemeTheme.primary,
          actionBarTitle: "Resim Seçin",
          allViewTitle: "Tüm Resimler",
          maxImages: maxImage,
          useDetailsView: false,
          selectCircleStrokeColor: colorSchemeTheme.primary,
        ),
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
        final content = ContentData.fromData("jpg", compressedImg);
        imageExport.imgadder = content;
      }
      _imageExport = imageExport;
    } catch (_) {
      return;
    }
  }

  static Future<List<ContentData>> getCompressedImageList(
      {required List<Asset> assetimgs}) async {
    List<ContentData> contentImages = [];
    final paramList = List.generate(
        assetimgs.length,
        (index) => ImageCompressParams(
            repositoryType: RepositoryType.gallery,
            imageData: assetimgs.elementAt(index)));
    final compressedList = await getImageCompressedList(paramList);
    for (var compressedImg in compressedList) {
      final content = ContentData.fromData("jpg", compressedImg);
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

      await Future.wait<void>(List.from(
        images.files.map<Future<void>>((item) async {
          final content = ContentData.fromData(
            item.extension,
            item.bytes,
            fileName: item.name,
          );
          imageExport.imgadder = content;
        }),
      ));

      _imageExport = imageExport;
    } catch (_) {

      return;
    }
  }
}
