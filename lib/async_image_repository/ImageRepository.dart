import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ImageRepository {
  ImageRepository._();
  static final ImageRepository handler = ImageRepository._();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _getRawImage(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  Future<bool> ImageExists(String fileName) async {
    return await (await _getRawImage(fileName)).exists();
  }

  Future<bool> ImageDoesNotExist(String fileName) async {
    return !(await (await _getRawImage(fileName)).exists());
  }

  Future<File> DownloadImage(String fileName, String url) async {
    final file = await _getRawImage(fileName);
    HttpClient().getUrl(Uri.parse(url))
      .then((HttpClientRequest request) =>
        request.close())
      .then((HttpClientResponse response) =>
        response.pipe(file.openWrite()));
    return file;
  }

  Future<File> RetrieveImage(String fileName) async {
    return await _getRawImage(fileName);
  }

  Future<FileSystemEntity> DeleteImage(String fileName) async {
    final file = await _getRawImage(fileName);
    return await file.delete();
  }

  /*
  // ...
  Future<File> _writeRawImage(String image, List<int> data) async {
    final file = await _getRawImage(image);
    return file.writeAsBytes(data);
  }

  // ...
  Future<List<int>> _readRawImage(String image) async {
    try {
      final file = await _getRawImage(image);
      return await file.readAsBytes();
    } catch (e) {
      return List<int>();
    }
  }
  */
}