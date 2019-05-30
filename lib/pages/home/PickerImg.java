

class PickerImg extends StatefulWidget {
  @override
  _PickerImgState createState() => _PickerImgState();
}

class _PickerImgState extends State<PickerImg> {
  File img;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('¿Desea Escoger Una Foto?'),
      content: Column(
        children: <Widget>[
          Text('IMAGEN'),
          img == null ? Container(
            child: Text("si no desea escoger foto precione continuar"),
          ) : Image.file(img),
          img != null ? IconButton(
            icon: Icon(Icons.close),
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
          child: const Text('Continuar'),
          onPressed: () async {
            var customImg = await editImg(img);
            Navigator.of(context).pop(customImg);
          },
        )
      ],
    );
  }

  Future<Image> editImg(File img) async{
    return showDialog<Image>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return CanvasImg(img);
      },
    );
  }
}
