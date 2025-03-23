import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyService {
  static const String _textBeeApiKey = "";
  static const String _textBeeSender = "";
  static const String _contactNumber = ""; // Replace with recipient's number
  static const String _apiUrl = "https://api.textbee.dev/api/v1/gateway/devices";

  EmergencyService() {
    _checkAndSendStoredMessages();
  }

  Future<void> handleEmergency() async {
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition();
    } catch (e) {
      print("❌ Error fetching location: $e");
      return;
    }

    final String message =
        "🚨 SOS! I need help! Location: https://www.google.com/maps?q=${position.latitude},${position.longitude}";

    final ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      await _sendMessage(message);
    } else {
      await _storeMessageLocally(message);
    }
  }

  Future<void> _sendMessage(String message) async {
    final Uri url = Uri.parse("$_apiUrl/$_textBeeSender/send-sms");

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "x-api-key": _textBeeApiKey,
    };

    final Map<String, dynamic> body = {
      "recipients": [_contactNumber],
      "message": message,
    };

    try {
      final http.Response response = await http
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);
      print("📩 TextBee Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 && responseData['status'] == "sent") {
        print("✅ SMS sent successfully.");
      } else {
        print("⚠️ SMS not sent: ${responseData['status']}");
      }
    } on SocketException {
      print("🚨 Network error: Unable to reach TextBee.");
    } on TimeoutException {
      print("⏳ Timeout: TextBee API is taking too long to respond.");
    } catch (e) {
      print("🚨 Unexpected error sending SMS: $e");
    }
  }

  Future<void> _storeMessageLocally(String message) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? storedMessages = prefs.getStringList('sos_messages');
    final List<String> updatedMessages = storedMessages ?? [];
    updatedMessages.add(message);
    await prefs.setStringList('sos_messages', updatedMessages);
    print("📝 SOS alert stored. Will send when network is available.");
  }

  Future<void> _checkAndSendStoredMessages() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final List<String>? storedMessages = prefs.getStringList('sos_messages');

  if (storedMessages != null && storedMessages.isNotEmpty) {
    final ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      for (final message in storedMessages) {
        await _sendMessage(message); // Try to send the stored messages
      }
      await prefs.remove('sos_messages'); // Clear messages after sending
      print("📤 Stored SOS alerts sent.");
    } else {
      print("📴 Still offline. Messages remain stored.");
    }
  }
}

// Auto-check network status and send stored messages when back online
void monitorNetworkChanges() {
  Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      _checkAndSendStoredMessages(); // Try sending stored messages when back online
    }
  });
}
}