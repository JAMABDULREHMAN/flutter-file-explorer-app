import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageGallery extends StatefulWidget {
  const ImageGallery({super.key});

  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  List<File> _imageFiles = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final files = Directory(directory!.path).listSync();
      setState(() {
        _imageFiles = files
            .where((file) =>
                file.path.endsWith('.jpg') || file.path.endsWith('.png'))
            .map((e) => File(e.path))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
      ),
      itemCount: _imageFiles.length,
      itemBuilder: (context, index) {
        return Image.file(
          _imageFiles[index],
          fit: BoxFit.cover,
        );
      },
    );
  }
}
