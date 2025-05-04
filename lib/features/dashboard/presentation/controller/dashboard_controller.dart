import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final _currentIndex = 0.obs;
  final _pageController = PageController().obs;

  int get currentIndex => _currentIndex.value;
  PageController get pageController => _pageController.value;

  @override
  void onInit() {
    super.onInit();
    _pageController.value = PageController(initialPage: 0);
  }

  @override
  void onClose() {
    _pageController.value.dispose();
    super.onClose();
  }

  void changePage(int index) {
    _currentIndex.value = index;
    _pageController.value.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}