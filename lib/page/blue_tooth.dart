import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BluePage extends StatefulWidget {
  const BluePage({super.key});

  @override
  _BluePageState createState() => _BluePageState();
}

class _BluePageState extends State<BluePage> with WidgetsBindingObserver {
  final FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  final List<DiscoveredDevice> devicesList = [];
  StreamSubscription<DiscoveredDevice>? scanStream;

  @override
  void initState() {
    super.initState();
    scan();
  }

  void scan() {
    scanStream = flutterReactiveBle.scanForDevices(
      scanMode: ScanMode.lowLatency,
      withServices: [],
    ).listen(
          (device) {
        setState(() {
          // 이미 존재하는 장치가 아닐 경우에만 추가
          if (!devicesList.any((d) => d.id == device.id)) {
            devicesList.add(device);
          }
        });
      },
      onError: (e) {
        print("Error while scanning: $e");
      },
    );
  }

  Future<void> connectToDevice(String deviceId) async {
    final connection = flutterReactiveBle.connectToDevice(id: deviceId).listen(
          (connectionState) {
        // connectionState는 ConnectionState가 아닌 'ConnectionState' 객체를 사용해야 합니다.
        switch (connectionState.connectionState) {
          case DeviceConnectionState.connected:
            print("Connected to $deviceId");
            // 연결된 후 수행할 작업 추가
            break;
          case DeviceConnectionState.disconnected:
            print("Disconnected from $deviceId");
            // 연결 해제된 후 작업 추가
            break;
          default:
            break;
        }
      },
      onError: (e) {
        print("Error while connecting: $e");
      },
    );

    // 연결이 끝나면 구독을 취소합니다.
    connection.cancel();
  }

  @override
  void dispose() {
    scanStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Devices'),
      ),
      body: ListView.builder(
        itemCount: devicesList.length,
        itemBuilder: (context, index) {
          final device = devicesList[index];
          return ListTile(
            title: Text(device.name.isNotEmpty ? device.name : 'N/A'),
            subtitle: Text(device.id),
            onTap: () {
              connectToDevice(device.id);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 스캔 재시작
          devicesList.clear(); // 기존 장치 리스트 초기화
          scan();
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
