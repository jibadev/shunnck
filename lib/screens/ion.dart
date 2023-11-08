import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ionicons/ionicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shunnck/screens/ki.dart';
import 'package:shunnck/screens/sonoj.dart';
import '../generated/l10n.dart';

class IonScreen extends StatefulWidget {
  final String searchQuery;

  const IonScreen({Key? key, required this.searchQuery}) : super(key: key);

  @override
  _IonScreenState createState() => _IonScreenState();
}

class _IonScreenState extends State<IonScreen> {
  List<Map<String, String>> _searchResults = [];
  final PageController _pageController = PageController(initialPage: 0);
  bool _noResultsFound = false;
  bool _isConnected = true;
  int _selectedIndex = 0;
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.searchQuery.isEmpty) {
      _noResultsFound = true;
    } else {
      // Inicializa el término de búsqueda actual
      _currentSearchQuery = widget.searchQuery;
      _checkInternetConnection();
    }
  }

  Future<void> _checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isConnected = false;
        _noResultsFound = true;
      });
    } else {
      _searchWikipedia(_currentSearchQuery);
    }
  }

  Future<String> _fetchDescription(int pageId) async {
    final descriptionUrl = Uri.parse(
        'https://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts|info&pageids=$pageId&explaintext=true');

    final response = await http.get(descriptionUrl);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final page = body['query']['pages'][pageId.toString()];
      final article = page['extract'] ?? '';
      final lines = article.split('\n');
      final firstThreeLines = lines.take(3).join(' ');
      return firstThreeLines;
    }

    return '';
  }

  void _searchWikipedia(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _noResultsFound = true;
      });
      return;
    }

    final url = Uri.parse(
        'https://en.wikipedia.org/w/api.php?action=query&format=json&list=search&srsearch=$query&utf8=1');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final searchResults = body['query']['search'] as List<dynamic>;
        final List<Map<String, String>> results = [];

        for (final result in searchResults) {
          final pageId = result['pageid'];
          final article = await _fetchDescription(pageId);
          final title = result['title'];
          results.add({
            'title': title,
            'article': article,
            'pageid': pageId.toString()
          });
        }

        setState(() {
          _searchResults = results;
          _noResultsFound = _searchResults.isEmpty;
        });

        if (!_noResultsFound) {}
      } else {
        setState(() {
          _searchResults = [
            {
              'title': 'Error',
              'article': 'Error al realizar la búsqueda en Wikipedia.',
              'pageid': '-1',
            }
          ];
          _noResultsFound = true;
        });
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
    }
  }

  void _reloadSearch() {
    _searchWikipedia(_currentSearchQuery);
    _pageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Ionicons.chevron_back_outline,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onBackground,
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KiView(searchQuery: widget.searchQuery),
                ),
              );
            },
            icon: Icon(
              Ionicons.images,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ],
        title: Align(
          alignment: Alignment.center,
          child: Text(
            S.current.holowide,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.onBackground
                  : Theme.of(context).primaryColor,
              fontSize: 24,
              fontFamily: "LexendExa",
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          CustomAnimatedGradient(), // Usa el widget de AnimatedGradient personalizado aquí
          _isConnected ? _buildPageContent() : _buildNoInternetScreen(),
        ],
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
                      Ionicons.reader,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onBackground
                          : Theme.of(context).primaryColor,
                    )
                  : Icon(
                      Ionicons.reader_outline,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              onPressed: () {},
            ),
            IconButton(
              icon: _selectedIndex == 1
                  ? Icon(
                      Ionicons.reload,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onBackground
                          : Theme.of(context).primaryColor,
                    )
                  : Icon(
                      Ionicons.reload_outline,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              onPressed: _reloadSearch, // Asigna la función de recarga al botón
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoInternetScreen() {
    return Padding(
      padding: const EdgeInsets.only(left: 19.0, right: 19.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Ionicons.train,
              size: 45,
            ),
            const SizedBox(height: 10),
            const Text(
              'No hay conexión a Internet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ButtonStyle(
                elevation: MaterialStateProperty.all<double>(0),
                backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).colorScheme.tertiary,
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              onPressed: () {
                _checkInternetConnection();
              },
              child: Text(
                "Vamos al Tren Urbano",
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    return _noResultsFound
        ? Padding(
            padding: const EdgeInsets.only(left: 19.0, right: 19.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Ionicons.alert_circle,
                    size: 45,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No encontramos nada para mostrarte en la web.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all<double>(0),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.tertiary,
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Hacer otra búsqueda",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : _searchResults.isEmpty
            ? Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onBackground
                      : Theme.of(context).primaryColor,
                  size: 57,
                ),
              )
            : PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final title =
                      _searchResults[index]['title'] ?? 'Título no disponible';
                  final article = _searchResults[index]['article'] ??
                      'Artículo no disponible';

                  return GestureDetector(
                    onTap: () {
                      final pageId =
                          int.parse(_searchResults[index]['pageid'] ?? '-1');
                      if (pageId != -1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SonojView(pageId: pageId),
                          ),
                        );
                      }
                    },
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 50,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              article,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class CustomAnimatedGradient extends StatefulWidget {
  @override
  _CustomAnimatedGradientState createState() => _CustomAnimatedGradientState();
}

class _CustomAnimatedGradientState extends State<CustomAnimatedGradient>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    _colorAnimation = ColorTween(
      begin: isDarkMode ? const Color(0xFF282828) : const Color(0xFFFFFFFF),
      end: isDarkMode ? const Color(0xFF777777) : const Color(0xFFFF7791),
    ).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final color = _colorAnimation.value;

        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.5,
              colors: [
                color!,
                Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF282828)
                    : const Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: child,
        );
      },
      child: SizedBox.expand(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
