import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pastelaria/estado.dart';
import 'package:pastelaria/telas/detalhes.dart';
import 'package:pastelaria/telas/pasteis.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const Pastelaria());
}

class Pastelaria extends StatelessWidget {
  const Pastelaria({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => EstadoApp(),
        child: MaterialApp(
          title: 'Pastelaria',
          theme: ThemeData(
            colorScheme: const ColorScheme.light(),
            useMaterial3: true,
          ),
          home: const TelaPrincipal(),
        ));
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  void _exibirComoRetrato() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    _exibirComoRetrato();

    estadoApp = context.watch<EstadoApp>();
    Widget tela = const SizedBox.shrink();
    if (estadoApp.situacao == Situacao.mostrandoPasteis) {
      tela = const Pasteis();
    } else if (estadoApp.situacao == Situacao.mostrandoDetalhes) {
      tela = const Detalhes();
    }

    return tela;
  }
}
