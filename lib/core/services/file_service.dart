import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class FileService {
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    String? mimeType,
    required String dialogTitle,
    required String type,
  }) async {
    return FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      bytes: bytes,
      mimeType: mimeType!,
      type: FileType.custom,
      allowedExtensions: [type],
    );
  }

  Future<PlatformFile?> loadFile() async {
    return FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
  }
}
