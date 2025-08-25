import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ktnsolutions/models/case_model.dart';
import 'package:ktnsolutions/services/case_service.dart';

class AddEditEventScreen extends StatefulWidget {
  final String caseId;
  final CaseEvent? event;
  
  const AddEditEventScreen({
    super.key, 
    required this.caseId,
    this.event,
  });

  @override
  State<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caseService = CaseService();
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  EventType _selectedEventType = EventType.general;
  DateTime _eventDate = DateTime.now();
  TimeOfDay _eventTime = TimeOfDay.now();
  
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.event != null;
    
    if (_isEditMode) {
      final event = widget.event!;
      _titleController.text = event.title;
      _descriptionController.text = event.description ?? '';
      _selectedEventType = event.eventType;
      _eventDate = event.eventDate;
      _eventTime = TimeOfDay.fromDateTime(event.eventDate);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() => _eventDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _eventTime,
    );
    
    if (picked != null) {
      setState(() => _eventTime = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final eventDateTime = DateTime(
        _eventDate.year,
        _eventDate.month,
        _eventDate.day,
        _eventTime.hour,
        _eventTime.minute,
      );
      
      final event = CaseEvent(
        id: widget.event?.id ?? '',
        caseId: widget.caseId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : "",
        eventType: _selectedEventType,
        eventDate: eventDateTime,
        createdAt: widget.event?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      if (_isEditMode) {
        await _caseService.updateCaseEvent(event);
      } else {
        await _caseService.addCaseEvent(event);
      }
      
      if (mounted) {
        Get.back(result: true);
      }
    } catch (e) {
      debugPrint('Error saving event: $e');
      if (mounted) {
        Get.snackbar('Error', 'Failed to save event');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? 'Edit Event' : 'Add New Event'),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _submitForm,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Event Type
                      DropdownButtonFormField<EventType>(
                        value: _selectedEventType,
                        decoration: const InputDecoration(
                          labelText: 'Event Type *',
                          border: OutlineInputBorder(),
                        ),
                        items: EventType.values.map((type) {
                          return DropdownMenuItem<EventType>(
                            value: type,
                            child: Text(
                              type.toString().split('.').last,
                              style: TextStyle(
                                color: _getEventColor(type),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedEventType = value);
                          }
                        },
                        validator: (value) {
                          if (value == null) return 'Please select an event type';
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Event Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(),
                          hintText: 'E.g., First Hearing, Document Submission',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Date & Time
                      const Text(
                        'Date & Time *',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectDate,
                              icon: const Icon(Icons.calendar_today),
                              label: Text(_formatDate(_eventDate)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                alignment: Alignment.centerLeft,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectTime,
                              icon: const Icon(Icons.access_time),
                              label: Text(_formatTime(_eventTime)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                alignment: Alignment.centerLeft,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          hintText: 'Add any additional details about this event',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Save Button
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(_isEditMode ? 'Update Event' : 'Add Event'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
  
  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a').format(dateTime);
  }
  
  Color _getEventColor(EventType eventType) {
    switch (eventType) {
      case EventType.hearing:
        return Colors.blue;
      case EventType.filing:
        return Colors.green;
      case EventType.deadline:
        return Colors.orange;
      case EventType.general:
        return Colors.purple;
      case EventType.other:
        return Colors.grey;
    }
  }
}
