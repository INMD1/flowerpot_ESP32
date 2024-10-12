import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class mainpage extends StatefulWidget {
  const mainpage({super.key});

  @override
  _mainpageState createState() => _mainpageState();
}

class _mainpageState extends State<mainpage> with WidgetsBindingObserver {
  //블루투스 관련
  Map<String, dynamic> data = {};

  @override
  void initState() {
    super.initState();
    print("이 페이지가 로드됨");
    _loadLocation();
    WidgetsBinding.instance.addObserver(this);
  }

  //메모리 누수 방지
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadLocation() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    data = jsonDecode(sp.getString("blue_connect").toString());
    setState(() {
      data = jsonDecode(sp.getString("blue_connect").toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      body: Container(
        color: Color(0xffe1e7ef),
        child: Column(
          children: [
            Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.08),
                    Text("스마트팜 센서 현황", style: TextStyle(fontSize: 35)),
                    Text("XXXX.XX.XX XX:XX 기준", style: TextStyle(fontSize: 12)),
                  ],
                )),
            Expanded(
              flex: 7,
              child: Container(
                width: double.infinity,
                child: Container(
                  margin: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    children: [
                    SizedBox(
                    height: screenHeight * 0.01,
                    width: double.infinity,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.39,
                        height: screenHeight * 0.19,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xfffcfcfc),
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("온도센서",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: screenHeight * 0.008),
                                Center(
                                  child: Text("10" + "°C",
                                      style: TextStyle(fontSize: 50)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.39,
                        height: screenHeight * 0.19,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xfffcfcfc),
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("대기 습도",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: screenHeight * 0.008),
                                Center(
                                  child: Text("10" + "%",
                                      style: TextStyle(fontSize: 50)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.03,
                    width: double.infinity,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    SizedBox(
                    width: screenWidth * 0.39,
                    height: screenHeight * 0.19,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Color(0xfffcfcfc),
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("토양 수분",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: screenHeight * 0.008),
                            Center(
                              child: Text("10" + "%",
                                  style: TextStyle(fontSize: 50)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.39,
                    height: screenHeight * 0.19,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xfffcfcfc),
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      child: Container(
                          margin: EdgeInsets.fromLTRB(14, 20, 10, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("블루투스 연결",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),

                              SizedBox(height: screenHeight * 0.02),
                              InkWell(
                                  onTap: () {
                                    if(data["connect"] == "0"){
                                      context.go("/blue_page");
                                    }
                                    print("나눌려짐");
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                  Image.asset(
                                  data["connect"] == "0"
                                  ? "assets/image/Disconnect.png"
                                      : "assets/image/Connect.png",
                                    width: screenWidth * 0.15,
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.
                                    start,
                                    children: [
                                      Text("MAC 주소"),
                                      Text(data["connect"] == "0"
                                          ? "연결이 안되어 있습니다."
                                          : "0.",
                                        style: TextStyle(fontSize: 10),)
                                    ],
                                  ))
                            ],
                          )
                      )
                      ],
                    ),
                  ),
                ),
              ),
              ],
            ),
            SizedBox(
              height: screenHeight * 0.015,
              width: double.infinity,
            ),
            Container(
              margin: EdgeInsets.all(screenWidth * 0.028),
              width: double.infinity,
              height: screenHeight * 0.15,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xfffcfcfc),
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.06,
                      ),
                      const Image(
                          image: AssetImage(
                              "assets/image/color_picker.png")),
                      SizedBox(
                        width: screenWidth * 0.03,
                      ),
                      const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "색깔을 조합해 보세요",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17),
                              ),
                              Text(
                                "현재 공간에 맞게 사용자가 직접 설정할수 있습니다.",
                              )
                            ],
                          )),
                      SizedBox(
                        width: screenWidth * 0.06,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    ),
    ],
    ),
    ),
    );
  }
}
