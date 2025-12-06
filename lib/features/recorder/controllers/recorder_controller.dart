import 'package:get/get.dart';

class RecorderController extends GetxController {
  RxString duration = "00:01:50".obs;
  RxString recordName = "Record 1".obs;
  RxString recordInfo = "2.1 MB, M4a,44.1KHz".obs;
  RxBool isRecording = true.obs;
}
