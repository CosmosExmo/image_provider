library;

import 'dart:async';
import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:dialog_service/dialog_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:flutter_image_compress/flutter_image_compress.dart'
    show CompressFormat;
import 'package:focused_image_widget/focused_image_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_provider/src/helpers/compress_image_helper.dart';
import 'package:image_provider/src/models/image_export.dart';
import 'package:image_provider/src/ui/views/camera_view/camera_viewmodel.dart';
import 'package:image_provider/src/utils/device_type.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:permission_manager/permission_manager.dart';
import 'package:provider/provider.dart';

export 'package:image_provider/src/models/image_export.dart';
export 'package:permission_manager/permission_manager.dart';

part 'src/app/enums.dart';
part 'src/image_provider.dart';
part 'src/options/camera_options.dart';
part 'src/options/camera_view_metadata_item.dart';
part 'src/options/compression_options.dart';
part 'src/ui/views/camera_view/camera_view.dart';
part 'src/ui/views/widgets/repository_type_selection_widget.dart';
