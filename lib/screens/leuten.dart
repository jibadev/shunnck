import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ionicons/ionicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shunnck/screens/home.dart';
import '../generated/l10n.dart';
import 'ion.dart';

class LeutenView extends StatefulWidget {
  final int pageId;

  const LeutenView({Key? key, required this.pageId}) : super(key: key);

  @override
  _LeutenViewState createState() => _LeutenViewState();
}

class _LeutenViewState extends State<LeutenView> {
  String text = "";
  List<Map<String, String>> buttons = [];
  int currentPage = 0;
  late PageController pageController;
  bool isLoading = true; // Variable para controlar la carga

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(
        Uri.parse('http://intsplay.com/holowide/wat/${widget.pageId}.json'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final firstItem = data['0'];
      setState(() {
        text = firstItem['text'];
        buttons = List<Map<String, String>>.from(
            firstItem['buttons'].values.map((dynamic button) {
          return {
            'name': button['name'].toString(),
            'link': button['link'].toString(),
          };
        }));
        isLoading = false; // La carga se ha completado
      });
    } else {
      throw Exception('Failed to load data');
    }
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
        title: Center(
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
        actions: [
          IconButton(
            icon: Icon(
              Ionicons.sparkles_outline,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(children: [
        CustomAnimatedGradient(),
        isLoading
            ? Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onBackground
                      : Theme.of(context).primaryColor,
                  size: 57,
                ),
              )
            : PageView.builder(
                scrollDirection: Axis.vertical,
                controller: pageController,
                itemCount: buttons.length + 1,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, bottom: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              index == 0
                                  ? Text(
                                      text,
                                      style: const TextStyle(fontSize: 34),
                                    )
                                  : Text(
                                      buttons[index - 1]['name']!,
                                      style: TextStyle(
                                        fontSize: 34,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        if (index > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all<double>(0),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onBackground
                                      : Theme.of(context).primaryColor,
                                ),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                String urlToPass = buttons[index - 1]
                                    ['link']!; // Obtén la URL del botón
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HomeScreen(url: urlToPass),
                                  ),
                                );
                              },
                              child: Text(
                                "Abrir enlace",
                                style: TextStyle(
                                  fontSize: 22,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
              ),
      ]),
    );
  }
}
