import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class CrimeMapPage extends StatefulWidget {
  @override
  _CrimeMapPageState createState() => _CrimeMapPageState();
}

class _CrimeMapPageState extends State<CrimeMapPage> {
  List<dynamic> crimeData = [];
  Set<Marker> _markers = {};
  LatLng? _userLocation;
  String _userRiskLevel = "Safe Zone";

  @override
  void initState() {
    super.initState();
    _loadData();
    _getUserLocation();
  }

  Future<void> _loadData() async {
    String jsonString = await rootBundle.loadString('assets/crime.json');
    List<dynamic> data = jsonDecode(jsonString);

    for (var entry in data) {
      entry['risk_level'] = _categorizeRisk(entry['total_crimes'].toInt());
    }

    setState(() {
      crimeData = data;
      _addMarkers(crimeData);
    });
  }

  String _categorizeRisk(int totalCrimes) {
    if (totalCrimes > 5000) {
      return 'Extremely Risky';
    } else if (totalCrimes > 1000) {
      return 'High Risk';
    } else if (totalCrimes > 500) {
      return 'Medium Risk';
    } else {
      return 'Low Risk';
    }
  }

  void _addMarkers(List<dynamic> crimeData) {
    for (var entry in crimeData) {
      _markers.add(
        Marker(
          point: LatLng(entry['Latitude'], entry['Longitude']),
          width: 40.0,
          height: 40.0,
          child: Icon(
            Icons.location_on,
            color: _getMarkerColor(entry['risk_level']),
            size: 40,
          ),
        ),
      );
    }
  }

  Color _getMarkerColor(String riskLevel) {
    switch (riskLevel) {
      case 'Extremely Risky':
        return Colors.purple;
      case 'High Risk':
        return Colors.red;
      case 'Medium Risk':
        return Colors.orange;
      case 'Low Risk':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
      _checkRiskLevel();
    });
  }

  void _checkRiskLevel() {
    if (_userLocation == null || crimeData.isEmpty) return;

    double alertRadius = 5000; 
    String riskZone = "Safe Zone";

    for (var entry in crimeData) {
      double distance = Geolocator.distanceBetween(
        _userLocation!.latitude,
        _userLocation!.longitude,
        entry['Latitude'],
        entry['Longitude'],
      );

      if (distance <= alertRadius) {
        if (entry['risk_level'] == 'Extremely Risky') {
          riskZone = "Extremely Risky Zone";
          break;
        } else if (entry['risk_level'] == 'High Risk') {
          riskZone = "High Risk Zone";
        } else if (entry['risk_level'] == 'Medium Risk') {
          riskZone = "Medium Risk Zone";
        } else if (entry['risk_level'] == 'Low Risk') {
          riskZone = "Low Risk Zone";
        }
      }
    }

    setState(() {
      _userRiskLevel = riskZone;
    });

    _showAlert(riskZone);
  }

  void _showAlert(String riskZone) {
    String message = (riskZone == "Safe Zone")
        ? "You are in a Safe Zone."
        : "Warning: You are in a $riskZone! Stay alert.";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Safety Alert"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crime Map"),
        backgroundColor: const Color.fromRGBO(255, 33, 117, 1),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _userLocation ?? const LatLng(20.5937, 78.9629),
              initialZoom: 5.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              MarkerLayer(markers: _markers.toList()),
            ],
          ),

          /// **🔹 Risk Level Indicator**
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, color: _getMarkerColor(_userRiskLevel)),
                  const SizedBox(width: 10),
                  Text(
                    "Zone: $_userRiskLevel",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getMarkerColor(_userRiskLevel),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// **🔹 Legend (Explains the Colors)**
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem("Extremely Risky", Colors.purple),
                  _buildLegendItem("High Risk", Colors.red),
                  _buildLegendItem("Medium Risk", Colors.orange),
                  _buildLegendItem("Low Risk", Colors.green),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// **🔹 Helper Function for Legend Items**
  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
