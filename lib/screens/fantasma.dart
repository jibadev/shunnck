// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ionicons/ionicons.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shunnck/screens/inicio.dart';
import 'package:shunnck/screens/nybox.dart';
import '../generated/l10n.dart';
import 'package:http/http.dart' as http;

class FantasmaScreen extends StatefulWidget {
  const FantasmaScreen({Key? key, this.url}) : super(key: key);

  final String? url;

  @override
  _FantasmaScreenState createState() => _FantasmaScreenState();
}

class _FantasmaScreenState extends State<FantasmaScreen>
    with AfterLayoutMixin<FantasmaScreen> {
  late FocusNode _searchFieldFocus;
  late InAppWebViewController _webViewController;
  late String _currentUrl = "https://intsplay.com/shunnck/";
  bool _isLoading = false;
  late TextEditingController _searchController;
  String? scannedUrl;
  bool _isDesktopMode = false;
  List<String> _webLinks = [];
  bool _isSecure = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.url);
    if (widget.url != null) {
      _currentUrl = widget.url!;
    }
    _loadWebLinks();
    _searchFieldFocus = FocusNode();
  }

  Future<void> _checkIfSecure(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      setState(() {
        _isSecure = response.statusCode < 400;
      });
    } catch (e) {
      setState(() {
        _isSecure = false;
      });
    }
  }

  Future<void> _loadWebLinks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _webLinks = prefs.getStringList('web_links') ?? [];
    });
  }

  void _openSearchBar() {
    _searchFieldFocus.requestFocus(); // Enfoca el TextField

    Future.delayed(const Duration(milliseconds: 50), () {
      _searchController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _searchController.text.length,
      );
    });
  }

  Future<void> _saveWebLinks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('web_links', _webLinks);
  }

  void _selectAllText() {
    Future.delayed(Duration.zero, () {
      _searchController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _searchController.text.length,
      );
    });
  }

  void _addWebLink(String link) {
    if (!_webLinks.contains(link)) {
      setState(() {
        _webLinks.add(link);
        _saveWebLinks();
      });
    }
  }

  void _goBack() {
    _webViewController.goBack();
  }

  void _goForward() {
    _webViewController.goForward();
  }

  void _refresh() {
    _webViewController.reload();
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(
                    _isSecure ? Ionicons.shield_checkmark : Ionicons.warning,
                    color: _isSecure
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).primaryColor,
                    size: 25,
                  ),
                  title: Text(
                    _isSecure ? S.current.estasseguro : S.current.noestasseguro,
                    style: TextStyle(
                        color: _isSecure
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).primaryColor,
                        fontSize: 22),
                  ),
                  onTap: () {
                    _goBack();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Ionicons.laptop_outline,
                    color: _isDesktopMode
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.onBackground,
                    size: 25,
                  ),
                  title: Text(
                    S.current.modoescritorio,
                    style: TextStyle(
                      color: _isDesktopMode
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.onBackground,
                      fontSize: 22,
                      fontWeight:
                          _isDesktopMode ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _isDesktopMode = !_isDesktopMode;
                    });
                    _webViewController.setOptions(
                      options: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          preferredContentMode: _isDesktopMode
                              ? UserPreferredContentMode.DESKTOP
                              : UserPreferredContentMode.MOBILE,
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Ionicons.arrow_back_outline,
                    color: Theme.of(context).colorScheme.onBackground,
                    size: 25,
                  ),
                  title: Text(
                    S.current.atras,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 22),
                  ),
                  onTap: () {
                    _goBack();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Ionicons.arrow_forward_outline,
                    color: Theme.of(context).colorScheme.onBackground,
                    size: 25,
                  ),
                  title: Text(
                    S.current.siguientepagina,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 22),
                  ),
                  onTap: () {
                    _goForward();
                    Navigator.pop(
                        context); // Cierra el BottomSheet después de la acción
                  },
                ),
                ListTile(
                  leading: Icon(
                    Ionicons.reload_outline,
                    color: Theme.of(context).colorScheme.onBackground,
                    size: 25,
                  ),
                  title: Text(
                    S.current.recargar,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 22),
                  ),
                  onTap: () {
                    _refresh();
                    Navigator.pop(
                        context); // Cierra el BottomSheet después de la acción
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeWebLink(String link) {
    setState(() {
      _webLinks.remove(link);
      _saveWebLinks();
    });
  }

  void _openNyboxView(BuildContext context) async {
    final userInput = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const NyboxView()),
    );

    if (userInput != null) {
      handleSubmitted(userInput);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadUrl(String url) async {
    await _webViewController.loadUrl(
        urlRequest: URLRequest(url: Uri.parse(url)));
  }

  void handleSubmitted(String userInput) {
    final uri = Uri.tryParse(userInput);
    if (uri != null && uri.scheme.isNotEmpty) {
      loadUrl(userInput);
    } else {
      final searchQuery = Uri.encodeComponent(userInput);
      loadUrl('https://duckduckgo.com/?q=$searchQuery');
    }
    _searchController.clear();
  }

  Future<bool> onWillPop() async {
    if (await _webViewController.canGoBack()) {
      _webViewController.goBack();
      return false;
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const InicioScreen(),
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (scannedUrl != null) {
      loadUrl(scannedUrl!);
      scannedUrl = null;
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const InicioScreen(),
                ),
              );
            },
            child: Icon(
              Ionicons.chevron_back_outline,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          title: Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            margin: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: GestureDetector(
              child: TextField(
                onTap: () {
                  _selectAllText(); // Selecciona automáticamente todo el texto
                },
                controller: TextEditingController(text: _currentUrl),
                focusNode: _searchFieldFocus,
                onChanged: (newUrl) {
                  _currentUrl = newUrl;
                },
                onSubmitted: handleSubmitted,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 21,
                ),
                decoration: InputDecoration(
                  hintText: S.current.url,
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 18,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onBackground,
          ),
          actions: [
            IconButton(
              icon: Icon(
                _webLinks.contains(_currentUrl)
                    ? Ionicons.bookmark
                    : Ionicons.bookmark_outline,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              onPressed: () {
                _addWebLink(_currentUrl);
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: Uri.parse(_currentUrl)),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  preferredContentMode: UserPreferredContentMode.MOBILE,
                  javaScriptEnabled: true,
                  cacheEnabled: false,
                  clearCache: true,
                ),
              ),
              onWebViewCreated: (controller) async {
                _webViewController = controller;
                _webViewController.addJavaScriptHandler(
                  handlerName: 'alert',
                  callback: (args) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Alerta'),
                        content: Text(args[0]),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(S.current.lotengo),
                          ),
                        ],
                      ),
                    );
                  },
                );
                final String? link =
                    ModalRoute.of(context)?.settings.arguments as String?;
                if (link != null) {
                  loadUrl(link);
                }
                final options = await _webViewController.getOptions();
                if (options != null) {
                  setState(() {
                    _isDesktopMode =
                        options.crossPlatform.preferredContentMode ==
                            UserPreferredContentMode.DESKTOP;
                  });
                }
                _refresh();
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _isLoading = true;
                  _currentUrl = url.toString();
                });

                _checkIfSecure(url.toString());
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  _isLoading = false;
                  _currentUrl = url.toString();
                });
                controller.getTitle().then((title) {
                  setState(() {});
                });
              },
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          color: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      _isSecure
                          ? Ionicons.medical_outline
                          : Ionicons.alert_outline,
                      color: _isSecure
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      _showBottomSheet(context);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Ionicons.search_outline,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    onPressed: () {
                      _openSearchBar(); // Llama a la función para enfocar el TextField
                    },
                  ),
                  GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: _currentUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          content: Text(
                            S.current.copiado,
                            style: TextStyle(
                              fontFamily: "PON",
                              fontSize: 20,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                    child: IconButton(
                      icon: Icon(
                        Ionicons.arrow_undo_outline,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      onPressed: () async {
                        await Share.share(_currentUrl);
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _isLoading ? null : 0.0,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _selectAllText();
  }
}
