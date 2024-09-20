
# Image Provider

`image_provider` is a Flutter package that simplifies the process of loading, compressing, and managing images from various sources, such as the camera, gallery, and file system. This package is designed to handle different repository types while offering compression and export functionalities.

## Features

- **Repository Type Selection**: Camera, Gallery, and File-based repositories are supported.
- **Image Compression**: Compress images for efficient storage and faster loading.
- **Cross-Platform**: Works on mobile (iOS/Android) and web.
- **Permissions Management**: Built-in integration with `PermissionManager` for managing media and location permissions.

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  image_provider: latest_version
```

Then, run:

```bash
flutter pub get
```

## Usage

### Initialize and Select Repository Type

```dart
final imageProvider = ImageProvider(context, repositoryType: RepositoryType.camera);
final images = await imageProvider.getImages();
```

### Get Images from Gallery

```dart
final imageProvider = ImageProvider(context, repositoryType: RepositoryType.gallery);
final images = await imageProvider.getImages(maxImage: 10);
```

### Get Images from File System (Web)

```dart
final imageProvider = ImageProvider(context);
final images = await imageProvider.getImages();
```

### Image Compression

To compress a list of selected images:

```dart
final compressedImages = await ImageProvider.getCompressedImageList(assetimgs: selectedFiles);
```

## Permissions

Before accessing media, ensure you handle permissions correctly:

```dart
final permissionManager = PermissionManager();
await permissionManager.requestMedia(photos: true);
```

## Image Export

The `ImageExport` class handles the final export of images. You can retrieve images from various sources (camera, gallery, file picker) and then process or compress them for your needs.

### Example Usage

```dart
final images = await imageProvider.getImages();
if (images != null) {
  for (var img in images.exportedImages) {
    // Do something with img.content
  }
}
```

## Error Handling

In case of errors (e.g., user cancels image selection), you can handle them using try-catch:

```dart
try {
  final images = await imageProvider.getImages();
} catch (e) {
  print('Error: $e');
}
```

## Contributions

Contributions are welcome! Please open an issue or submit a pull request on GitHub.

## License

This project is licensed under the MIT License.
