import 'package:eplisio_go/features/meetings/presentation/widgets/active_meeting_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eplisio_go/features/meetings/presentation/controller/meeting_controller.dart';

class ActiveMeetingsTab extends GetView<MeetingsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error.value != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.error.value!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.checkActiveMeeting,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (controller.activeMeeting.value == null) {
        return const Center(
          child: Text('No active meetings'),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ActiveMeetingCard(
          meeting: controller.activeMeeting.value!,
          onCheckout: () => Get.toNamed('/meetings/checkout'),
        ),
      );
    });
  }
}