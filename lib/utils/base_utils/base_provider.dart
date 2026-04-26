import 'package:flutter/widgets.dart';

class BaseProvider extends ChangeNotifier {
  int _selectedNavigationIndex = 1;
  int get selectedNavigationIndex => _selectedNavigationIndex;

  void updateNavigationIndex(int index) {
    _selectedNavigationIndex = index;
    notifyListeners();
  }
}