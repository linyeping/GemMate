import 'package:flutter/material.dart';

class ConnectionStore extends ChangeNotifier {
  static final ConnectionStore _instance = ConnectionStore._();
  factory ConnectionStore() => _instance;
  ConnectionStore._();

  bool _isLaptopConnected = false;
  bool _isLocalModelAvailable = false;

  bool get isConnected => _isLaptopConnected;
  bool get isLaptopConnected => _isLaptopConnected;
  bool get isLocalModelAvailable => _isLocalModelAvailable;
  bool get hasAnyModel => _isLaptopConnected || _isLocalModelAvailable;

  void setConnected(bool value) {
    if (_isLaptopConnected != value) {
      _isLaptopConnected = value;
      notifyListeners();
    }
  }

  void setLaptopConnected(bool value) => setConnected(value);

  void setLocalModelAvailable(bool value) {
    if (_isLocalModelAvailable != value) {
      _isLocalModelAvailable = value;
      notifyListeners();
    }
  }
}
