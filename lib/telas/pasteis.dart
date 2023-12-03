import 'package:flat_list/flat_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pastelaria/apis/servicos.dart';
import 'package:pastelaria/autentificador.dart';
import 'package:pastelaria/componentes/card_pastel.dart';
import 'package:pastelaria/estado.dart';

const TAMANHO_DA_PAGINA = 4;

class Pasteis extends StatefulWidget {
  const Pasteis({super.key});

  @override
  State<StatefulWidget> createState() => PasteisState();
}

class PasteisState extends State<Pasteis> {
  List<dynamic> _pasteis = [];

  String _filtro = "";
  late TextEditingController _controladorFiltro;

  bool _carregando = false;
  int _proximaPagina = 1;

  late ServicoPasteis _servicoPasteis;

  @override
  void initState() {
    _controladorFiltro = TextEditingController();
    _recuperarUsuarioLogado();

    _servicoPasteis = ServicoPasteis();
    _carregarPasteis();

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

  void _carregarPasteis() {
    setState(() {
      _carregando = true;
    });

    if (_filtro.isNotEmpty) {
      _servicoPasteis
          .findPasteis(_proximaPagina, TAMANHO_DA_PAGINA, _filtro)
          .then((pasteis) {
        setState(() {
          _carregando = false;
          _proximaPagina += 1;

          _pasteis.addAll(pasteis);
        });
      });
    } else {
      _servicoPasteis
          .getPasteis(_proximaPagina, TAMANHO_DA_PAGINA)
          .then((pasteis) {
        setState(() {
          _carregando = false;
          _proximaPagina += 1;

          _pasteis.addAll(pasteis);
        });
      });
    }
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
