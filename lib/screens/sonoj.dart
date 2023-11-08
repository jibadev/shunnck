import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ionicons/ionicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../generated/l10n.dart';
import '../data/websites.dart';
import 'home.dart';

class SonojView extends StatefulWidget {
  final int pageId;

  const SonojView({Key? key, required this.pageId}) : super(key: key);

  @override
  _SonojViewState createState() => _SonojViewState();
}

class _SonojViewState extends State<SonojView> {
  String _title = '';
  List<TextSpan> _description = [];
  bool _isLoading = true;
  bool _openHomePage = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadPageContent(widget.pageId);
    });
  }

  Future<void> _loadPageContent(int pageId) async {
    if (sitiosweb.containsKey(pageId.toString())) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                HomeScreen(url: sitiosweb[widget.pageId.toString()]!['url']),
          ),
        );
      });
    } else {
      await _fetchWikipediaArticle(pageId);
      _showCustomSnackbar("Se abrió el artículo enlazado al resultado.");
    }
  }

  Future<void> _fetchWikipediaArticle(int pageId) async {
    final descriptionUrl = Uri.parse(
        'https://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts|info&pageids=$pageId&explaintext=true');

    final response = await http.get(descriptionUrl);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final page = body['query']['pages'][pageId.toString()];
      final title = page['title'] ?? '';
      final article = page['extract'] ?? '';
      setState(() {
        _title = title;
        _description = _processDescription(article);
        _isLoading = false;
      });
    }
  }

  List<TextSpan> _processDescription(String input) {
    final RegExp titleRegex = RegExp(r'==([^=]+)==');
    final matches = titleRegex.allMatches(input);
    List<TextSpan> textSpans = [];
    int lastEnd = 0;

    for (var match in matches) {
      if (match.start > lastEnd) {
        textSpans.add(TextSpan(
          text: input.substring(lastEnd, match.start),
        ));
      }

      textSpans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ));

      lastEnd = match.end;
    }

    if (lastEnd < input.length) {
      textSpans.add(TextSpan(
        text: input.substring(lastEnd),
      ));
    }

    return textSpans;
  }

  void _showCustomSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        content: Text(
          message,
          style: TextStyle(
            fontFamily: "PON",
            fontSize: 20,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_openHomePage) {
      return Container(); // Devuelve un contenedor vacío mientras se realiza la navegación
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            onPressed: () {},
            icon: Icon(
              Ionicons.medical,
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
      body: Stack(children: [
        _isLoading
            ? Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onBackground
                      : Theme.of(context).primaryColor,
                  size: 57,
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const SizedBox(height: 10),
                  Text(
                    _title,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  Text(
                    "Artículo de Wikipedia",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 13),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        height: 1.4,
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onBackground,
                        fontFamily: "SJ",
                        fontWeight: FontWeight.bold,
                      ),
                      children: _description,
                    ),
                  ),
                ],
              ),
      ]),
    );
  }
}
