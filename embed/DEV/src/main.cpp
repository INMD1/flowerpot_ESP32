#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <DHT.h>
#include <ArduinoJson.h>

#define DHTPIN 13      // DHT11 센서가 연결된 핀
#define DHTTYPE DHT11  // 사용 중인 센서 타입

DHT dht(DHTPIN, DHTTYPE);

// BLE 서비스와 특성(UUID 정의)
#define SERVICE_UUID           "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID_RX "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID_TX "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

BLECharacteristic *pTxCharacteristic;
bool deviceConnected = false;
String receivedData = "";

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
    }

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      // 광고 다시 시작
      pServer->getAdvertising()->start();
    }
};

class MyCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string rxValue = pCharacteristic->getValue();
      if (rxValue.length() > 0) {
        receivedData = String(rxValue.c_str());
        Serial.println("Received: " + receivedData);

        if (receivedData == "get_temp_humidity") {
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
          if (deviceConnected) {
            pTxCharacteristic->setValue(output.c_str());
            pTxCharacteristic->notify();  // 클라이언트에 알림 전송
            Serial.println("Sent: " + output);
          }
        }

        if (receivedData == "connect_test") {
          // DHT11 센서 데이터 읽기
          float temperature = dht.readTemperature();
          float humidity = dht.readHumidity();

          // JSON 형식으로 데이터를 작성
          StaticJsonDocument<200> doc;
          doc["connect"] = "OK";
          String output;
          serializeJson(doc, output);

          // BLE를 통해 데이터를 전송
          if (deviceConnected) {
            pTxCharacteristic->setValue(output.c_str());
            pTxCharacteristic->notify();  // 클라이언트에 알림 전송
            Serial.println("Sent: " + output);
          }
        }
      }
    }
};

void setup() {
  Serial.begin(115200);
  dht.begin();

  // BLE 초기화
  BLEDevice::init("ESP32-Farm-Test");
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // BLE 서비스 생성
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // TX 특성 생성 (ESP32 -> 클라이언트)
  pTxCharacteristic = pService->createCharacteristic(
                        CHARACTERISTIC_UUID_TX,
                        BLECharacteristic::PROPERTY_NOTIFY
                      );
  pTxCharacteristic->addDescriptor(new BLE2902());

  // RX 특성 생성 (클라이언트 -> ESP32)
  BLECharacteristic *pRxCharacteristic = pService->createCharacteristic(
                        CHARACTERISTIC_UUID_RX,
                        BLECharacteristic::PROPERTY_WRITE
                      );
  pRxCharacteristic->setCallbacks(new MyCallbacks());

  // BLE 서비스 시작
  pService->start();

  // BLE 광고 시작
  pServer->getAdvertising()->start();
  Serial.println("Waiting for client connection...");
}

void loop() {
  // 블루투스 연결이 유지된 상태에서만 데이터를 처리
  if (deviceConnected) {
    // 예: 10초마다 센서 데이터 전송 (필요에 따라 반복 데이터 전송)
    delay(10000);
  }
}
