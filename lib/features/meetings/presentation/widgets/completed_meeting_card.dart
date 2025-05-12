import 'package:eplisio_go/features/meetings/data/model/meeting_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompletedMeetingCard extends StatelessWidget {
  final MeetingModel meeting;

  const CompletedMeetingCard({
    Key? key,
    required this.meeting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    meeting.clinicName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(meeting.meetingType),
              ],
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

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check-in',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        DateFormat('MMM dd • hh:mm a').format(meeting.checkInTime),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check-out',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        DateFormat('MMM dd • hh:mm a').format(meeting.checkOutTime!),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (meeting.notes?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${meeting.notes}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(MeetingType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type == MeetingType.firstMeeting ? 'First Meeting' : 'Follow-up',
        style: const TextStyle(
          color: Colors.purple,
          fontSize: 12,
        ),
      ),
    );
  }
}