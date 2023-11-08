import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/identificadores.dart';
import '../generated/l10n.dart';

class NFCView extends StatefulWidget {
  const NFCView({Key? key}) : super(key: key);

  @override
  State<NFCView> createState() => _NFCViewState();
}

class _NFCViewState extends State<NFCView> {
  double _opacityLevel = 1.0;
  late FocusNode _textFocusNode;
  late Timer _opacityTimer;
  final Set<String> addedCodes = <String>{};

  @override
  void initState() {
    super.initState();
    _textFocusNode = FocusNode();
    _startOpacityTimer();
    _openKeyboardAndFocus();
  }

  void _startOpacityTimer() {
    _opacityTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      setState(() {
        _opacityLevel = _opacityLevel == 1 ? 0.6 : 1;
      });
    });
  }

  void _openKeyboardAndFocus() {
    _textFocusNode.requestFocus();
  }

  void _verifyCodeAndAddName(String code) async {
    if (nombresEIdentificadores.containsValue(code) &&
        !addedCodes.contains(code)) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final nombre = nombresEIdentificadores.keys
          .firstWhere((key) => nombresEIdentificadores[key] == code);

      final List<String> guardas = prefs.getStringList('guardas') ?? [];
      guardas.add(nombre);
      await prefs.setStringList('guardas', guardas);

      addedCodes.add(code);

      _showSnackBar(S.current.guardaguardado, true);
    } else {
      _showSnackBar(S.current.codigoincorrecto, false);
    }
  }

  void _showSnackBar(String message, bool success) {
    final snackBar = SnackBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      content: Text(
        message,
        style: TextStyle(
          fontFamily: "LeaugeSpartanLite",
          fontSize: 20,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _opacityTimer.cancel();
    _textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: AnimatedOpacity(
          opacity: _opacityLevel,
          duration: const Duration(seconds: 1),
          child: IconButton(
            icon: Icon(
              Ionicons.medical,
              size: 35,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            onPressed: () {},
          ),
        ),
      ),
      body: AnimatedOpacity(
        opacity: _opacityLevel,
        duration: const Duration(seconds: 1),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: TextFormField(
            focusNode: _textFocusNode,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              hintText: S.current.codigoguarda,
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 50,
                height: 1.3,
                fontFamily: 'LeaugeSpartanLite',
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
              fontFamily: "LeaugeSpartanLite",
            ),
            maxLines: null,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (code) {
              _verifyCodeAndAddName(code);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
