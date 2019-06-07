import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joincompany/main.dart';
import 'canvasImg.dart';

class PickerImg extends StatefulWidget {
  @override
  _PickerImgState createState() => _PickerImgState();
}

class _PickerImgState extends State<PickerImg> {
  File img;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Firma del Cliente'),
      actions: <Widget>[
        FlatButton(
          child: const Text('Continuar'),
          onPressed: () async {
            var customImg = await editImg(img);
            Navigator.of(context).pop(customImg);
          },
        )
      ],
    );
  }

  Future<Uint8List> editImg(File img) async{
    return showDialog<Uint8List>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        if(img != null){
          return CanvasImg(Image.file(img));

        }else{
          return CanvasImg(null);
        }
      },
    );
  }
}
