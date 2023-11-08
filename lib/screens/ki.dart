import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ionicons/ionicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:convert';

import '../generated/l10n.dart';

class KiView extends StatefulWidget {
  final String searchQuery;

  const KiView({Key? key, required this.searchQuery}) : super(key: key);

  @override
  _KiViewState createState() => _KiViewState();
}

class _KiViewState extends State<KiView> {
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchImages(widget.searchQuery).then((images) {
      setState(() {
        _imageUrls = images;
      });
    });
  }

  Future<List<String>> fetchImages(String searchQuery) async {
    const apiKey =
        '19838244-75281de5343408360c62d8642'; // Reemplaza con tu API Key de Pixabay
    final url = Uri.parse(
        'https://pixabay.com/api/?key=$apiKey&q=$searchQuery&image_type=photo');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<String> imageUrls = [];

      for (var item in data['hits']) {
        imageUrls.add(item['webformatURL']);
      }

      return imageUrls;
    } else {
      throw Exception('Error al cargar imágenes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
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
              Navigator.pushNamedAndRemoveUntil(
                  context, 'inicio', (route) => false);
            },
            icon: Icon(
              Ionicons.exit,
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
      body: _imageUrls.isEmpty
          ? Center(
              child: LoadingAnimationWidget.threeArchedCircle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onBackground
                    : Theme.of(context).primaryColor,
                size: 57,
              ),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
              ),
              itemCount: _imageUrls.length,
              itemBuilder: (BuildContext context, int index) => Image.network(
                _imageUrls[index],
                fit: BoxFit.cover,
              ),
            ),
    );
  }
}
