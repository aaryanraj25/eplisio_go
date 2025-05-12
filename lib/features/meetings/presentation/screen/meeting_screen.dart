import 'package:eplisio_go/core/utils/location_services.dart';
import 'package:eplisio_go/features/meetings/presentation/controller/meeting_controller.dart';
import 'package:eplisio_go/features/meetings/presentation/widgets/active_meetings.dart';
import 'package:eplisio_go/features/meetings/presentation/widgets/completed_meeting.dart';
import 'package:eplisio_go/features/meetings/presentation/widgets/check_in_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class MeetingsScreen extends GetView<MeetingsController> {
  const MeetingsScreen({Key? key}) : super(key: key);

  Future<void> _handleCheckIn() async {
    try {
      // Check location permission and show dialog if needed
      final hasPermission = await LocationService.checkLocationPermission();
      if (!hasPermission) {
        Get.dialog(
          AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'Location permission is required to check in at clinics. '
              'Please enable location permission in settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Get.back();
                  await openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                child: const Text('Open Settings',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        return;
      }

      // Show check-in dialog
      final result = await Get.dialog(
        const CheckInDialog(),
        barrierDismissible: false,
      );

      if (result == true) {
        // Refresh meetings list on successful check-in
        await controller.checkActiveMeeting();
        Get.snackbar(
          'Success',
          'Check-in completed successfully',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      debugPrint('Error during check-in: $e');
      Get.snackbar(
        'Error',
        'Failed to complete check-in. Please try again.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meetings',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.purple,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: [
            ActiveMeetingsTab(),
            CompletedMeetingsTab(),
          ],
        ),
        floatingActionButton: Obx(
          () => controller.isLoading.value
              ? FloatingActionButton.extended(
                  onPressed: null,
                  backgroundColor: Colors.purple,
                  icon: const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  label: const Text('Loading...'),
                )
              : FloatingActionButton.extended(
                  onPressed: _handleCheckIn,
                  backgroundColor: Colors.purple,
                  icon: const Icon(Icons.add),
                  label: const Text('Check In'),
                ),
        ),
      ),
    );
  }
}
