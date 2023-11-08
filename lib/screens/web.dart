import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../generated/l10n.dart';

class WebView extends StatefulWidget {
  const WebView({Key? key}) : super(key: key);

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  List<String> guardas = [];

  Future<void> loadGuardas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      guardas = prefs.getStringList('guardas') ?? [];
    });
  }

  Future<void> removeGuarda(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      guardas.removeAt(index);
      prefs.setStringList('guardas', guardas);
    });
  }

  @override
  void initState() {
    super.initState();
    loadGuardas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      resizeToAvoidBottomInset: false,
      body: KeyboardVisibilityBuilder(
        builder: (BuildContext context, bool isKeyboardVisible) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 14, right: 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Mis wats",
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: 4, left: 14, right: 14, top: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Aquí encontrarás los wats que hacen parte de tu experiencia.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: guardas.isEmpty
                    ? Container(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        margin: const EdgeInsets.only(bottom: 80),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 25),
                              child: SizedBox(
                                width: 290,
                                child: Image.asset(
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? "assets/images/mural_blanco.png"
                                      : "assets/images/mural_rosa.png",
                                ),
                              ),
                            ),
                            Text(
                              S.current.nohaypestanas,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: guardas.length,
                        itemBuilder: (context, index) {
                          final guardaInfo = guardas[index];

                          return GestureDetector(
                            onLongPress: () {
                              showEditDialog(context, index);
                            },
                            child: Dismissible(
                              key: Key(guardaInfo),
                              onDismissed: (_) => removeGuarda(index),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Theme.of(context).primaryColor,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: Icon(
                                  Ionicons.trash_bin_outline,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                              ),
                              child: ListTile(
                                title: Text(
                                  guardaInfo,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    height: 1.2,
                                    fontSize: 26,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> showEditDialog(BuildContext context, int index) async {
    String newName = guardas[index];

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar nombre de enlace'),
          content: TextField(
            controller: TextEditingController(text: newName),
            onChanged: (value) {
              newName = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () {
                setState(() {
                  guardas[index] = newName;
                  saveGuardas();
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> saveGuardas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('guardas', guardas);
  }
}
