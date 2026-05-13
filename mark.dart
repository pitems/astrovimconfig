import 'classtest.dart';

class SampleController {
  SampleController._internal();

  static SampleController? _instance;

  static SampleController get instance {
    _instance ??= SampleController._internal();
    return _instance!;
  }

  static void disposeInstance() {
    _instance = null;
  }

  int leCounter = 0;
  final ClassTest service;

  SampleController({required this.service});

  void increment() {
    leCounter += 1;
  }

  Future<void> refresh() async {
    leCounter = service.data;
  }

  int readCounter() {
    return leCounter;
  }
}
