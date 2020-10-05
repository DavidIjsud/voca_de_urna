import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_vision/image_detail.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CapturaImagen extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<CapturaImagen> {
  File _selectedFile, _selectedFileActa;
  String _codigoActa;
  bool _inProcess = false;

  Widget getImageWidget() {
    if (_selectedFile != null) {
      return Image.file(
        _selectedFile,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        "assets/placeholder.jpeg",
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      );
    }
  }

  Widget getImageWidgetActa() {
    if (_selectedFileActa != null) {
      return Image.file(
        _selectedFileActa,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        "assets/placeholder.jpeg",
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      );
    }
  }

  getImageActa(ImageSource source) async {
    this.setState(() {
      _inProcess = true;
    });
    File image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: image.path,
          /*aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ], */
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Seleccionar imagen completa',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
             // initAspectRatio: CropAspectRatioPreset.original,
             // lockAspectRatio: false),
         // iosUiSettings: IOSUiSettings(
          //  minimumAspectRatio: 1.0,
          )); 

      /*  File cropped = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxWidth: 700,
          maxHeight: 700,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.deepOrange,
            toolbarTitle: "RPS Cropper",
            statusBarColor: Colors.deepOrange.shade900,
            backgroundColor: Colors.white,
          )); */

      this.setState(() {
        _selectedFileActa = cropped;
        _inProcess = false;
      });
    } else {
      this.setState(() {
        _inProcess = false;
      });
    }
  }

  getImage(ImageSource source) async {
    this.setState(() {
      _inProcess = true;
    });
    File image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Seleccionar solo votos',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));

      /*  File cropped = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxWidth: 700,
          maxHeight: 700,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.deepOrange,
            toolbarTitle: "RPS Cropper",
            statusBarColor: Colors.deepOrange.shade900,
            backgroundColor: Colors.white,
          )); */

      this.setState(() {
        _selectedFile = cropped;
        _inProcess = false;
      });
    } else {
      this.setState(() {
        _inProcess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        SafeArea(
            child: SingleChildScrollView(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Seleccionar imagen solo la parte de los votos", textAlign: TextAlign.center ,style: TextStyle( fontSize: 18.0, color: Colors.red ), ),
                getImageWidget(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MaterialButton(
                        color: Colors.green,
                        child: Text(
                          "Camara",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          getImage(ImageSource.camera);
                        }),
                    MaterialButton(
                        color: Colors.deepOrange,
                        child: Text(
                          "Dispositivo",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          getImage(ImageSource.gallery);
                        })
                  ],
                ),
                SizedBox( height: 50.0, ),
                Text("Seleccionar imagen completa del acta", textAlign: TextAlign.center , style: TextStyle( fontSize: 18.0 ,color: Colors.red ), ),
                //ESTO ES PARA EL ACTA COMPLETA
                 getImageWidgetActa(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MaterialButton(
                        color: Colors.green,
                        child: Text(
                          "Camara",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          getImageActa(ImageSource.camera);
                        }),
                    MaterialButton(
                        color: Colors.deepOrange,
                        child: Text(
                          "Dispositivo",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          getImageActa(ImageSource.gallery);
                        })
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric( horizontal: 10.0 ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Ingresar identificador del acta" 
                    ),
                    onChanged: (value){
                        this.setState(() {
                            this._codigoActa = value;
                         });
                    },
                  ),
                ),

                //////
                MaterialButton(
                    color: Colors.deepOrange,
                    child: Text(
                      "Enviar a analizar",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: this._selectedFile != null && this._selectedFileActa != null && this._codigoActa != null && this._codigoActa != ""
                        ? () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DetailScreen( imagePath: this._selectedFile.path, imagenActa: this._selectedFileActa.path, codigoActa: this._codigoActa, archivActa: this._selectedFileActa, )));
                          }
                        : null)
              ],
          ),
            ),
        ),
        (_inProcess)
            ? Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height * 0.95,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Center()
      ],
    ));
  }
}
