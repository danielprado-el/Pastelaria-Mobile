import 'dart:convert';

import 'package:flat_list/flat_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pastelaria/autentificador.dart';
import 'package:pastelaria/componentes/card_pastel.dart';
import 'package:pastelaria/estado.dart';

const tamanhoPagina = 4;

class Pasteis extends StatefulWidget {
  const Pasteis({super.key});

  @override
  State<StatefulWidget> createState() => PasteisState();
}

class PasteisState extends State<Pasteis> {
  late dynamic _feedEstatico;
  List<dynamic> _pasteis = [];

  String _filtro = "";
  late TextEditingController _controladorFiltro;

  bool _carregando = false;
  int _proximaPagina = 1;

  @override
  void initState() {
    _lerFeedEstatico();
    _controladorFiltro = TextEditingController();

    _recuperarUsuarioLogado();

    super.initState();
  }

  void _recuperarUsuarioLogado() {
    Autenticador.recuperarUsuario().then((usuario) {
      if (usuario != null) {
        setState(() {
          estadoApp.onLogin(usuario);
        });
      }
    });
  }

  Future<void> _lerFeedEstatico() async {
    final stringJson = await rootBundle.loadString('assets/json/feed.json');
    _feedEstatico = await json.decode(stringJson);

    _carregarPasteis();
  }

  void _carregarPasteis() {
    setState(() {
      _carregando = true;
    });

    var maisPasteis = [];

    if (_filtro.isNotEmpty) {
      List<dynamic> pasteis = _feedEstatico['pasteis'];

      pasteis.where((item) {
        String nomePastel = item['pastel']['nome'];
        return nomePastel.toLowerCase().contains(_filtro.toLowerCase());
      }).forEach((item) {
        maisPasteis.add(item);
      });
    } else {
      maisPasteis = _pasteis;
      final totalDeFeedsParaCarregar = _proximaPagina * tamanhoPagina;
      if (_feedEstatico['pasteis'].length >= totalDeFeedsParaCarregar) {
        maisPasteis =
            _feedEstatico['pasteis'].sublist(0, totalDeFeedsParaCarregar);
      } else {
        maisPasteis = _feedEstatico['pasteis'];
      }
    }

    setState(() {
      _carregando = false;
      _proximaPagina += 1;

      _pasteis = maisPasteis;
    });
  }

  Future<void> _atualizarPasteis() async {
    _pasteis = [];
    _proximaPagina = 1;

    _carregarPasteis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const SizedBox.shrink(),
          actions: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                  controller: _controladorFiltro,
                  onSubmitted: (texto) {
                    _filtro = texto;
                    _atualizarPasteis();
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(color: Colors.orange, Icons.search))),
            )),
            Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: estadoApp.temUsuarioLogado()
                    ? GestureDetector(
                        onTap: () {
                          Autenticador.logout().then((_) {
                            Fluttertoast.showToast(
                                msg: "você não está mais conectado");

                            setState(() {
                              estadoApp.onLogout();
                            });
                          });
                        },
                        child: const Icon(
                            color: Colors.orange, Icons.logout, size: 30))
                    : GestureDetector(
                        onTap: () {
                          Autenticador.login().then((usuario) {
                            Fluttertoast.showToast(
                                msg: "você foi conectado com sucesso");
                            setState(() {
                              estadoApp.onLogin(usuario);
                            });
                          });
                        },
                        child: const Icon(
                            color: Colors.orange, Icons.person, size: 30)))
          ],
        ),
        body: FlatList(
          data: _pasteis,
          loading: _carregando,
          numColumns: 2,
          onRefresh: () {
            _filtro = "";
            _controladorFiltro.clear();
            return _atualizarPasteis();
          },
          onEndReached: () {
            _carregarPasteis();
          },
          onEndReachedDelta: 200,
          buildItem: (item, int index) {
            return CardPastel(item);
          },
          listEmptyWidget: Container(
              alignment: Alignment.center,
              child: const Text("Não existem pasteis para exibir :(")),
        ));
  }
}
