import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class bluepage extends StatefulWidget {
  const bluepage({super.key});

  @override
  _bluepageState createState() => _bluepageState();
}

class _bluepageState extends State<bluepage> with WidgetsBindingObserver {
  List<ScanResult> scanResultList = [];
  bool _isScanning = false;
  var connect = 0;

  @override
  initState() {
    super.initState();
    initBle();
  }

  void initBle() {
    // BLE 스캔 상태 얻기 위한 리스너
    FlutterBluePlus.isScanning.listen((isScanning) {
      _isScanning = isScanning;
      setState(() {});
    });
  }

  scan() async {
    if (!_isScanning) {
      // 스캔 중이 아니라면
      // 기존에 스캔된 리스트 삭제
      scanResultList.clear();
      // 스캔 시작, 제한 시간 60초
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 60));

      // 스캔 결과 리스너
      FlutterBluePlus.scanResults.listen((results) {
        // List<ScanResult> 형태의 results 값을 scanResultList에 복사
        scanResultList = results;
        // UI 갱신
        setState(() {
          _isScanning = true;
        });
      });
    }
  }

  Future<void> stopScan() async {
    setState(() {
      _isScanning = false;
    });
    await FlutterBluePlus.stopScan();
  }

  /*
   여기서부터는 장치별 출력용 함수들
  */

  /*  장치의 신호값 위젯  */
  Widget deviceSignal(ScanResult r) {
    return Text(r.rssi.toString());
  }

  /* 장치의 MAC 주소 위젯  */
  Widget deviceMacAddress(ScanResult r) {
    return Text(r.device.remoteId.toString());
  }

  /* 장치의 명 위젯  */
  Widget deviceName(ScanResult r) {
    String name = '';

    if (r.device.advName.isNotEmpty) {
      // device.name에 값이 있다면
      name = r.device.advName;
    } else if (r.advertisementData.advName.isNotEmpty) {
      // advertisementData.localName에 값이 있다면
      name = r.advertisementData.advName;
    } else {
      // 둘다 없다면 이름 알 수 없음...
      name = 'N/A';
    }
    return Text(name);
  }

  /* BLE 아이콘 위젯 */
  Widget leading(ScanResult r) {
    return const CircleAvatar(
      backgroundColor: Colors.cyan,
      child: Icon(
        Icons.bluetooth,
        color: Colors.white,
      ),
    );
  }

  /* 장치 아이템을 탭 했을때 호출 되는 함수 */
  void onTap(ScanResult r) {
    // 장치 정보 표시
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('장치 정보'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('이 기기로 블루투스 정보를 저장하시겟습니까?\n', style: TextStyle(fontSize: 17),),
              Text('이름: ${r.device.advName.isNotEmpty ? r.device.advName : "N/A"}'),
              Text('MAC 주소: ${r.device.remoteId.toString()}\n'),
              Text("저장후 잠시후 연결을 시작합니다.")
            ],
          ),
          actions: [
            TextButton(
              child: const Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('저장'),
              onPressed: () {
                // 장치 연결 로직 추가
                connectToDevice(r.device);
                Navigator.of(context).pop();
                context.go("/");
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      SharedPreferences Shardata = await SharedPreferences.getInstance();
      //await device.connect();
      var savedata = {
        "remoteId" : device.remoteId,
        "platformName" : device.platformName
      };
      //로그
      print('연결 성공: ${device.remoteId}');
      print(device);
      //저장
      //Shardata.setString("bluetooth", jsonEncode(savedata));
      setState(() {
        connect = 1;
      });
    } catch (e) {
      setState(() {
        connect = 2;
      });
      print('연결 실패: $e');
    }
    connect = 0;
  }

  /* 장치 아이템 위젯 */
  Widget listItem(ScanResult r) {
    return ListTile(
      onTap: () => onTap(r),
      leading: leading(r),
      title: deviceName(r),
      subtitle: deviceMacAddress(r),
      trailing: deviceSignal(r),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ListView.separated(
        itemCount: scanResultList.length,
        itemBuilder: (context, index) {
          return listItem(scanResultList[index]);
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
      )),
      /* 장치 검색 or 검색 중지  */
      floatingActionButton: FloatingActionButton(
        onPressed: _isScanning ? stopScan : scan,
        // 스캔 중이라면 stop 아이콘을, 정지상태라면 search 아이콘으로 표시
        child: Icon(_isScanning ? Icons.stop : Icons.search),
      ),
    );
  }

  Future<void> _showsnackbars(BuildContext context) async {
    final snackBar = SnackBar(
      content: Text('정상적으로 연결 했습니다.'),
      duration: Duration(seconds: 5),
      action: SnackBarAction(
        label: '확인',
        onPressed: () {
          // 버튼 눌렀을 때의 작업을 여기에 추가하세요.
        },
      ),
    );

    // SnackBar를 화면에 표시합니다.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
