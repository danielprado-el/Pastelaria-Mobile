import 'package:flutter/material.dart';
import 'package:pastelaria/autentificador.dart';

enum Situacao { mostrandoPasteis, mostrandoDetalhes }

class EstadoApp extends ChangeNotifier {
  Situacao _situacao = Situacao.mostrandoPasteis;
  Situacao get situacao => _situacao;
  set situacao(Situacao situacao) {
    _situacao = situacao;
  }

  int _idPastel = 0;
  int get idPastel => _idPastel;
  set idPastel(int idPastel) {
    _idPastel = idPastel;
  }

  Usuario? _usuario;
  Usuario? get usuario => _usuario;
  set usuario(Usuario? usuario) {
    _usuario = usuario;
  }

  void mostrarPasteis() {
    situacao = Situacao.mostrandoPasteis;

    notifyListeners();
  }

  void mostrarDetalhes(int idPastel) {
    situacao = Situacao.mostrandoDetalhes;
    this.idPastel = idPastel;

    notifyListeners();
  }

  void onLogin(Usuario usuario) {
    _usuario = usuario;

    notifyListeners();
  }

  void onLogout() {
    _usuario = null;

    notifyListeners();
  }

  bool temUsuarioLogado() {
    return _usuario != null;
  }
}

late EstadoApp estadoApp;
