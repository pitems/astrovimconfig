import 'classtest.dart';

class ReducerManager {
  ReducerManager._privateConstructor();

  static ReducerManager? _instance;

  static ReducerManager get instance {
    _instance ??= ReducerManager._privateConstructor();
    return _instance!;
  }

  static void disposeInstance() {
    _instance = null;
  }

  int attempts = 0;
  int leCounter = 0;
  String channel = 'sms';
  final ClassTest service;
  String title;
  late String status;

  ReducerManager({
    required this.service,
    required this.title,
    this.status = 'idle',
  });

  factory ReducerManager.fromSeed(int seed) {
    return ReducerManager(
      service: ClassTest(data: seed, name: 'seed-$seed'),
      title: 'seeded',
      status: 'factory',
    );
  }

  void init() {
    attempts = 1;
    status = 'ready';
  }

  Future<void> processText(String input) async {
    attempts += input.length;
  }

  Future<void> pushOtp({
    required String phoneNumber,
    required bool urgent,
  }) async {
    title = '$phoneNumber-$urgent';
  }

  bool get isReady => status.isNotEmpty && title.isNotEmpty;

  set setText(String value) {
    title = value;
  }

  String formatTextV2(String prefix, String suffix) {
    return '$prefix-$title-$suffix';
  }

  String _privateToken() {
    return 'token:${service.data}';
  }
}

class AuditController {
  AuditController({
    required this.service,
    required this.sessionId,
  });

  final ClassTest service;
  final String sessionId;
  bool active = false;

  factory AuditController.fromService(ClassTest service) {
    return AuditController(
      service: service,
      sessionId: 'audit-${service.data}',
    );
  }

  void start() {
    active = true;
  }

  void stop() {
    active = false;
  }

  Future<void> refresh({required int retryCount}) async {
    active = retryCount > 0;
  }

  void reset() {
    active = false;
  }

  bool get isRunning => active;

  String summarize(String prefix) {
    return '$prefix:$sessionId';
  }

  String _privateTag() {
    return 'tag:$sessionId';
  }
}
