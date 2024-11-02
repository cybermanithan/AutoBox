#include <ESP8266WiFi.h>  // Use ESP8266WiFi library for ESP8266
#include <Firebase_ESP_Client.h>
#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>

// Wi-Fi credentials
#define WIFI_SSID "Redmi9C"
#define WIFI_PASSWORD "12345678"

// Firebase credentials
#define FIREBASE_HOST "autobox-fc474-default-rtdb.firebaseio.com"
#define API_KEY "AIzaSyBlg1d47902af9Q7sEN9Frq3_lhU0eSAxs"
#define USER_EMAIL "emdrail@gmail.com"
#define USER_PASSWORD "#kumar1234"  // Replace with your actual Firebase password

// Firebase Data object
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

const int lightPin = D1;  // D1 on ESP8266 corresponds to GPIO5
const int fanpin = D2;
const int rey1 = D3;
const int rey2 = D4;
void setup() {
  Serial.begin(115200);

  // Connect to Wi-Fi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(50);
    Serial.print(".");
  }
  Serial.println(" connected!");

  // Configure Firebase credentials and URL
  config.api_key = API_KEY;
  config.database_url = "https://" FIREBASE_HOST;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  // Callback for Firebase token generation
  config.token_status_callback = tokenStatusCallback;
  
  // Initialize Firebase with credentials
  Firebase.begin(&config, &auth);

  // Set up the light pin as output and ensure it’s off initially
  pinMode(lightPin, OUTPUT);
  digitalWrite(lightPin, HIGH);
  pinMode(fanpin,OUTPUT);
  digitalWrite(fanpin,HIGH);
  pinMode(rey1, OUTPUT);
  digitalWrite(rey1, HIGH);
  pinMode(rey2,OUTPUT);
  digitalWrite(rey2,HIGH);  // Turn off the light initially
}

void loop() {
  if (Firebase.ready()) {
    // Retrieve the boolean value at /Light/Switch
    if (Firebase.RTDB.getBool(&fbdo, "/devices/light")) {
      bool lightStatus = fbdo.boolData();
      digitalWrite(lightPin, lightStatus ? LOW : HIGH);  // Set pin state based on Firebase value
      Serial.print("Light is now ");
      Serial.println(lightStatus ? "OFF" : "ON");
    }
    if (Firebase.RTDB.getBool(&fbdo, "/devices/fan")) {
      bool lightStatus = fbdo.boolData();
      digitalWrite(fanpin, lightStatus ? LOW : HIGH);  // Set pin state based on Firebase value
      Serial.print("Fan is now ");
      Serial.println(lightStatus ? "OFF" : "ON");
    } 

    if (Firebase.RTDB.getBool(&fbdo, "/devices/relay1")) {
      bool lightStatus = fbdo.boolData();
      digitalWrite(rey1, lightStatus ? LOW : HIGH);  // Set pin state based on Firebase value
      Serial.print("rey1 is now ");
      Serial.println(lightStatus ? "OFF" : "ON");
    }
    if (Firebase.RTDB.getBool(&fbdo, "/devices/relay2")) {
      bool lightStatus = fbdo.boolData();
      digitalWrite(rey2, lightStatus ? LOW : HIGH);  // Set pin state based on Firebase value
      Serial.print("rey2 is now ");
      Serial.println(lightStatus ? "OFF" : "ON");
    } 
     else {
      // Log any errors in retrieving data
      Serial.println("Failed to get data: " + fbdo.errorReason());
    }
  }
  delay(50); // Delay for polling Firebase (adjust as needed)
}
