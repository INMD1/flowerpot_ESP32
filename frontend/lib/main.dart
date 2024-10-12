import 'package:flowerpot_esp32/page/color_set.dart';
import 'package:flutter/material.dart';
import 'package:flowerpot_esp32/page/blue_tooth.dart';
import 'package:flowerpot_esp32/page/main_page.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 주로 실행하는 코드
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  first_data();
  runApp(const ALLlife());
}

Future<void> first_data()  async {
  SharedPreferences Shardata = await SharedPreferences.getInstance();
  if (await Shardata.getString("blue_connect") == null) {
    await Shardata.setString("blue_connect", '{"connect":"0"}');
    print("처음이라서 생성함");
  }else{
    print("object");
  }
}

class PageLoader extends StatelessWidget {
  final Future<void> future;
  final WidgetBuilder builder;


  const PageLoader({required this.future, required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()), // 로딩 인디케이터 추가
          );
        } else {
          return builder(context); // 로딩 완료 후 페이지 전환
        }
      },
    );
  }
}

// 블루투스 권한 페이지
class BluetoothPermissionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth 권한 확인'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await checkBluetoothPermission(context);
          },
          child: const Text('Bluetooth 권한 확인 및 설정'),
        ),
      ),
    );
  }

  Future<void> checkBluetoothPermission(BuildContext context) async {
    var status = await Permission.bluetoothConnect.status;
    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('블루투스 권한이 이미 허용되었습니다.')),
      );
    } else if (status.isDenied || status.isPermanentlyDenied) {
      _showPermissionDialog(context);
    }
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("블루투스 권한 필요"),
          content: const Text("블루투스 기능을 사용하려면 권한을 허용해 주세요."),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text("설정으로 이동"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소"),
            ),
          ],
        );
      },
    );
  }
}

// GoRouter 설정
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const mainpage()),
    GoRoute(path: '/blue_page', builder: (context, state) =>  bluepage()),
    GoRoute(path: '/color_picker', builder: (context, state) =>  color_pickerepage()),
  ],
  errorBuilder: (context, state) => const ErrorPage(),
);

// 오류 페이지
class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(child: Text('Page not found')),
    );
  }
}

class ALLlife extends StatelessWidget {
  const ALLlife({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ALL-Life',
      theme: ThemeData(
        iconTheme: const IconThemeData(color: Colors.black), // 아이콘 색상
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.black), // 버튼 색상
        ),
      ),
      routerConfig: _router, // GoRouter 사용
    );
  }
}
