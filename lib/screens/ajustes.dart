// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({Key? key}) : super(key: key);

  @override
  _AjustesScreenState createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  List<String> _savedUrls = [];

  @override
  void initState() {
    super.initState();
    _loadSavedUrls();
  }

  Future<void> _loadSavedUrls() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrls = prefs.getStringList('savedUrls') ?? [];
    setState(() {
      _savedUrls = savedUrls;
    });
  }

  Future<void> _deleteUrl(int index) async {
    setState(() {
      _savedUrls.removeAt(index);
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('savedUrls', _savedUrls);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ));
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              },
              child: Image.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? "assets/images/shunnck-logo.png"
                    : "assets/images/shunnck-logo-blanco.png",
                height: 26,
              ),
            ),
          ),
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              margin: const EdgeInsets.only(top: 30),
              child: Text(
                "Mi cajón",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 60,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_savedUrls.isEmpty)
              Text(
                'Mantén el botón de compartir y podrás guardar un sitio web en tu cajón.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 22,
                    height: 1.1),
              )
            else
              ..._savedUrls.asMap().entries.map(
                    (entry) => Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        color: Theme.of(context).colorScheme.background,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("data"),
                          ListTile(
                            title: Text(
                              entry.value,
                              maxLines: 1,
                            ),
                            onLongPress: () => _deleteUrl(entry.key),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
