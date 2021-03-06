import 'package:flutter/material.dart';
import 'package:sisfo_mobile/services/storage.dart';

class InitialProvider extends ChangeNotifier {
  String initialPage;

  String get getInitialPage => initialPage;

  set setInitialPage(val) {
    initialPage = val;
    notifyListeners();
  }

  cekInitialPage() async {
    String splash = await store.splash();
    String token = await store.token();

    if (splash == null) {
      setInitialPage = 'SPLASH';
    } else if (splash != null && token == null) {
      setInitialPage = 'LOGIN';
    } else {
      setInitialPage = 'HOME';
    }
  }
}
