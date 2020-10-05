import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_vision/main_page.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:async';

import 'package:modal_progress_hud/modal_progress_hud.dart';

class DetailScreen extends StatefulWidget {
  final String imagePath, imagenActa, codigoActa;
  final File archivActa;
  DetailScreen({this.imagePath, this.imagenActa, this.codigoActa, this.archivActa});

  @override
  _DetailScreenState createState() => new _DetailScreenState(imagePath, imagenActa, codigoActa, archivActa);
}

class _DetailScreenState extends State<DetailScreen> {
  _DetailScreenState(this.path, this.acta, this.codigoActa, this.archivoActa);

  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  final String path;
  final String acta;
  final String codigoActa;
  final archivoActa;

  Map<String, String> resultadosDeLosVotos;
  List<String> listaDeREsultados;
  List<String> listaDeSiglas;

  List<int> listaDeResultadoFinalPaEnviar;

  Size _imageSize;
  List<TextElement> _elements = [];
  String recognizedText = "";

  bool cargando;
  //de firebase
  bool _initialized = false;
  bool _error = false;

  void _initializeVision() async {
    this.listaDeREsultados = List();
    final File imageFile = File(path);

    if (imageFile != null) {
      await _getImageSize(imageFile);
    }

    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);

    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();

    final VisionText visionText =
        await textRecognizer.processImage(visionImage);

    String pattern = r"^[0-9]";
    //r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";

    //Davidijsud@gmail.com
    RegExp regEx = RegExp(pattern);

    String mailAddress = "";
    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        //if (regEx.hasMatch(line.text)) {
        if (isNumeric(line.text) &&
            (line.text.length >= 1 || line.text.length <= 3)) {
          this.listaDeREsultados.add(line.text);
          mailAddress += line.text + '\n';
        }
        //}
      }
    }

    if (this.mounted) {
      setState(() {
        recognizedText = mailAddress;
      });
    }
    print(this.listaDeREsultados);
  }

  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      print("Error al inciar firestore " + e.toString());
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }

  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();

    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
  }

  @override
  void initState() {
    _initializeVision();
    super.initState();
    this.listaDeSiglas = List();
    this.listaDeSiglas.add("CC");
    this.listaDeSiglas.add("FPV");
    this.listaDeSiglas.add("MTS");
    this.listaDeSiglas.add("UCS");
    this.listaDeSiglas.add("MAS-IPSP");
    this.listaDeSiglas.add("21F");
    this.listaDeSiglas.add("PDC");
    this.listaDeSiglas.add("MNR");
    this.listaDeSiglas.add("PAN-BOL");
    initializeFlutterFire();
    this.listaDeResultadoFinalPaEnviar = List();
    this.listaDeResultadoFinalPaEnviar.clear();
    this.cargando = false;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (this.listaDeREsultados.length != 9) {
        this.globalKey.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text("Fallo en la captura de datos")));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: this.cargando,
      dismissible: false,
      progressIndicator: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
      ),
      child: Scaffold(
        key: globalKey,
        appBar: AppBar(
          title: Text("Detalle"),
        ),
        body: _imageSize != null
            ? Stack(
                children: <Widget>[
                  Center(
                    child: Container(
                      width: double.maxFinite,
                      color: Colors.black,
                      child: CustomPaint(
                        foregroundPainter:
                            TextDetectorPainter(_imageSize, _elements),
                        child: AspectRatio(
                          aspectRatio: _imageSize.aspectRatio,
                          child: Image.file(
                            File(path),
                          ),
                        ),
                      ),
                    ),
                  ),
                  this.recognizedText != "" &&
                          this.listaDeREsultados.length == 9
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: Card(
                            elevation: 8,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: RaisedButton(
                                onPressed: () {
                                  if (this.listaDeREsultados.length == 9) {
                                    _mostrarDialog(context);
                                  }
                                },
                                child: Container(
                                  child: Text("Enviar informacion"),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              )
            : Container(
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
      ),
    );
  }

  Future uploadImageToFirebase(BuildContext context) async {
    String fileName = this.acta;
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('actas_imagenes/$fileName');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(this.archivoActa);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  dynamic value =  await taskSnapshot.ref.getDownloadURL();
   print("SEra la url? "+  value.toString());

  CollectionReference actasColeccion =
                          FirebaseFirestore.instance.collection('/actas_guardadas');

  actasColeccion.doc(this.codigoActa).set({
        "CC" :  this.listaDeREsultados[0],
        "FPV" : this.listaDeREsultados[1],
        "MTS" : this.listaDeREsultados[2],
        "UCS" : this.listaDeREsultados[3],
        "MAS-IPSP" : this.listaDeREsultados[4],
        "21F"      : this.listaDeREsultados[5],
        "PDC"      : this.listaDeREsultados[6],
        "MNR"      : this.listaDeREsultados[7],
        "PAN-BOL"  : this.listaDeREsultados[8],
        "URL_IMAGEN" : value.toString()   
        
  });                       

  }

  void _mostrarDialog(BuildContext contexto) {
    final tamanoPhone = MediaQuery.of(contexto).size;

    showDialog(
        context: contexto,
        barrierDismissible: true,
        builder: (BuildContext contexto) {
          return Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  color: Colors.white),
              height: tamanoPhone.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Verificar los votos",
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: this.listaDeREsultados.length,
                      itemBuilder: (BuildContext contexto, int indice) {
                        return ListTile(
                          leading: Text(this.listaDeSiglas[indice]),
                          title: Center(
                            child: Text(
                              this.listaDeREsultados[indice] + " Votos",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();

                      this.setState(() {
                        this.cargando = true;
                      });

                      CollectionReference actasColeccion =
                          FirebaseFirestore.instance.collection('/elecciones');

                      /*  Map<String, dynamic> mapaAenviar = {
                        "CC": 0,
                        "FPV": 5,
                        "MTS": 10,
                        "UCS": 50,
                        "MAS-IPSP": 1444,
                        "21F": 15,
                        "PDC": 3,
                        "MNR": 0,
                        "PAN-BOL": 8,
                      }; */

                      /* actasColeccion
                          .doc("rFA4Z34h25viza6pF8kv")
                          .update(mapaAenviar)
                          .then((value) => () {
                                this.listaDeREsultados.clear();
                                this.listaDeResultadoFinalPaEnviar.clear();
                                print("TODO NICE");
                              }); */

                      DocumentSnapshot documento = await actasColeccion
                          .doc('rFA4Z34h25viza6pF8kv')
                          .get();
                      Map<String, dynamic> mapaAenviar;
                      if (documento.exists) {
                        Map<String, dynamic> data = documento.data();

                        try {
                          for (var i = 0;
                              i < this.listaDeREsultados.length;
                              i++) {
                            int numero = int.parse(this.listaDeREsultados[i]) +
                                data[this.listaDeSiglas[i]] as int;
                            this.listaDeResultadoFinalPaEnviar.add(numero);
                          }
                        } catch (e) {
                          print("Error " + e.toString());
                          return;
                        }

                        mapaAenviar = {
                          "CC": this.listaDeResultadoFinalPaEnviar[0],
                          "FPV": this.listaDeResultadoFinalPaEnviar[1],
                          "MTS": this.listaDeResultadoFinalPaEnviar[2],
                          "UCS": this.listaDeResultadoFinalPaEnviar[3],
                          "MAS-IPSP": this.listaDeResultadoFinalPaEnviar[4],
                          "21F": this.listaDeResultadoFinalPaEnviar[5],
                          "PDC": this.listaDeResultadoFinalPaEnviar[6],
                          "MNR": this.listaDeResultadoFinalPaEnviar[7],
                          "PAN-BOL": this.listaDeResultadoFinalPaEnviar[8],
                        };
                      }

                      print(mapaAenviar);

                      actasColeccion
                          .doc("rFA4Z34h25viza6pF8kv")
                          .update(mapaAenviar);

                    uploadImageToFirebase(contexto);

                      setState(() {
                        this.cargando = false;
                      });

                      SnackBar barra = SnackBar(
                        content: Text("Los datos fueron enviados al servidor"),
                        backgroundColor: Colors.red,
                      );

                      this.globalKey.currentState.showSnackBar(barra);

                      int count = 0;
                      Future.delayed(
                          Duration(seconds: 3),
                          () => {
                                Navigator.of(context)
                                    .popUntil((_) => count++ >= 2)
                                /* Navigator.pop(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MainPage())) */
                              });

                      /*  actasColeccion
                          .doc('rFA4Z34h25viza6pF8kv')
                          .get()
                          .then((value) => () {
                                if (!value.exists) {
                                  return;
                                }

                                Map<String, dynamic> data = value.data();

                                for (var i = 0;
                                    i < this.listaDeREsultados.length - 1;
                                    i++) {
                                  int numero =
                                      int.parse(this.listaDeREsultados[i]) +
                                          data[this.listaDeSiglas[i]] as int;
                                  this
                                      .listaDeResultadoFinalPaEnviar
                                      .add(numero);
                                }

                                try {} catch (e) {}

                                Map<String, dynamic> mapaAenviar = {
                                  "CC": this.listaDeResultadoFinalPaEnviar[0],
                                  "FPV": this.listaDeResultadoFinalPaEnviar[1],
                                  "MTS": this.listaDeResultadoFinalPaEnviar[2],
                                  "UCS": this.listaDeResultadoFinalPaEnviar[3],
                                  "MAS-IPSP":
                                      this.listaDeResultadoFinalPaEnviar[4],
                                  "21F": this.listaDeResultadoFinalPaEnviar[5],
                                  "PDC": this.listaDeResultadoFinalPaEnviar[6],
                                  "MNR": this.listaDeResultadoFinalPaEnviar[7],
                                  "PAN-BOL":
                                      this.listaDeResultadoFinalPaEnviar[8],
                                };

                                actasColeccion
                                    .doc("a")
                                    .update(mapaAenviar)
                                    .then((value) => () {
                                          this.listaDeREsultados.clear();
                                          this
                                              .listaDeResultadoFinalPaEnviar
                                              .clear();
                                          print("TODO NICE");
                                        });
                              })
                          .catchError((onError) => () {
                                print("Error :" + onError.toString());
                              }); */
                    },
                    child: Container(
                      child: Text("Enviar al servidor"),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}



class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.absoluteImageSize, this.elements);

  final Size absoluteImageSize;
  final List<TextElement> elements;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(TextContainer container) {
      return Rect.fromLTRB(
        container.boundingBox.left * scaleX,
        container.boundingBox.top * scaleY,
        container.boundingBox.right * scaleX,
        container.boundingBox.bottom * scaleY,
      );
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.red
      ..strokeWidth = 2.0;

    for (TextElement element in elements) {
      canvas.drawRect(scaleRect(element), paint);
    }
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return true;
  }
}
