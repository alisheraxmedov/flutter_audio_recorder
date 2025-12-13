import 'package:get/get.dart';

class TrackData {
  final int id;
  RxString filePath = "".obs;
  RxString fileName = "Empty".obs;
  RxString fileFormat = "".obs;
  RxString fileSize = "".obs;
  RxList<double> waveform = <double>[].obs;

  // Selection logic per track
  RxDouble startSelection = 0.0.obs;
  RxDouble endSelection = 1.0.obs;

  // Total duration of the file in milliseconds
  RxInt totalDurationMs = 0.obs;

  TrackData({required this.id});

  // Computed properties
  int get startMs => (startSelection.value * totalDurationMs.value).toInt();
  int get endMs => (endSelection.value * totalDurationMs.value).toInt();

  void reset() {
    filePath.value = "";
    fileName.value = "Empty";
    fileFormat.value = "";
    fileSize.value = "";
    waveform.clear();
    startSelection.value = 0.0;
    endSelection.value = 1.0;
    totalDurationMs.value = 0;
  }
}
