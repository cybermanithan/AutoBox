import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBlg1d47902af9Q7sEN9Frq3_lhU0eSAxs', // Get this from google-services.json
      appId: '1:344472693978:android:7754f4a057ee7a68e649e3', // Get this from google-services.json
      messagingSenderId: 'YOUR-SENDER-ID', // Get this from google-services.json
      projectId: 'autobox-fc474', // Get this from google-services.json
      databaseURL: 'https://autobox-fc474-default-rtdb.firebaseio.com', // Get this from Firebase Console
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Control Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  bool _isLoading = true;
  String _error = '';
  
  bool lightState = false;
  bool fanState = false;
  bool relay1State = false;
  bool relay2State = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      _database.child('devices').onValue.listen((event) {
        if (event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            lightState = data['light'] ?? false;
            fanState = data['fan'] ?? false;
            relay1State = data['relay1'] ?? false;
            relay2State = data['relay2'] ?? false;
            _isLoading = false;
          });
        } else {
          // If no data exists, create initial data
          _database.child('devices').set({
            'light': false,
            'fan': false,
            'relay1': false,
            'relay2': false,
          });
          _isLoading = false;
        }
      }, onError: (error) {
        setState(() {
          _error = 'Database Error: $error';
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        _error = 'Initialization Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateDeviceState(String device, bool state) async {
    try {
      await _database.child('devices').update({device: state});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating $device: $e')),
      );
    }
  }

  Widget _buildDeviceButton(String title, bool state, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: state ? Colors.green : Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => onChanged(!state),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(state ? Icons.power : Icons.power_off),
              const SizedBox(width: 10),
              Text(
                '$title: ${state ? 'ON' : 'OFF'}',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _error,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Control Panel'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.blue[100]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDeviceButton(
                'Light',
                lightState,
                (state) => _updateDeviceState('light', state),
              ),
              _buildDeviceButton(
                'Fan',
                fanState,
                (state) => _updateDeviceState('fan', state),
              ),
              _buildDeviceButton(
                'Relay 1',
                relay1State,
                (state) => _updateDeviceState('relay1', state),
              ),
              _buildDeviceButton(
                'Relay 2',
                relay2State,
                (state) => _updateDeviceState('relay2', state),
              ),
            ],
          ),
        ),
      ),
    );
  }
}