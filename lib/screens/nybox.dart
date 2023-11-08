import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shunnck/screens/home.dart';
import '../generated/l10n.dart';
import 'inicio.dart';
import 'ion.dart';

class NyboxView extends StatefulWidget {
  const NyboxView({Key? key}) : super(key: key);

  @override
  State<NyboxView> createState() => _NyboxViewState();
}

class _NyboxViewState extends State<NyboxView> {
  final TextEditingController _textEditingController = TextEditingController();
  late FocusNode _textFocusNode;
  double _opacityLevel = 1.0;
  late Timer _opacityTimer;

  @override
  void initState() {
    super.initState();
    _startOpacityTimer();
    _textFocusNode = FocusNode();
    _openKeyboard();
  }

  void _startOpacityTimer() {
    _opacityTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      setState(() {
        _opacityLevel = _opacityLevel == 1 ? 0.6 : 1;
      });
    });
  }

  @override
  void dispose() {
    _opacityTimer.cancel();
    _textEditingController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmitted(String userInput) {
    final isLink = Uri.tryParse(userInput)?.hasScheme ?? false;

    if (userInput.startsWith("!")) {
      final homeScreenUrl =
          'https://duckduckgo.com/?q=${Uri.encodeComponent(userInput)}';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(url: homeScreenUrl),
        ),
      );
    } else if (isLink) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(url: userInput),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IonScreen(searchQuery: userInput),
        ),
      );
    }

    _textEditingController.clear();
  }

  void _openKeyboard() {
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(_textFocusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const InicioScreen()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                fontFamily: "PON",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Ionicons.shield_checkmark,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onBackground
                    : Theme.of(context).primaryColor,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: AnimatedOpacity(
          opacity: _opacityLevel,
          duration: const Duration(seconds: 1),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: TextField(
              controller: _textEditingController,
              focusNode: _textFocusNode,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                hintText: S.current.buscar,
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 50,
                  height: 1.3,
                  fontFamily: 'PON',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(27),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(27),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 50,
                height: 1.3,
                fontFamily: "PON",
              ),
              maxLines: null,
              textInputAction: TextInputAction.go,
              onSubmitted: _handleSubmitted,
            ),
          ),
        ),
      ),
    );
  }
}
