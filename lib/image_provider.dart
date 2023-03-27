library image_provider;

import 'dart:math';

import 'package:camera/camera.dart';
import 'package:dialog_service/dialog_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_provider/src/models/image_export.dart';
import 'package:image_provider/src/ui/views/camera_view/camera_viewmodel.dart';
import 'package:image_provider/src/utils/compress_image.dart';
import 'package:image_provider/src/widgets/rolling_photo_gallery_widget.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

part 'src/app/enums.dart';
part 'src/image_provider.dart';
part 'src/ui/views/camera_view/camera_view.dart';
part 'src/ui/views/widgets/radial_menu.dart';
part 'src/ui/views/widgets/repository_type_selection_widget.dart';
part 'src/options/camera_view_metadata_item.dart';
part 'src/options/camera_options.dart';
