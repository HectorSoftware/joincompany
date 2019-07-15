import 'package:joincompany/async_image_repository/ImageRepository.dart';
import 'package:test_api/test_api.dart';

var img = "https://previews.123rf.com/images/pandavector/pandavector1612/pandavector161200463/69448631-icono-de-ri%C3%B1ones-humanos-en-el-estilo-de-contorno-aislado-en-el-fondo-blanco-%C3%B3rganos-humanos-ilustraci%C3%B3n-s%C3%ADmbol.jpg";

void main(){
  ImageRepository repo =ImageRepository.handler;

  test('prueba imagenes',() async{
    var file = await repo.RetrieveImageFromUrl(img);
    if (await repo.ImageExists(img)) {
      print(file);
    } else if (await repo.ImageDoesNotExist(img)) {
      print("GTFO");
    }
  });
}