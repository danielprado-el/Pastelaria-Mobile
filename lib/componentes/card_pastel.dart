import 'package:flutter/material.dart';
import 'package:pastelaria/estado.dart';

class CardPastel extends StatefulWidget {
  final dynamic pastel;

  const CardPastel(this.pastel, {super.key});

  @override
  State<StatefulWidget> createState() {
    return CardPastelState();
  }
}

class CardPastelState extends State<CardPastel> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 350,
        child: GestureDetector(
            onTap: () {
              estadoApp.mostrarDetalhes(widget.pastel["_id"]);
            },
            child: Card(
              surfaceTintColor: Colors.orange,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0)),
                      child: Image.asset('assets/imgs/pastel.jpg')),
                  Row(children: [
                    Image.asset('assets/imgs/pastelLogo.png', width: 38),
                    Padding(
                        padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
                        child: Text(
                          widget.pastel["pastelaria"]["nome"],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ))
                  ]),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      widget.pastel["pastel"]["nome"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0, top: 5, bottom: 10),
                    child: Text(
                      widget.pastel["pastel"]["descricao"],
                    ),
                  ),
                  Row(children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "R\$ ${widget.pastel["pastel"]["preco"].toString()}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 90.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.thumb_up_alt_outlined,
                            color: Colors.red,
                            size: 18,
                          ),
                          Text(
                            widget.pastel["likes"].toString(),
                          ),
                        ],
                      ),
                    )
                  ])
                ],
              ),
            )));
  }
}
