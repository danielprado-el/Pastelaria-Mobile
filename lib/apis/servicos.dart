import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pastelaria/autentificador.dart';

final URL_SERVICOS = Uri.parse("http://10.0.2.2");

final URL_PASTEIS = "${URL_SERVICOS.toString()}:5001/pasteis";
final URL_PASTEL = "${URL_SERVICOS.toString()}:5001/pastel";

final URL_COMENTARIOS = "${URL_SERVICOS.toString()}:5002/comentarios";
final URL_ADICIONAR_COMENTARIO = "${URL_SERVICOS.toString()}:5002/adicionar";
final URL_REMOVER_COMENTARIO = "${URL_SERVICOS.toString()}:5002/remover";

final URL_CURTIU = "${URL_SERVICOS.toString()}:5003/curtiu";
final URL_CURTIR = "${URL_SERVICOS.toString()}:5003/curtir";
final URL_DESCURTIR = "${URL_SERVICOS.toString()}:5003/descurtir";

final URL_ARQUIVOS = "${URL_SERVICOS.toString()}:5005";

class ServicoPasteis {
  Future<List<dynamic>> getPasteis(int pagina, int tamanhoPagina) async {
    final resposta = await http
        .get(Uri.parse("${URL_PASTEIS.toString()}/$pagina/$tamanhoPagina"));
    final pasteis = jsonDecode(resposta.body);

    return pasteis;
  }

  Future<List<dynamic>> findPasteis(
      int pagina, int tamanhoPagina, String nome) async {
    final resposta = await http.get(
        Uri.parse("${URL_PASTEIS.toString()}/$pagina/$tamanhoPagina/$nome"));
    final pasteis = jsonDecode(resposta.body);

    return pasteis;
  }

  Future<Map<String, dynamic>> findPastel(int idPastel) async {
    final resposta =
        await http.get(Uri.parse("${URL_PASTEL.toString()}/$idPastel"));
    final pasteis = jsonDecode(resposta.body);

    return pasteis;
  }
}

class ServicoCurtidas {
  Future<bool> curtiu(Usuario usuario, int idPastel) async {
    final resposta = await http
        .get(Uri.parse("${URL_CURTIU.toString()}/${usuario.email}/$idPastel"));
    final resultado = jsonDecode(resposta.body);

    return resultado["curtiu"] as bool;
  }

  Future<dynamic> curtir(Usuario usuario, int idPastel) async {
    final resposta = await http
        .post(Uri.parse("${URL_CURTIR.toString()}/${usuario.email}/$idPastel"));

    return jsonDecode(resposta.body);
  }

  Future<dynamic> descurtir(Usuario usuario, int idPastel) async {
    final resposta = await http.post(
        Uri.parse("${URL_DESCURTIR.toString()}/${usuario.email}/$idPastel"));

    return jsonDecode(resposta.body);
  }
}

class ServicoComentarios {
  Future<List<dynamic>> getComentarios(
      int idPastel, int pagina, int tamanhoPagina) async {
    final resposta = await http.get(Uri.parse(
        "${URL_COMENTARIOS.toString()}/$idPastel/$pagina/$tamanhoPagina"));
    final comentarios = jsonDecode(resposta.body);

    return comentarios;
  }

  Future<dynamic> adicionar(
      int idPastel, Usuario usuario, String comentario) async {
    final resposta = await http.post(Uri.parse(
        "${URL_ADICIONAR_COMENTARIO.toString()}/$idPastel/${usuario.nome}/${usuario.email}/$comentario"));

    return jsonDecode(resposta.body);
  }

  Future<dynamic> remover(int idComentario) async {
    final resposta = await http.delete(
        Uri.parse("${URL_REMOVER_COMENTARIO.toString()}/$idComentario"));

    return jsonDecode(resposta.body);
  }
}

String caminhoArquivo(String arquivo) {
  return "${URL_ARQUIVOS.toString()}/$arquivo";
}
