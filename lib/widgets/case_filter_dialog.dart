import 'package:flutter/material.dart';
import 'package:ktnsolutions/models/case_model.dart';

class CaseFilterDialog extends StatefulWidget {
  final CaseStatus? initialStatus;
  final DateTime? initialFromDate;
  final DateTime? initialToDate;
  
  const CaseFilterDialog({
    super.key,
    this.initialStatus,
    this.initialFromDate,
    this.initialToDate,
  });

  @override
  State<CaseFilterDialog> createState() => _CaseFilterDialogState();
}

class _CaseFilterDialogState extends State<CaseFilterDialog> {
  late CaseStatus? _selectedStatus;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _fromDate = widget.initialFromDate;
    _toDate = widget.initialToDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Cases'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<CaseStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Statuses'),
                ),
                ...CaseStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toString().split('.').last),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, true),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(_fromDate == null 
                        ? 'From' 
                        : _formatDate(_fromDate!)),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('to'),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, false),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(_toDate == null 
                        ? 'To' 
                        : _formatDate(_toDate!)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, {
            'status': _selectedStatus,
            'fromDate': _fromDate,
            'toDate': _toDate,
          }),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final initialDate = isFromDate 
        ? _fromDate ?? DateTime.now() 
        : _toDate ?? DateTime.now();
        
    final firstDate = isFromDate 
        ? DateTime(2000) 
        : _fromDate ?? DateTime(2000);
        
    final lastDate = isFromDate 
        ? _toDate ?? DateTime(2100) 
        : DateTime(2100);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
          if (_toDate != null && _toDate!.isBefore(picked)) {
            _toDate = picked;
          }
        } else {
          _toDate = picked;
        }
      });
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
