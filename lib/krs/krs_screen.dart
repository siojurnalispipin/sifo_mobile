import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:permissions_plugin/permissions_plugin.dart';
import 'package:provider/provider.dart';
import 'package:sisfo_mobile/krs/krs_pdf_viewer.dart';
import 'package:sisfo_mobile/krs/krs_pengajuan_screen.dart';
import 'package:sisfo_mobile/krs/models/krs_model.dart';
import 'package:sisfo_mobile/krs/krs_provider.dart';
import 'package:sisfo_mobile/krs/widgets/info_widget.dart';
import 'package:sisfo_mobile/services/global_config.dart';
import 'package:sisfo_mobile/services/storage.dart';
import 'package:sisfo_mobile/widgets/error_widget.dart';
import 'package:sisfo_mobile/widgets/loading.dart';
import 'package:toast/toast.dart';

class KrsScreen extends StatefulWidget {
  KrsScreen({Key key}) : super(key: key);

  @override
  _KrsScreenState createState() => _KrsScreenState();
}

class _KrsScreenState extends State<KrsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<KrsProvider>(context, listen: false).doGetTahunAjaranAktif();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appbarColor,
        title: Text('KRS'),
        actions: [cekToShowDownloadKRS()],
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      colorFilter: new ColorFilter.mode(
                          Colors.black.withOpacity(0.2), BlendMode.dstATop),
                      image: AssetImage('assets/images/bg-stikes.jpg'),
                      fit: BoxFit.cover)),
              padding: EdgeInsets.only(left: 10, top: 20, bottom: 20),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        LineIcons.user,
                        color: Colors.black.withOpacity(0.4),
                        size: 40,
                      ),
                      cekStatusKRS(),
                    ],
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cekTahunKRS(),
                      FutureBuilder(
                        future: store.nama(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: textPrimary),
                            );
                          } else {
                            return loadingH2;
                          }
                        },
                      ),
                      FutureBuilder(
                        future: store.npm(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: textPrimary),
                            );
                          } else {
                            return loadingH3;
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            cekStatusKRSBody()
          ],
        ),
      )),

      //Pengajuan KRS
    );
  }

  Widget cekToShowDownloadKRS() {
    final KrsProvider prov = Provider.of<KrsProvider>(context);
    if (prov.isAdaDataStatusKRS) {
      return (prov.dataStatusKRS.data.statuskrs == 'Aktif' ||
              prov.dataStatusKRS.data.statuskrs == 'A')
          ? GestureDetector(
              child: Padding(
                padding: EdgeInsets.only(right: 20),
                child: Row(
                  children: [
                    Icon(
                      LineIcons.cloud_download,
                      color: textWhite,
                      size: 20,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    !prov.isLoadingPdfKRS
                        ? Text(
                            'Download KRS',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: textWhite),
                          )
                        : Text(
                            'Downloading ...',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                  ],
                ),
              ),
              onTap: () async {
                await PermissionsPlugin.requestPermissions([
                  Permission.READ_EXTERNAL_STORAGE,
                  Permission.WRITE_EXTERNAL_STORAGE,
                ]);
                await prov.downloadPDFKRS();
                if (prov.isDataPDF) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => KRSPdfViewer(
                                path: prov.pDFpath,
                              )));
                  Toast.show(prov.isMessage, context,
                      gravity: Toast.TOP, duration: 3);
                } else {
                  Toast.show(prov.isMessage, context,
                      gravity: Toast.TOP, duration: 3);
                }
              },
            )
          : Container();
    } else {
      return Container();
    }
  }

  Widget cekTahunKRS() {
    final KrsProvider prov = Provider.of<KrsProvider>(context);
    if (prov.isLoading) {
      return loadingH1;
    } else if (prov.isErrorTahun) {
      print('Error at cekTahunKRS');
      return Container();
    } else if (!prov.isDataTAaktif) {
      return Text('Tahun Ajaran Aktif tidak ada!');
    } else if (prov.isDataTAaktif) {
      return Text(prov.dataTahunAktif?.data?.namaTA ?? '-');
    } else {
      return Container();
    }
  }

  Widget cekStatusKRS() {
    final KrsProvider prov = Provider.of<KrsProvider>(context);
    if (prov.isLoadingStatusKRS) {
      return Container();
    } else if (prov.isErrorStatusKRS) {
      print('Error at CekStatusKRS');
      return Container();
    } else if (!prov.isAdaDataStatusKRS) {
      return Container();
    } else if (prov.isAdaDataStatusKRS) {
      return Container(
          padding: EdgeInsets.only(left: 5, right: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: primaryRed,
          ),
          child: Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                "${prov.dataStatusKRS?.data?.statuskrs ?? '-'}",
                style: TextStyle(color: Colors.white, fontSize: 12),
              )));
    } else {
      return Container();
    }
  }

  Widget cekStatusKRSBody() {
    final KrsProvider prov = Provider.of<KrsProvider>(context);

    if (prov.isLoadingStatusKRS) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [loadingTable],
      );
    } else if (prov.isErrorStatusKRS) {
      print('PROV.ISERRORSTATUSKRS: ${prov.isErrorStatusKRS}');
      return Column(
        children: [
          SomeError(),
          RaisedButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textColor: Colors.blueGrey,
            onPressed: () async {
              await prov.doGetTahunAjaranAktif();
              Toast.show(prov.isMessage, context,
                  duration: 3, gravity: Toast.TOP);
            },
            child: Text('Reload'),
          )
        ],
      );
    } else if (prov.isAdaDataStatusKRS) {
      return (prov.dataStatusKRS.data.statuskrs == 'Aktif' ||
              prov.dataStatusKRS.data.statuskrs == 'A')
          ? cekKRS()
          : Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoWidget(
                    info:
                        'Belum memenuhi syarat ambil KRS. Silahkan hubungi Administrasi',
                  ),
                ],
              ),
            );
    } else if (prov.isAdaDataStatusKRS == false) {
      return Column(
        children: [
          loadingTable,
          RaisedButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textColor: Colors.blueGrey,
            onPressed: () async {
              await prov.doGetTahunAjaranAktif();
              Toast.show(prov.isMessage, context,
                  duration: 3, gravity: Toast.TOP);
            },
            child: Text('Reload'),
          )
        ],
      );
    } else {
      return Container();
    }
  }

  Widget cekKRS() {
    final KrsProvider prov = Provider.of<KrsProvider>(context);

    if (prov.isLoadingKRS) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [loadingTable],
      );
    } else if (prov.isErrorKRS) {
      return Column(
        children: [
          SomeError(),
          RaisedButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textColor: Colors.blueGrey,
            onPressed: () async {
              await prov.doGetKRS(khsid: prov.dataStatusKRS.data.kHSID);
              Toast.show(prov.isMessage, context,
                  duration: 3, gravity: Toast.TOP);
            },
            child: Text('Reload'),
          )
        ],
      );
    } else if (!prov.isAdaDataKRS) {
      print('masuk sini');
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: InfoWidget(
            info:
                'Belum pernah melakukan pengisian KRS. Harap menghubungi bagian Akademik'),
      );
    } else if (prov.isAdaDataKRS) {
      return Container(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cekKRSData(),
            SizedBox(
              height: 10,
            ),
            prov.isSenin
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: primaryYellow,
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "Senin",
                          style: TextStyle(color: Colors.black87, fontSize: 11),
                        )))
                : Container(),
            prov.isSenin ? cekKRSHari(hari: 1) : Container(),
            Divider(),
            prov.isSelasa
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: primaryYellow,
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "Selasa",
                          style: TextStyle(color: Colors.black87, fontSize: 11),
                        )))
                : Container(),
            prov.isSelasa ? cekKRSHari(hari: 2) : Container(),
            Divider(),
            prov.isRabu
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: primaryYellow,
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "Rabu",
                          style: TextStyle(color: Colors.black87, fontSize: 11),
                        )))
                : Container(),
            prov.isRabu ? cekKRSHari(hari: 3) : Container(),
            Divider(),
            prov.isKamis
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: primaryYellow,
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "Kamis",
                          style: TextStyle(color: Colors.black87, fontSize: 11),
                        )))
                : Container(),
            prov.isKamis ? cekKRSHari(hari: 4) : Container(),
            Divider(),
            prov.isJumat
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: primaryYellow,
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "Jumat",
                          style: TextStyle(color: Colors.black87, fontSize: 11),
                        )))
                : Container(),
            prov.isJumat ? cekKRSHari(hari: 5) : Container(),
            Divider(),
            prov.isSabtu
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: primaryYellow,
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "Sabtu",
                          style: TextStyle(color: Colors.black87, fontSize: 11),
                        )))
                : Container(),
            prov.isSabtu ? cekKRSHari(hari: 6) : Container(),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget cekKRSData() {
    final KrsProvider prov = Provider.of<KrsProvider>(context);

    if (prov.isAdaDataCekKrs) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          prov.dataCekKrs.data == true
              ? InfoWidget(
                  info:
                      "Batas pengambilan / pengubahan KRS sudah selesai. KRS tidak dapat diubah.")
              : Container(),
          prov.dataCekKrs.data == false
              ? InfoWidget(
                  info: "Silahkan klik 'Ambil KRS' untuk memilih paket KRS.")
              : Container(),
          prov.dataCekKrs.data == false
              ? ButtonTheme(
                  buttonColor: bgColor,
                  minWidth: MediaQuery.of(context).size.width,
                  child: RaisedButton(
                    textColor: Colors.white,
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => KrsPengajuanScreen())),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Ambil KRS'),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(LineIcons.arrow_circle_right),
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget expandedBuilder(Data e, int i) {
    final KrsProvider prov = Provider.of<KrsProvider>(context);
    return Container(
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          print(i);
          if (e.isExpanded == true) {
            prov.setExpanded(i, false);
          } else if (e.isExpanded == false) {
            prov.setExpanded(i, true);
          }
        },
        children: [
          ExpansionPanel(
            canTapOnHeader: true,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nama Mata Kuliah',
                        style: TextStyle(fontSize: 11, color: textPrimary)),
                    Text(
                      e.nama ?? '-',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textPrimary),
                    )
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Dosen : ',
                        style: TextStyle(
                          fontSize: 12,
                        )),
                    Flexible(
                        child: Text(
                      e.dSN ?? '-',
                      style: TextStyle(
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ))
                  ],
                ),
              );
            },
            body: DataTable(
              columnSpacing: 16,
              columns: <DataColumn>[
                DataColumn(label: Text("Kode")),
                DataColumn(label: Text("Jam Kuliah")),
                DataColumn(label: Text("Ruang")),
                DataColumn(label: Text("SKS")),
              ],
              rows: <DataRow>[
                DataRow(
                  cells: <DataCell>[
                    DataCell(Text(e.mKKode ?? '-')),
                    DataCell(Text('${e.jM ?? '-'} - ${e.jS ?? '-'}')),
                    DataCell(Text(e.ruangID ?? '-')),
                    DataCell(Text(e.sKS.toString() ?? '-')),
                  ],
                ),
              ],
            ),
            isExpanded: e.isExpanded,
          )
        ],
      ),
    );
  }

  Widget cekKRSHari({@required hari}) {
    final KrsProvider prov = Provider.of<KrsProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: prov.dataKRS.data.map((e) {
        var index = prov.dataKRS.data.indexOf(e);
        if (e.hariID == hari) {
          return expandedBuilder(e, index);
        } else {
          return Container();
        }
      }).toList(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
