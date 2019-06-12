import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class TomarImage extends StatefulWidget {
  @override
  _TomarImageState createState() => _TomarImageState();
}

class _TomarImageState extends State<TomarImage> {
  File img;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Escoja Una Opcion'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('IMAGEN'),
          img == null ? Container(
            child: Center(child: Text(""),),
          ) : Image.file(img),
          img != null ? RaisedButton(
            color: Colors.transparent,
            child: Text('Eliminar Imagen'),
            elevation: 0,

            onPressed: (){
              setState(() {
                img = null;
              });
            },
          ):Container(),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('CAMARA'),
          onPressed: () async {
            img = await ImagePicker.pickImage(source: ImageSource.camera);
            setState(() {
              img;
            });
          },
        ),
        FlatButton(
          child: Text('GALERIA'),
          onPressed: () async {
            img = await ImagePicker.pickImage(source: ImageSource.gallery);
            setState(() {
              img;
            });
          },
        ),
        FlatButton(
          child: const Text('GUARDAR'),
          onPressed: () async {
            Uint8List imgValue = Uint8List.fromList(img.readAsBytesSync());
            Navigator.of(context).pop(imgValue);
          },
        )
      ],
    );
  }

}
