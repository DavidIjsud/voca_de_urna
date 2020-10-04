import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vision/captura_imagen.dart';
import 'package:flutter_vision/captura_imagen_two.dart';
import 'package:flutter_vision/main.dart';
import 'package:flutter_vision/sigla.dart';

class MainPage extends StatefulWidget {
  MainPage();

  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  CollectionReference resultadoDEVotos;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("Entro");
    initializeFlutterFire();
  }

  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
    } catch (e) {
      print("Error al inciar firestore " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Segundo parcial Software"),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CapturaImagen(),
                  ),
                );
              },
              child: Container(
                child: Text("ENVIAR ACTA"),
              ),
            ),
            RaisedButton(
              onPressed: () {
                _mostrarDialog(context);
              },
              child: Container(
                child: Text("VER RESULTADOS ONLINE"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialog(BuildContext contexto) {
    final tamanoPhone = MediaQuery.of(contexto).size;

    showDialog(
        context: contexto,
        barrierDismissible: true,
        builder: (BuildContext contexto) {
          resultadoDEVotos =
              FirebaseFirestore.instance.collection('elecciones');
          return Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  color: Colors.white),
              height: tamanoPhone.height * 0.9,
              child: Container(
                width: double.infinity,
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        "Resultado de votos en tiempo real",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: this.resultadoDEVotos.snapshots(),
                      builder: (BuildContext contexto,
                          AsyncSnapshot<QuerySnapshot> snapShot) {
                        if (snapShot.hasError) {
                          return CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                          );
                        }

                        if (snapShot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                          );
                        }

                        QueryDocumentSnapshot queryDocumentSnapshot =
                            snapShot.data.docs[0];

                        List<Sigla> listaDeSiglaMasVoto = List();

                        queryDocumentSnapshot.data().forEach((key, value) {
                          listaDeSiglaMasVoto
                              .add(Sigla(nombre: key, votos: value));
                        });

                        return Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: listaDeSiglaMasVoto.length,
                            itemBuilder: (BuildContext contexto, int indice) {
                              return Card(
                                elevation: 10,
                                child: ListTile(
                                  leading:
                                      Text(listaDeSiglaMasVoto[indice].nombre),
                                  title: Text(listaDeSiglaMasVoto[indice]
                                      .votos
                                      .toString()),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
