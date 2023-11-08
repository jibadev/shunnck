import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ionicons/ionicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../generated/l10n.dart';

class NavalView extends StatefulWidget {
  final int pageId;

  const NavalView({Key? key, required this.pageId}) : super(key: key);

  @override
  _NavalViewState createState() => _NavalViewState();
}

class _NavalViewState extends State<NavalView> {
  String _title = '';
  List<TextSpan> _description = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _loadPageContent(widget.pageId);
    });
  }

  Future<void> _loadPageContent(int pageId) async {
    final locale = Localizations.localeOf(context);
    final isSpanish = locale.languageCode == 'es';

    final apiUrl = isSpanish
        ? 'https://es.wikipedia.org/w/api.php?action=query&format=json&prop=extracts|info&pageids=$pageId&explaintext=true'
        : 'https://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts|info&pageids=$pageId&explaintext=true';

    final response = await http.get(Uri.parse(apiUrl));

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

  @override
  Widget build(BuildContext context) {
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
      body: Stack(
        children: [
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
        ],
      ),
    );
  }
}
