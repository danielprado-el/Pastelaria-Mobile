import 'package:flat_list/flat_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_visibility_pro/keyboard_visibility_pro.dart';
import 'package:pastelaria/apis/servicos.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../estado.dart';

const TAMANHO_DA_PAGINA = 4;

class Detalhes extends StatefulWidget {
  const Detalhes({super.key});

  @override
  State<StatefulWidget> createState() => DetalhesState();
}

class DetalhesState extends State<Detalhes> {
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

  late ServicoPasteis _servicoPasteis;
  late ServicoCurtidas _servicoCurtidas;
  late ServicoComentarios _servicoComentarios;

  @override
  void initState() {
    _iniciarSlides();

    _controladorNovoComentario = TextEditingController();

    _servicoPasteis = ServicoPasteis();
    _servicoCurtidas = ServicoCurtidas();
    _servicoComentarios = ServicoComentarios();

    _carregarPastel();
    _carregarComentarios();

    super.initState();
  }

  void _iniciarSlides() {
    _slideSelecionado = 0;
    _controladorSlides = PageController(initialPage: _slideSelecionado);
  }

  void _carregarPastel() {
    _servicoPasteis.findPastel(estadoApp.idPastel).then((pastel) {
      _pastel = pastel;

      if (estadoApp.usuario != null) {
        _servicoCurtidas
            .curtiu(estadoApp.usuario!, estadoApp.idPastel)
            .then((curtiu) {
          setState(() {
            _temPastel = _pastel != null;
            _curtiu = curtiu;

            _carregandoComentarios = false;
          });
        });
      } else {
        setState(() {
          _temPastel = _pastel != null;

          _carregandoComentarios = false;
        });
      }
    });
  }

  void _carregarComentarios() {
    setState(() {
      _carregandoComentarios = true;
    });

    _servicoComentarios
        .getComentarios(estadoApp.idPastel, _proximaPagina, TAMANHO_DA_PAGINA)
        .then((comentarios) {
      setState(() {
        _comentarios.addAll(comentarios);
        _temComentarios = _comentarios.isNotEmpty;
        _proximaPagina += 1;

        _carregandoComentarios = false;
      });
    });
  }

  Future<void> _atualizarComentarios() async {
    _comentarios = [];
    _proximaPagina = 1;

    _carregarComentarios();
  }

  void _adicionarComentario() {
    _servicoComentarios
        .adicionar(estadoApp.idPastel, estadoApp.usuario!,
            _controladorNovoComentario.text)
        .then((resultado) {
      if (resultado["situacao"] == "ok") {
        Fluttertoast.showToast(msg: "comentário adicionado");

        _atualizarComentarios();
      }
    });
  }

  void _removerComentario(int idComentario) {
    _servicoComentarios.remover(idComentario).then((resultado) {
      if (resultado["situacao"] == "ok") {
        Fluttertoast.showToast(msg: "comentário removido com sucesso");

        _atualizarComentarios();
      }
    });
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
                bool usuarioLogadoComentou = estadoApp.temUsuarioLogado() &&
                    item["conta"] == estadoApp.usuario!.email;

                return Dismissible(
                    key: UniqueKey(),
                    direction: usuarioLogadoComentou
                        ? DismissDirection.endToStart
                        : DismissDirection.none,
                    background: Container(
                        color: Colors.red,
                        child: const Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                                padding: EdgeInsets.only(right: 15.0),
                                child: Icon(Icons.delete)))),
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
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
                                          _carregarComentarios();
                                        });

                                        Navigator.of(contexto).pop();
                                      },
                                      child: const Text("não")),
                                  TextButton(
                                      onPressed: () {
                                        _removerComentario(
                                            item["comentario_id"]);

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
                                  item["comentario"],
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
                                          item["nome"],
                                          style: const TextStyle(fontSize: 12),
                                        )),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: Text(
                                          _formatarData(item["data"]),
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

  List<String> _imagensDoSlide() {
    List<String> imagens = [];

    imagens.add(_pastel["imagem1"]);
    if ((_pastel["imagem2"] as String).isNotEmpty) {
      imagens.add(_pastel["imagem2"]);
    }

    return imagens;
  }

  Widget _exibirPastel() {
    List<Widget> widgets = [];
    final slides = _imagensDoSlide();

    if (!_tecladoVisivel) {
      widgets.addAll([
        SizedBox(
          height: 230,
          child: Stack(children: [
            PageView.builder(
              itemCount: slides.length,
              controller: _controladorSlides,
              onPageChanged: (slide) {
                setState(() {
                  _slideSelecionado = slide;
                });
              },
              itemBuilder: (context, pagePosition) {
                return Image.network(
                  caminhoArquivo(slides[pagePosition]),
                  fit: BoxFit.cover,
                );
              },
            ),
            Align(
                alignment: Alignment.topRight,
                child: Column(children: [
                  estadoApp.temUsuarioLogado()
                      ? IconButton(
                          onPressed: () {
                            if (_curtiu) {
                              _servicoCurtidas
                                  .descurtir(
                                      estadoApp.usuario!, estadoApp.idPastel)
                                  .then((resultado) {
                                if (resultado["situacao"] == "ok") {
                                  Fluttertoast.showToast(
                                      msg: "avaliação removida");

                                  setState(() {
                                    _carregarPastel();
                                  });
                                }
                              });
                            } else {
                              _servicoCurtidas
                                  .curtir(
                                      estadoApp.usuario!, estadoApp.idPastel)
                                  .then((resultado) {
                                if (resultado["situacao"] == "ok") {
                                  Fluttertoast.showToast(
                                      msg: "obrigado pela sua avaliação");

                                  setState(() {
                                    _carregarPastel();
                                  });
                                }
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
            count: slides.length,
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
                        _pastel["nome_pastel"],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ))
                  : const SizedBox.shrink(),
              _temPastel
                  ? Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(_pastel["descricao"],
                          style: const TextStyle(fontSize: 12)))
                  : const SizedBox.shrink(),
              _temPastel
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                      child: Row(children: [
                        Text(
                          "R\$ ${_pastel["preco"].toString()}",
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
                                    _pastel["curtidas"].toString(),
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
            Image.network(caminhoArquivo(_pastel["avatar"]), width: 38),
            Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
                child: Text(
                  _pastel["nome_pastel"],
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
