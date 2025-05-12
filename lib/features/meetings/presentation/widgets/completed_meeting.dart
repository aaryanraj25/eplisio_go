import 'package:eplisio_go/features/meetings/presentation/widgets/completed_meeting_card.dart';
import 'package:eplisio_go/features/meetings/presentation/widgets/date_range_field.dart';
import 'package:eplisio_go/features/meetings/presentation/widgets/meeting_filter_sheet.dart';
import 'package:eplisio_go/features/meetings/presentation/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eplisio_go/features/meetings/presentation/controller/meeting_controller.dart';

class CompletedMeetingsTab extends GetView<MeetingsController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DateRangeField(
                      startDate: controller.filterStartDate.value,
                      endDate: controller.filterEndDate.value,
                      onChanged: (start, end) {
                        controller.filterStartDate.value = start;
                        controller.filterEndDate.value = end;
                        controller.fetchCompletedMeetings();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => _showFilterBottomSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SearchField(
                onChanged: (value) {
                  controller.searchQuery.value = value;
                  controller.fetchCompletedMeetings();
                },
              ),
            ],
          ),
        ),

        // Meetings List
        Expanded(
          child: Obx(() {
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
                      onPressed: controller.fetchCompletedMeetings,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (controller.completedMeetings.isEmpty) {
              return const Center(
                child: Text('No completed meetings found'),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.fetchCompletedMeetings,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.completedMeetings.length,
                itemBuilder: (context, index) {
                  final meeting = controller.completedMeetings[index];
                  return CompletedMeetingCard(meeting: meeting);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MeetingFiltersSheet(),
    );
  }
}