import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/pages/canvasIMG/canvasImg.dart';
import 'dart:convert';

class PickerImgNetwork extends StatefulWidget {
  PickerImgNetwork({this.netImage});
  final String netImage;
  @override
  _PickerImgNetworkState createState() => _PickerImgNetworkState();
}

class _PickerImgNetworkState extends State<PickerImgNetwork> {


  File img;
  Image  imgSave;

  @override
  Widget build(BuildContext context) {
    imgSave =  Image.network(widget.netImage);
    return AlertDialog(
      title: Text('Imagen desde Servidor'),
      content: Container(
        height: MediaQuery.of(context).size.height*0.40,
        child: Column(
          children: <Widget>[
            Text('IMAGEN'),
            Container(
              height: MediaQuery.of(context).size.width*0.5,
              child: Center(child: Image(image: imgSave.image),),
            ),
          ],
        ),
      ),
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
        return CanvasImg(img);
      },
    );
  }
}
