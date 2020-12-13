import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storage {
  final storage = new FlutterSecureStorage();

  saveToken({@required String val}) async {
    await storage.write(key: 'token', value: val);
  }

  saveNama({@required String val}) async {
    await storage.write(key: 'nama', value: val);
  }

  saveSplashAction({@required String val}) async {
    /// value splash : true // false
    await storage.write(key: 'splash', value: val);

    print('berhasil simpan $val');
  }

  //Read
  token() async {
    return await storage.read(key: 'token');
  }

  splash() async {
    return await storage.read(key: 'splash');
  }

  nama() async {
    return await storage.read(key: 'nama');
  }

  //Destroy
  destroyToken() async {
    await storage.delete(key: 'token');
  }

  destroyNama() async {
    await storage.delete(key: 'nama');
  }
}

final store = Storage();