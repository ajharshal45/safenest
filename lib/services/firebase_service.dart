import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LogEntry {
  final String message;
  final DateTime timestamp;
  final String colorType; // 'red', 'green', 'yellow', 'blue'

  LogEntry({required this.message, required this.timestamp, required this.colorType});
}

class FirebaseService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Realtime Database Values
  int _gas = 0;
  bool _pir1 = false;
  bool _pir2 = false;
  bool _door = false;
  bool _gasAlert = false;
  bool _securityAlert = false;
  bool _lockCommand = false;
  String _lockStatus = "LOCKED";
  int _light = 0;
  int _motor = 0;
  bool _lightStatus = false;
  bool _motorStatus = false;
  
  // Getters
  int get gas => _gas;
  bool get pir1 => _pir1;
  bool get pir2 => _pir2;
  bool get door => _door;
  bool get gasAlert => _gasAlert;
  bool get securityAlert => _securityAlert;
  bool get lockCommand => _lockCommand;
  String get lockStatus => _lockStatus;
  int get light => _light;
  int get motor => _motor;
  bool get lightStatus => _lightStatus;
  bool get motorStatus => _motorStatus;
  
  // Historical data for charts
  List<int> gasHistory = [];
  
  // Activity Log
  List<LogEntry> activityLog = [];

  // Auto-relock timer
  Timer? _relockTimer;
  int _relockCountdown = 0;
  int get relockCountdown => _relockCountdown;

  FirebaseService() {
    _init();
  }

  Future<void> _init() async {
    try {
      _initNotifications();
      await _auth.signInWithEmailAndPassword(
          email: "test@test.com", password: "12345678");
      
      _db.databaseURL = "https://safenest-6ae41-default-rtdb.asia-southeast1.firebasedatabase.app/";
      
      _setupListeners();
      _setupConnectionListener();
    } catch (e) {
      debugPrint("Firebase Init Error: $e");
    }
  }

  void _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = 
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(settings: initializationSettings);
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = 
        AndroidNotificationDetails(
          'safenest_alerts', 'SafeNest Alerts',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );
    const NotificationDetails platformChannelSpecifics = 
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _notificationsPlugin.show(
      id: DateTime.now().millisecond, 
      title: title, 
      body: body, 
      notificationDetails: platformChannelSpecifics,
    );
  }

  void _setupConnectionListener() {
    _db.ref(".info/connected").onValue.listen((event) {
      final connected = event.snapshot.value as bool? ?? false;
      _isConnected = connected;
      notifyListeners();
    });
  }

  void _addLog(String message, String colorType) {
    activityLog.insert(0, LogEntry(
      message: message,
      timestamp: DateTime.now(),
      colorType: colorType,
    ));
    if (activityLog.length > 50) {
      activityLog.removeLast();
    }
    notifyListeners();
  }

  bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value.toInt() == 1;
    if (value is String) return value.toLowerCase() == "true" || value == "1";
    return false;
  }

  void _setupListeners() {
    final ref = _db.ref("SafeNest");
    
    ref.child("gas").onValue.listen((event) {
      final val = (event.snapshot.value as num?)?.toInt() ?? 0;
      if (val >= 2500 && _gas < 2500) {
        _addLog("Gas crossed threshold: $val", "red");
        _showNotification("⚠️ Gas Alert", "Dangerous gas levels detected: $val ppm");
      }
      _gas = val;
      gasHistory.add(_gas);
      if (gasHistory.length > 12) {
        gasHistory.removeAt(0);
      }
      notifyListeners();
    });

    ref.child("pir1").onValue.listen((event) {
      final val = _toBool(event.snapshot.value);
      if (val && !_pir1) {
        _showNotification("🏠 Motion Detected", "Movement sensed by PIR Sensor 1");
      }
      _pir1 = val;
      notifyListeners();
    });

    ref.child("pir2").onValue.listen((event) {
      final val = _toBool(event.snapshot.value);
      if (val && !_pir2) {
        _showNotification("🏠 Motion Detected", "Movement sensed by PIR Sensor 2");
      }
      _pir2 = val;
      notifyListeners();
    });

    ref.child("door").onValue.listen((event) {
      _door = _toBool(event.snapshot.value);
      notifyListeners();
    });
    
    ref.child("gasAlert").onValue.listen((event) {
      final val = _toBool(event.snapshot.value);
      if (val && !_gasAlert) {
        _showNotification("⚠️ Gas Critical", "Gas alert active!");
      }
      _gasAlert = val;
      notifyListeners();
    });

    ref.child("securityAlert").onValue.listen((event) {
      final val = _toBool(event.snapshot.value);
      if (val && !_securityAlert) {
        _showNotification("🛡️ Security Alert", "Security breach detected!");
      }
      _securityAlert = val;
      notifyListeners();
    });
    
    ref.child("lockCommand").onValue.listen((event) {
      final val = _toBool(event.snapshot.value);
      if (_lockCommand != val) {
        _lockCommand = val;
        _addLog("Lock state changed to: ${val ? 'UNLOCKED' : 'LOCKED'}", val ? "yellow" : "green");
        
        if (_lockCommand) {
          _startRelockTimer();
        } else {
          _cancelRelockTimer();
        }
        notifyListeners();
      }
    });

    ref.child("lockStatus").onValue.listen((event) {
      _lockStatus = event.snapshot.value as String? ?? "LOCKED";
      notifyListeners();
    });

    ref.child("light").onValue.listen((event) {
      _light = (event.snapshot.value as num?)?.toInt() ?? 0;
      notifyListeners();
    });

    ref.child("motor").onValue.listen((event) {
      _motor = (event.snapshot.value as num?)?.toInt() ?? 0;
      notifyListeners();
    });
    
    ref.child("lightStatus").onValue.listen((event) {
       final val = _toBool(event.snapshot.value);
       if (_lightStatus != val) {
         _lightStatus = val;
         _addLog("Light toggled ${_lightStatus ? 'ON' : 'OFF'}", "blue");
         notifyListeners();
       }
    });
    
    ref.child("motorStatus").onValue.listen((event) {
       final val = _toBool(event.snapshot.value);
       if (_motorStatus != val) {
         _motorStatus = val;
         _addLog("DC Motor toggled ${_motorStatus ? 'ON' : 'OFF'}", "blue");
         notifyListeners();
       }
    });
  }



  void _startRelockTimer() {
    _cancelRelockTimer();
    _relockCountdown = 20;
    notifyListeners();
    
    _relockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_relockCountdown > 0) {
        _relockCountdown--;
        notifyListeners();
      } else {
        _cancelRelockTimer();
        setLock(false); // Auto-relock
        _addLog("Auto-relocked after 20s", "yellow");
      }
    });
  }

  void _cancelRelockTimer() {
    _relockTimer?.cancel();
    _relockTimer = null;
    _relockCountdown = 0;
  }

  // Write Methods
  Future<void> setLock(bool unlock) async {
    _lockCommand = unlock;
    notifyListeners();
    await _db.ref("SafeNest/lockCommand").set(unlock);
  }

  Future<void> setLight(int val) async {
    _lightStatus = val == 1;
    notifyListeners();
    await _db.ref("SafeNest/light").set(val);
  }

  Future<void> setMotor(int val) async {
    _motorStatus = val == 1;
    notifyListeners();
    await _db.ref("SafeNest/motor").set(val);
  }
}
