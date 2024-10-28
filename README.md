# 아카이브
누군가의 도음으로 앱 개발은 내가 안하게 되었다.
> 그래도 만약을 위해 플러터 폴더는 삭제안한다. 다른 곳에 쓰일지도 모르니..
# 무슨 프로젝트인가요?
학교에서 실시하는 어느 창업동아리에서 저한데 코딩을 해달라고 의뢰가 들어와서 하는 Flutter과 임베디드 esp32모듈을 연동해서 만드는 프로젝트입니다. 
<br>
<br>
<img src="https://github.com/user-attachments/assets/f9b8dc30-ebaa-4bd2-a391-a1b9412bf5df" width="500" height="300">
>거의 이런 것이지 뭐.. (사진출처: 대학내일)

## 프로젝트에 사용한 기기나 기술
[기술, 프레임워크]<br>
BLE(Bluetooth Low Energy)<br>
Flutter Framwork

[기기]

ESP32<br>
온습도센서(DHT)<br>
RGB가 지원되는 LED 드라이버 모듈

![image](https://github.com/user-attachments/assets/40f0e607-49bd-440d-a80f-5aed85190630)
> 상자안에 기기를 넣어놨다.

## 작동방식
1. 핸드폰에서 앱을 실행합니다.
2. 앱에서 블루투스 연결하기를 이용해 연결합니다.
3. 블루투스에 연결된 순간 일정한 간격으로 단말기에서 정보를 수집합니다.
4. led에 색변화가 필요할경우 컬러 픽커로 색을 정한후에 단말기에 정보를 보냄니다.
5. 단말기에서는 색 RGB값을 분석해서 색을 표현합니다.
   
## 명령어 
```
get_temp_humidity -> json 형태로 온도와 실내 습도를 알려줌
connect_test -> json형태로 연결 상태를 알려준다. 연결이 안된경우아 오류가 발생하면 안알려준다
rgb_set (R, G, B) //rgb깂으로 보내주면 LED 색이 변한댜ㅏ.
```


