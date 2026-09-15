import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );
    return file?.path;
  }
