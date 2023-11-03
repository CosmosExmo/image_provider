library image_provider;

import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:dialog_service/dialog_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:focused_image_widget/focused_image_widget.dart';
import 'package:image_provider/src/models/image_export.dart';
import 'package:image_provider/src/ui/views/camera_view/camera_viewmodel.dart';
import 'package:image_provider/src/utils/compress_image.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:permission_manager/permission_manager.dart';
import 'package:provider/provider.dart';

export 'package:image_provider/src/models/image_export.dart';
export 'package:multi_image_picker_plus/multi_image_picker_plus.dart'
    show AssetThumb;
export 'package:permission_manager/permission_manager.dart';

part 'src/app/enums.dart';
part 'src/image_provider.dart';
part 'src/options/camera_options.dart';
part 'src/options/camera_view_metadata_item.dart';
part 'src/ui/views/camera_view/camera_view.dart';
part 'src/ui/views/widgets/radial_menu.dart';
part 'src/ui/views/widgets/repository_type_selection_widget.dart';
