import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shunnck/data/chi.dart';
import 'package:shunnck/screens/lernas.dart';
import 'package:shunnck/screens/nfc.dart';
import 'package:shunnck/screens/web.dart';
import 'package:shunnck/views/imagen.dart';
import '../generated/l10n.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  List<Widget> vistas = [];
  int _selectedIndex = 0;
  double _opacityLevel = 1.0;
  late Timer _opacityTimer;

  @override
  void initState() {
    super.initState();
    _startOpacityTimer();
    vistas = [LernasView(), const WebView()];
  }

  void _startOpacityTimer() {
    _opacityTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      setState(() {
        _opacityLevel = _opacityLevel == 1 ? 0.6 : 1;
      });
    });
  }

  Future<List<String>> _getGuardasList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final guardas = prefs.getStringList('guardas') ?? [];
    return guardas;
  }

  IconData _getGuardaIcon(String addedCodes) {
    final int parsedIdentifier = int.tryParse(addedCodes) ?? -1;
    return chi.contains(parsedIdentifier)
        ? Ionicons.prism_outline
        : Ionicons.medical_outline;
  }

  void _ajustes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<String>>(
          future: _getGuardasList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final guardasList = snapshot.data!;
              return Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 1,
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 30,
                          left: 15,
                          right: 15,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            Ionicons.medical,
                            color: Theme.of(context).colorScheme.onBackground,
                            size: 40,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 15,
                          top: 15,
                          bottom: 10,
                          right: 15,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            S.current.todosguardas,
                            style: TextStyle(
                              fontSize: 25,
                              height: 1.2,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                        ),
                      ),
                      for (int index = 0; index < guardasList.length; index++)
                        Dismissible(
                          key: Key(guardasList[index]),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Theme.of(context).primaryColor,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Icon(
                              Ionicons.trash_bin_outline,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          onDismissed: (direction) {
                            _eliminarGuarda(index);
                          },
                          child: ListTile(
                            leading: Icon(
                              _getGuardaIcon(guardasList[index]),
                              size: 28,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            title: Text(
                              guardasList[index],
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontSize: 22,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                      ListTile(
                        leading: Icon(
                          Ionicons.add_circle_outline,
                          color: Theme.of(context).colorScheme.onBackground,
                          size: 28,
                        ),
                        title: Text(
                          S.current.agregarguarda,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const NFCView()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Text(S.current.nohaydatos);
            }
          },
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _eliminarGuarda(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final guardas = prefs.getStringList('guardas') ?? [];

    if (index >= 0 && index < guardas.length) {
      guardas.removeAt(index);
      await prefs.setStringList('guardas', guardas);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _opacityTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        elevation: 0,
        title: GestureDetector(
          onLongPress: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ImagenScreen()),
            );
          },
          onTap: () {
            _ajustes(context);
          },
          child: Align(
            alignment: Alignment.center,
            child: Text(
              S.current.url,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onBackground
                    : Theme.of(context).primaryColor,
                fontSize: 24,
                fontFamily: "PON",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: vistas,
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Theme.of(context).colorScheme.tertiary,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: _selectedIndex == 0
                  ? Icon(
                      Ionicons.planet,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onBackground
                          : Theme.of(context).primaryColor,
                    )
                  : Icon(
                      Ionicons.planet_outline,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              onPressed: () {
                _onItemTapped(0);
              },
            ),
            IconButton(
              icon: _selectedIndex == 1
                  ? Icon(
                      Ionicons.medical,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onBackground
                          : Theme.of(context).primaryColor,
                    )
                  : Icon(
                      Ionicons.medical_outline,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              onPressed: () {
                _onItemTapped(1);
              },
            ),
          ],
        ),
      ),
    );
  }
}
