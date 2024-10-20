#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <DHT.h>
#include <ArduinoJson.h>
#include <Preferences.h>
#include <nvs_flash.h>
#include <Adafruit_NeoPixel.h>
#include <string.h>

#define DHTPIN 13     // DHT11 센서가 연결된 핀
#define DHTTYPE DHT11 // 사용 중인 센서 타입

// WS2812B 설정
#define LED_PIN 6   // LED 핀 (WS2812B가 연결된 핀)
#define NUM_LEDS 16 // LED 개수
Adafruit_NeoPixel strip = Adafruit_NeoPixel(NUM_LEDS, LED_PIN, NEO_GRB + NEO_KHZ800);

DHT dht(DHTPIN, DHTTYPE);

// BLE 서비스와 특성(UUID 정의)
#define SERVICE_UUID "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID_RX "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID_TX "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

// INI 쓰기
void SetIni(String sNamespace, String sKey, String sValue)
{
  Preferences preferences;
  preferences.begin(sNamespace.c_str(), false);
  preferences.putString(sKey.c_str(), sValue.c_str());
  preferences.end();
}

// INI 읽기
String GetIni(String sNamespace, String sKey, String sDefaultValue)
{
  Preferences preferences;
  String sValue;
  preferences.begin(sNamespace.c_str(), false);
  sValue = preferences.getString(sKey.c_str(), sDefaultValue.c_str());
  preferences.end();
  return sValue;
}

// 단어 제거 함수
void removeWord(char *str, const char *word)
{
  int len = strlen(word);
  char *pos = strstr(str, word); // 문자열에서 단어의 시작 위치 찾기

  // 단어가 문자열에 없을 때까지 반복
  while (pos != NULL)
  {
    // 단어를 삭제하고 남은 문자열을 앞으로 이동
    memmove(pos, pos + len, strlen(pos + len) + 1);
    pos = strstr(str, word); // 다음 단어 위치 찾기
  }
}

// WS2812B에 RGB 색상 설정
void setLEDColor(int r, int g, int b)
{
  for (int i = 0; i < NUM_LEDS; i++)
  {
    strip.setPixelColor(i, strip.Color(r, g, b)); // 모든 LED에 동일한 색상 설정
  }
  strip.show(); // LED에 색상 출력
}

BLECharacteristic *pTxCharacteristic;
bool deviceConnected = false;
String receivedData = "";

class MyServerCallbacks : public BLEServerCallbacks
{
  void onConnect(BLEServer *pServer)
  {
    deviceConnected = true;
  }

  void onDisconnect(BLEServer *pServer)
  {
    deviceConnected = false;
    pServer->getAdvertising()->start();
  }
};

class MyCallbacks : public BLECharacteristicCallbacks
{
  void onWrite(BLECharacteristic *pCharacteristic)
  {
    std::string rxValue = pCharacteristic->getValue();
    if (rxValue.length() > 0)
    {
      receivedData = String(rxValue.c_str());
      Serial.println("Received: " + receivedData);

      // 센서 관련
      if (receivedData == "get_temp_humidity")
      {
        // DHT11 센서 데이터 읽기
        float temperature = dht.readTemperature();
        float humidity = dht.readHumidity();

        // JSON 형식으로 데이터를 작성
        StaticJsonDocument<200> doc;
        doc["temperature"] = temperature;
        doc["humidity"] = humidity;
        String output;
        serializeJson(doc, output);

        // BLE를 통해 데이터를 전송
        if (deviceConnected)
        {
          pTxCharacteristic->setValue(output.c_str());
          pTxCharacteristic->notify(); // 클라이언트에 알림 전송
          Serial.println("Sent: " + output);
        }
      }

      // 연결 테스트
      if (receivedData == "connect_test")
      {
        // JSON 형식으로 데이터를 작성
        StaticJsonDocument<200> doc;
        doc["connect"] = "OK";
        String output;
        serializeJson(doc, output);

        // BLE를 통해 데이터를 전송
        if (deviceConnected)
        {
          pTxCharacteristic->setValue(output.c_str());
          pTxCharacteristic->notify(); // 클라이언트에 알림 전송
          Serial.println("Sent: " + output);
        }
      }

      // RGB 설정
      if (receivedData.startsWith("rgb_set"))
      {
        char receivedDataChar[receivedData.length() + 1];
        receivedData.toCharArray(receivedDataChar, receivedData.length() + 1);

        // "rgb_set" 제거
        removeWord(receivedDataChar, "rgb_set");

        // RGB 값 추출
        int r, g, b;
        sscanf(receivedDataChar, "(%d, %d, %d)", &r, &g, &b);

        // 데이터 저장
        SetIni("rgb", "set_red", String(r));
        SetIni("rgb", "set_green", String(g));
        SetIni("rgb", "set_blue", String(b));

        // LED에 색상 설정
        setLEDColor(r, g, b);

        // BLE를 통해 데이터를 전송
        if (deviceConnected)
        {
          String output = "RGB set to: (" + String(r) + ", " + String(g) + ", " + String(b) + ")";
          pTxCharacteristic->setValue(output.c_str());
          pTxCharacteristic->notify(); // 클라이언트에 알림 전송
          Serial.println("Sent: " + output);
        }
      }

      // RGB 값 가져오기
      if (receivedData == "rgb_get")
      {
        String r = GetIni("rgb", "set_red", "255");
        String g = GetIni("rgb", "set_green", "255");
        String b = GetIni("rgb", "set_blue", "255");

        String output_rgb_get = "RGB: (" + r + ", " + g + ", " + b + ")";

        if (deviceConnected)
        {
          pTxCharacteristic->setValue(output_rgb_get.c_str());
          pTxCharacteristic->notify(); // 클라이언트에 알림 전송
          Serial.println("Sent: " + output_rgb_get);
        }

        // LED에 색상 적용
        setLEDColor(r.toInt(), g.toInt(), b.toInt());
      }
    }
  }
};

void setup()
{
  Serial.begin(115200);
  dht.begin();
  strip.begin();
  strip.show(); // LED를 초기화

  //부팅될때 한번만 실해하게 한다.
  String r = GetIni("rgb", "set_red", "255");
  String g = GetIni("rgb", "set_green", "255");
  String b = GetIni("rgb", "set_blue", "255");
  setLEDColor(r.toInt(), g.toInt(), b.toInt());

  // BLE 초기화
  BLEDevice::init("ESP32-Farm-Test");
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // BLE 서비스 생성
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // TX 특성 생성 (ESP32 -> 클라이언트)
  pTxCharacteristic = pService->createCharacteristic(
      CHARACTERISTIC_UUID_TX,
      BLECharacteristic::PROPERTY_NOTIFY);
  pTxCharacteristic->addDescriptor(new BLE2902());

  // RX 특성 생성 (클라이언트 -> ESP32)
  BLECharacteristic *pRxCharacteristic = pService->createCharacteristic(
      CHARACTERISTIC_UUID_RX,
      BLECharacteristic::PROPERTY_WRITE);
  pRxCharacteristic->setCallbacks(new MyCallbacks());

  // BLE 서비스 시작
  pService->start();

  // BLE 광고 시작
  pServer->getAdvertising()->start();
  Serial.println("Waiting for client connection...");
}

void loop()
{
  // 블루투스 연결이 유지된 상태에서만 데이터를 처리
  if (deviceConnected)
  {
    delay(1000);
  }
}
