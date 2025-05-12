import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeField extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?) onChanged;

  const DateRangeField({
    Key? key,
    this.startDate,
    this.endDate,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDateRangePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getDisplayText(),
                style: TextStyle(
                  color: startDate == null ? Colors.grey[600] : Colors.black,
                ),
              ),
            ),
            if (startDate != null || endDate != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () => onChanged(null, null),
              ),
          ],
        ),
      ),
    );
  }

  String _getDisplayText() {
    if (startDate == null && endDate == null) {
      return 'Select date range';
    }

    final dateFormat = DateFormat('MMM dd, yyyy');
    if (startDate == endDate) {
      return dateFormat.format(startDate!);
    }

    return '${dateFormat.format(startDate!)} - ${dateFormat.format(endDate!)}';
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.purple,
              onPrimary: Colors.white,
              surface: Colors.purple,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onChanged(picked.start, picked.end);
    }
  }
}