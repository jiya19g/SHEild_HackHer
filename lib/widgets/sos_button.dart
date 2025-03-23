import 'package:flutter/material.dart';
import 'package:title_proj/services/emergency_service.dart';

class SOSButton extends StatefulWidget {
  final Future<void> Function()? onPressed;

  const SOSButton({super.key, this.onPressed});

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> {
  bool _isSending = false;
  final EmergencyService _emergencyService = EmergencyService();

  void _sendSOS() async {
    if (!mounted) return; 
    setState(() => _isSending = true);

    try {
      await _emergencyService.handleEmergency();
    } finally {
      if (mounted) { 
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isSending ? null : _sendSOS,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // ✅ Same border radius
        ),
        child: Container(
          height: 160, // ✅ Same height
          width: MediaQuery.of(context).size.width * 0.7, // ✅ Same width
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(216, 68, 68, 1), // Red gradient
                Color.fromRGBO(248, 7, 7, 1),
              ],
            ),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white.withOpacity(0.5),
                child: const Icon(Icons.warning, size: 30, color: Colors.red),
              ),
              const SizedBox(height: 10),
              Text(
                'SOS Emergency',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.06,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to Send SOS Alert',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                ),
              ),
              const Spacer(),
              Container(
                height: 30,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: _isSending
                      ? const CircularProgressIndicator(color: Colors.red)
                      : Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.red[300],
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.055,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
