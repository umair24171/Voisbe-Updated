import 'package:flutter/material.dart';

class BottomProvider with ChangeNotifier {
  int currentIndex = 0;
  PageController pageController = PageController(initialPage: 1);

  setCurrentIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  // initPageController(int page) {
  //   pageController = PageController(initialPage: page);
  //   // notifyListeners();
  // }
}
