import 'dart:convert';

import 'package:flat_list/flat_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_visibility_pro/keyboard_visibility_pro.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:pastelaria/estado.dart';

const tamanhoPagina = 4;

class Detalhes extends StatefulWidget {
  const Detalhes({super.key});

  @override
  State<StatefulWidget> createState() => DetalhesState();
}

class DetalhesState extends State<Detalhes> {
  late dynamic _feedEstatico;
  late dynamic _comentariosEstaticos;

  late PageController _controladorSlides;
  late int _slideSelecionado;

  bool _temPastel = false;
  dynamic _pastel;

  bool _temComentarios = false;
  List<dynamic> _comentarios = [];
  late TextEditingController _controladorNovoComentario;
  bool _carregandoComentarios = false;

  int _proximaPagina = 1;

  bool _curtiu = false;
  bool _tecladoVisivel = false;

  @override
  void initState() {
    _lerBancoEstatico();
    _iniciarSlides();

    _controladorNovoComentario = TextEditingController();

    super.initState();
  }

  void _iniciarSlides() {
    _slideSelecionado = 0;
    _controladorSlides = PageController(initialPage: _slideSelecionado);
  }

  Future<void> _lerBancoEstatico() async {
    String stringJson = await rootBundle.loadString('assets/json/feed.json');
    _feedEstatico = await json.decode(stringJson);

    stringJson = await rootBundle.loadString('assets/json/comentarios.json');
    _comentariosEstaticos = await json.decode(stringJson);

    _carregarPastel();
    _carregarComentarios();
  }

  void _carregarPastel() {
    _pastel = _feedEstatico['pasteis']
        .firstWhere((pastel) => pastel['_id'] == estadoApp.idPastel);

    setState(() {
      _temPastel = _pastel != null;

      _carregandoComentarios = false;
    });
  }

  void _carregarComentarios() {
    setState(() {
      _carregandoComentarios = true;
    });

    var maisComentarios = [];
    _comentariosEstaticos['comentarios'].where((item) {
      return item['feed'] == estadoApp.idPastel;
    }).forEach((item) {
      maisComentarios.add(item);
    });

    final totalDeComentariosParaCarregar = _proximaPagina * tamanhoPagina;
    if (maisComentarios.length >= totalDeComentariosParaCarregar) {
      maisComentarios =
          maisComentarios.sublist(0, totalDeComentariosParaCarregar);
    }

    setState(() {
      _temComentarios = maisComentarios.isNotEmpty;
      _comentarios = maisComentarios;

      _proximaPagina += 1;

      _carregandoComentarios = false;
    });
  }

  Future<void> _atualizarComentarios() async {
    _comentarios = [];
    _proximaPagina = 1;

    _carregarComentarios();
  }

  void _adicionarComentario() {
    if (estadoApp.usuario != null) {
      final comentario = {
        "content": _controladorNovoComentario.text,
        "user": {
          "name": estadoApp.usuario!.nome,
          "email": estadoApp.usuario!.email,
        },
        "datetime": DateTime.now().toString(),
        "feed": estadoApp.idPastel
      };

      setState(() {
        _comentarios.insert(0, comentario);
      });
    }
  }

  String _formatarData(String dataHora) {
    DateTime dateTime = DateTime.parse(dataHora);
    DateFormat formatador = DateFormat("dd/MM/yyyy HH:mm");

    return formatador.format(dateTime);
  }

  Widget _exibirMensagemComentariosInexistentes() {
    return const Center(
        child: Padding(
            padding: EdgeInsets.all(14.0),
            child: Text('Não existem comentários',
                style: TextStyle(color: Colors.black, fontSize: 14))));
  }

  List<Widget> _exibirComentarios() {
    return [
      const Center(
          child: Text(
        "Comentários",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      )),
      estadoApp.temUsuarioLogado()
          ? Padding(
              padding: const EdgeInsets.all(6.0),
              child: TextField(
                  controller: _controladorNovoComentario,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintStyle: const TextStyle(fontSize: 14),
                      hintText: 'Digite aqui seu comentário...',
                      suffixIcon: GestureDetector(
                          onTap: () {
                            _adicionarComentario();
                          },
                          child:
                              const Icon(color: Colors.orange, Icons.send)))))
          : const SizedBox.shrink(),
      _temComentarios
          ? Expanded(
              child: FlatList(
              data: _comentarios,
              loading: _carregandoComentarios,
              numColumns: 1,
              onRefresh: () {
                _controladorNovoComentario.clear();

                return _atualizarComentarios();
              },
              onEndReached: () {
                _carregarComentarios();
              },
              onEndReachedDelta: 200,
              buildItem: (item, int index) {
                return Dismissible(
                    key: Key(_comentarios[index]['_id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                        color: Colors.red,
                        child: const Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                                padding: EdgeInsets.only(right: 15.0),
                                child: Icon(Icons.delete)))),
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        final comentario = _comentarios[index];
                        setState(() {
                          _comentarios.removeAt(index);
                        });

                        showDialog(
                            context: context,
                            builder: (BuildContext contexto) {
                              return AlertDialog(
                                title:
                                    const Text("deseja apagar o comentário?"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _comentarios.insert(
                                              index, comentario);
                                        });

                                        Navigator.of(contexto).pop();
                                      },
                                      child: const Text("não")),
                                  TextButton(
                                      onPressed: () {
                                        setState(() {});

                                        Navigator.of(contexto).pop();
                                      },
                                      child: const Text("sim"))
                                ],
                              );
                            });
                      }
                    },
                    child: Card(
                        surfaceTintColor: Colors.orange,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  _comentarios[index]["content"],
                                  style: const TextStyle(fontSize: 12),
                                )),
                            Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Row(
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            right: 10.0, left: 6.0),
                                        child: Text(
                                          _comentarios[index]["user"]["name"],
                                          style: const TextStyle(fontSize: 12),
                                        )),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: Text(
                                          _formatarData(
                                              _comentarios[index]["datetime"]),
                                          style: const TextStyle(fontSize: 12),
                                        )),
                                  ],
                                )),
                          ],
                        )));
              },
              listEmptyWidget: Container(
                  alignment: Alignment.center,
                  child: const Text("Não existem pasteis para exibir")),
            ))
          : _exibirMensagemComentariosInexistentes()
    ];
  }

  Widget _exibirPastel() {
    List<Widget> widgets = [];

    if (!_tecladoVisivel) {
      widgets.addAll([
        SizedBox(
          height: 230,
          child: Stack(children: [
            PageView.builder(
              itemCount: 2,
              controller: _controladorSlides,
              onPageChanged: (slide) {
                setState(() {
                  _slideSelecionado = slide;
                });
              },
              itemBuilder: (context, pagePosition) {
                List<String> imagens = [
                  'assets/imgs/pastel.jpg',
                  'assets/imgs/pastel2.jpg'
                ];

                return Image.asset(imagens[pagePosition], fit: BoxFit.cover);
              },
            ),
            Align(
                alignment: Alignment.topRight,
                child: Column(children: [
                  estadoApp.temUsuarioLogado()
                      ? IconButton(
                          onPressed: () {
                            if (_curtiu) {
                              setState(() {
                                _pastel['likes'] = _pastel['likes'] - 1;

                                _curtiu = false;
                              });
                            } else {
                              setState(() {
                                _pastel['likes'] = _pastel['likes'] + 1;

                                _curtiu = true;
                              });
                            }
                          },
                          icon: Icon(_curtiu
                              ? Icons.thumb_up_alt
                              : Icons.thumb_up_alt_outlined),
                          color: Colors.red,
                          iconSize: 32)
                      : const SizedBox.shrink(),
                ]))
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: PageViewDotIndicator(
            currentItem: _slideSelecionado,
            count: 2,
            unselectedColor: Colors.black26,
            selectedColor: Colors.orange,
            duration: const Duration(milliseconds: 200),
            boxShape: BoxShape.circle,
          ),
        ),
        Card(
          surfaceTintColor: Colors.orange,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _temPastel
                  ? Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        _pastel["pastel"]["nome"],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ))
                  : const SizedBox.shrink(),
              _temPastel
                  ? Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(_pastel["pastel"]["descricao"],
                          style: const TextStyle(fontSize: 12)))
                  : const SizedBox.shrink(),
              _temPastel
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                      child: Row(children: [
                        Text(
                          "R\$ ${_pastel["pastel"]["preco"].toString()}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.thumb_up_alt_outlined,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  Text(
                                    _pastel["likes"].toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ]))
                      ]))
                  : const SizedBox.shrink(),
            ],
          ),
        )
      ]);
    }
    widgets.addAll(_exibirComentarios());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(children: [
          Row(children: [
            Image.asset('assets/imgs/pastelLogo.png', width: 38),
            Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
                child: Text(
                  _pastel["pastelaria"]["nome"],
                  style: const TextStyle(fontSize: 15),
                ))
          ]),
          const Spacer(),
          GestureDetector(
            onTap: () {
              estadoApp.mostrarPasteis();
            },
            child: const Icon(color: Colors.orange, Icons.arrow_back, size: 30),
          )
        ]),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  Widget _exibirMensagemPastelInexistente() {
    return Scaffold(
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: FloatingActionButton(
              onPressed: () {
                estadoApp.mostrarPasteis();
              },
              child: const Icon(Icons.arrow_back))),
      const Material(
          color: Colors.transparent,
          child: Text('Pastel não existe ou foi esgotado!!',
              style: TextStyle(color: Colors.black, fontSize: 14))),
    ])));
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibility(
        onChanged: (bool visivel) {
          setState(() {
            _tecladoVisivel = visivel;
          });
        },
        child:
            _temPastel ? _exibirPastel() : _exibirMensagemPastelInexistente());
  }
}
