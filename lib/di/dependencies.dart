import 'package:get/get.dart';
import 'package:ktnsolutions/services/report_service.dart';

class Dependencies {
  Future<void> init() async {
    // Register services
    Get.lazyPut<ReportService>(() => ReportService(), fenix: true);
    
    // Add other dependencies here as needed
    
    // All dependencies are now initialized
    return;
  }
}
