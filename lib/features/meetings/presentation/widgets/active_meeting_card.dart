import 'package:eplisio_go/features/meetings/data/model/meeting_model.dart';
import 'package:eplisio_go/features/meetings/presentation/widgets/check_out_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ActiveMeetingCard extends StatelessWidget {
  final MeetingModel meeting;
  final VoidCallback onCheckout;

  const ActiveMeetingCard({
    Key? key,
    required this.meeting,
    required this.onCheckout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purple.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Active Meeting',
                  style: TextStyle(
                    color: Colors.purple[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meeting.clinicName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (meeting.client != null) ...[
                  Text(
                    'Client: ${meeting.client!.name}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    '${meeting.client!.designation} • ${meeting.client!.department}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  'Check-in: ${DateFormat('MMM dd, yyyy • hh:mm a').format(meeting.checkInTime)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Get.dialog(
                      CheckoutDialog(meetingId: meeting.id),
                      barrierDismissible: false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Check Out',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
