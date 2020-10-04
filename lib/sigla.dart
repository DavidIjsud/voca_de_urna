import 'dart:convert';

Sigla siglaFromJson(String str) => Sigla.fromJson(json.decode(str));

String siglaToJson(Sigla data) => json.encode(data.toJson());

class Sigla {
  Sigla({
    this.nombre,
    this.votos,
  });

  String nombre;
  int votos;

  factory Sigla.fromJson(Map<String, dynamic> json) => Sigla(
        nombre: json["nombre"],
        votos: json["votos"],
      );

  Map<String, dynamic> toJson() => {
        "nombre": nombre,
        "votos": votos,
      };
}
