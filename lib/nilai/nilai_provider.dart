import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' show Client, Response;
import 'package:sisfo_mobile/nilai/nilai_model.dart';
import 'package:sisfo_mobile/nilai/tahun_khs_model.dart';
import 'package:sisfo_mobile/providers/global_config.dart';
import 'package:sisfo_mobile/providers/storage.dart';

class NilaiProvider extends ChangeNotifier {
  Client client = Client();
  Response response;

  bool loading = false, error = false, adaData = false, adaDataNilai = false;
  String message = '';
  TahunKHS tahunKHS = new TahunKHS();
  NilaiModel nilaiModel = new NilaiModel();

  bool get isLoading => loading;
  bool get isError => error;
  bool get isData => adaData;
  bool get isDataNilai => adaDataNilai;

  String get isMsg => message;
  TahunKHS get dataTahunKHS => tahunKHS;
  NilaiModel get dataNilai => nilaiModel;

  set setLoading(val) {
    loading = val;
    notifyListeners();
  }

  set setError(val) {
    error = val;
    notifyListeners();
  }

  set setMessage(val) {
    message = val;
    notifyListeners();
  }

  set setTahunKHS(val) {
    tahunKHS = val;
    notifyListeners();
  }

  set setData(val) {
    adaData = val;
    notifyListeners();
  }

  set setNilai(val) {
    tahunKHS = val;
    notifyListeners();
  }

  set setDataNilai(val) {
    adaData = val;
    notifyListeners();
  }

  //Fungsi Ambil Tahun KHS
  doGetTahunKHS() async {
    setLoading = true;
    response = await getTahunKHS();
    print(response.statusCode);
    if (response != null) {
      if (response.statusCode == 200) {
        var tmp = json.decode(response.body);
        setTahunKHS = TahunKHS.fromJson(tmp);
        setData = true;
        await doGetNilai(tahun: dataTahunKHS.data[0].tahunid);
      } else if (response.statusCode == 401) {
        setMessage = 'Otentikasi tidak berhasil!';
        setError = true;
      } else {
        setMessage = 'Silahkan coba lagi!';
        setError = true;
      }
    } else {
      print('Response tidak ditemukan');
    }
  }

  getTahunKHS() async {
    var token = await store.token();
    final headerJwt = {
      'Content-Type': 'application/json',
      HttpHeaders.authorizationHeader: 'Barer $token'
    };
    try {
      response =
          await client.post('$api/mahasiswa/tahun-khs', headers: headerJwt);
      setLoading = false;
      return response;
    } catch (e) {
      print(e.toString());
      setLoading = false;
      setError = true;
      setMessage = 'Coba lagi, tidak dapat menghubungkan';
    }
  }

  //Fungsi ambil nilai
  doGetNilai({@required String tahun}) async {
    setLoading = true;
    response = await getNilai(tahun: tahun);
    //TODO masalah 400 saat get nilai
    print('doGetNilai / statusCode : ${response.statusCode}');
    if (response != null) {
      if (response.statusCode == 200) {
        var tmp = json.decode(response.body);
        setTahunKHS = NilaiModel.fromJson(tmp);
        setData = true;
      } else if (response.statusCode == 401) {
        setMessage = 'Otentikasi tidak berhasil!';
        setError = true;
      } else {
        setMessage = 'Silahkan coba lagi!';
        setError = true;
      }
    } else {
      print('Response tidak ditemukan');
    }
  }

  getNilai({@required String tahun}) async {
    var token = await store.token();
    var data = json.encode({"tahunid": tahun});
    print(data);
    final header = {
      'Content-Type': 'application/json',
      HttpHeaders.authorizationHeader: 'Barer $token'
    };
    try {
      response = await client.post('$api/mahasiswa/nilai',
          headers: header, body: data);
      setLoading = false;
      return response;
    } catch (e) {
      print(e.toString());
      setLoading = false;
      setError = true;
      setMessage = 'Coba lagi, tidak dapat menghubungkan';
    }
  }
}