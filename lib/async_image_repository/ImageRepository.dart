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

  Future<bool> ImageExists(String url) async {
    final fileName = basename(url);
    return await (await _getRawImage(fileName)).exists();
  }

  Future<bool> ImageDoesNotExist(String url) async {
    final fileName = basename(url);
    return !(await (await _getRawImage(fileName)).exists());
  }

  Future<File> RetrieveImageFromUrl(String url) async {
    final fileName = basename(url);
    final file = await _getRawImage(fileName);
    HttpClient().getUrl(Uri.parse(url))
      .then((HttpClientRequest request) =>
        request.close())
      .then((HttpClientResponse response) =>
        response.pipe(file.openWrite()));
    return file;
  }

  Future<File> ManageImage(String url) async {
    if (await ImageDoesNotExist(url))
      return await RetrieveImageFromUrl(url);
    return await _getRawImage(basename(url));
  }

  Future<FileSystemEntity> DeleteImage(String url) async {
    final fileName = basename(url);
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