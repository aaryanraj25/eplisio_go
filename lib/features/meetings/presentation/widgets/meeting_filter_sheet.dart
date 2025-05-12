import 'package:eplisio_go/features/meetings/presentation/controller/meeting_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MeetingFiltersSheet extends GetView<MeetingsController> {
  const MeetingFiltersSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  controller.resetFilters();
                  Navigator.pop(context);
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Meeting Type Filter
          const Text(
            'Meeting Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                label: 'First Meeting',
                selected: controller.filterMeetingType.value == 'first_meeting',
                onSelected: (selected) {
                  controller.filterMeetingType.value = 
                      selected ? 'first_meeting' : null;
                  controller.fetchCompletedMeetings();
                },
              ),
              _buildFilterChip(
                label: 'Follow Up',
                selected: controller.filterMeetingType.value == 'follow_up',
                onSelected: (selected) {
                  controller.filterMeetingType.value = 
                      selected ? 'follow_up' : null;
                  controller.fetchCompletedMeetings();
                },
              ),
              _buildFilterChip(
                label: 'Other',
                selected: controller.filterMeetingType.value == 'other',
                onSelected: (selected) {
                  controller.filterMeetingType.value = 
                      selected ? 'other' : null;
                  controller.fetchCompletedMeetings();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Add more filters here as needed
          // For example: Clinic filter, Client filter, etc.

          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              controller.fetchCompletedMeetings();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Colors.purple.withOpacity(0.2),
      checkmarkColor: Colors.purple,
    );
  }
}