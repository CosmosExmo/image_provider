library image_provider;

export 'ui/views/widgets/repository_type_selection_widget.dart';
export 'models/image_export.dart';

import 'package:animated_dialog_service/animated_dialog_service.dart';
import 'package:flutter/material.dart';
import 'package:image_provider/app/enums.dart';
import 'package:image_provider/models/image_export.dart';
import 'package:image_provider/ui/views/camera_view/camera_view.dart';
import 'package:image_provider/ui/views/widgets/repository_type_selection_widget.dart';
import 'package:image_provider/utils/compress_image.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class ImageProvider {
  final BuildContext _context;
  final RepositoryTypeSelectionWidget _widget;

  ImageProvider(this._context, this._widget);

  ImageExport _imageExport;

  Future<RepositoryType> get _pickRepository async {
    final _dialogService = AnimatedDialogService();

    final result = await _dialogService.showModalReturnData<RepositoryType>(
      _context,
      _widget,
    );

    return result;
  }

  Future<ImageExport> getImages() async {
    final _repositoryType = await _pickRepository;

    switch (_repositoryType) {
      case RepositoryType.Camera:
        print('Kamera');
        await _getCameraImages();
        break;
      case RepositoryType.Gallery:
        print('Galeri');
        await _getGalleryImages();
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

  Future<void> _getGalleryImages() async {
    try {
      final images = await MultiImagePicker.pickImages(
        maxImages: 50,
      );

      final imageExport = ImageExport.gallery();

      for (var item in images) {
        final byteData = await getImageCompressed(RepositoryType.Gallery, item);
        imageExport.images.add(byteData);
      }

      this._imageExport = imageExport;
    } on NoImagesSelectedException catch (e) {
      print(e);
      return;
    }
  }
}
