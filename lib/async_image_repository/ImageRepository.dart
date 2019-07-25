import 'dart:io';
import 'package:joincompany/main.dart';
import 'package:path_provider/path_provider.dart';

class ImageRepository {
  ImageRepository._();
  static final ImageRepository handler = ImageRepository._();

  Future<String> get _localPath async {
    try{
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }catch(error, stackTrace) {
      await sentryA.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      await sentryH.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      return "";
    }
  }

  Future<File> _getRawImage(String fileName) async {
    try{
      final path = await _localPath;
      return File('$path/$fileName');
    }catch(error, stackTrace) {
      await sentryA.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      await sentryH.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<bool> imageExists(String fileName) async {
    try{
      return await (await _getRawImage(fileName)).exists();
    }catch(error, stackTrace) {
      await sentryA.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      await sentryH.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> imageDoesNotExist(String fileName) async {
    try{
      return !(await (await _getRawImage(fileName)).exists());
    }catch(error, stackTrace) {
      await sentryA.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      await sentryH.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      return false;
    }

  }

  Future<File> downloadImage(String fileName, String url) async {
    try{
      final file = await _getRawImage(fileName);
      HttpClient().getUrl(Uri.parse(url))
          .then((HttpClientRequest request) =>
          request.close())
          .then((HttpClientResponse response) =>
          response.pipe(file.openWrite()));
      return file;
    }catch(error, stackTrace) {
      await sentryA.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      await sentryH.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      return null;
    }

  }

  Future<File> retrieveImage(String fileName) async {
    try{
      return await _getRawImage(fileName);
    }catch(error, stackTrace) {
      await sentryA.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      await sentryH.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      return null;
    }
    
  }

  Future<FileSystemEntity> deleteImage(String fileName) async {
    try{
      final file = await _getRawImage(fileName);
      return await file.delete();
    }catch(error, stackTrace) {
      await sentryA.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      await sentryH.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
      return null;
    }
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