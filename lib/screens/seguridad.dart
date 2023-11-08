import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class SeguridadView extends StatefulWidget {
  const SeguridadView({super.key});

  @override
  State<SeguridadView> createState() => _SeguridadViewState();
}

class _SeguridadViewState extends State<SeguridadView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: GestureDetector(
          child: Icon(
            Ionicons.chevron_back_outline,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 30, bottom: 30),
            child: Center(
              child: Icon(
                Ionicons.shield_checkmark,
                color: Theme.of(context).colorScheme.onBackground,
                size: 60,
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: const Text(
                '¡Estás seguro!',
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 25),
              child: Text(
                'duckduckgo.com',
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.all(11),
            padding: const EdgeInsets.all(15),
            child: Text(
              "Este sitio web está conectado al Dakspace que es contruido por nuestra comunidad, por lo que este está verificado y cumple con las políticas requeridas del Tratado Digital de Manatí.",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 24,
                  height: 1.2),
            ),
          )
        ],
      ),
    );
  }
}
