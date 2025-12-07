import 'package:get/get.dart';

class MainController extends GetxController {
  // Default to 1 (Record Page) to be in the center
  RxInt currentIndex = 1.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }
}
