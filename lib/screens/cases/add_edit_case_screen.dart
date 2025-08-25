import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ktnsolutions/models/case_model.dart';
import 'package:ktnsolutions/services/case_service.dart';

class AddEditCaseScreen extends StatefulWidget {
  final LegalCase? legalCase;

  const AddEditCaseScreen({
    super.key,
    this.legalCase,
  });

  @override
  State<AddEditCaseScreen> createState() => _AddEditCaseScreenState();
}

class _AddEditCaseScreenState extends State<AddEditCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caseService = CaseService();
  
  final _titleController = TextEditingController();
  final _caseNumberController = TextEditingController();
  final _courtNameController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientContactController = TextEditingController();
  final _advocateNameController = TextEditingController();
  final _advocateContactController = TextEditingController();
  final _notesController = TextEditingController();
  
  CaseStatus _selectedStatus = CaseStatus.pending;
  DateTime? _nextHearingDate;
  TimeOfDay? _nextHearingTime;
  
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.legalCase != null;
    
    if (_isEditMode) {
      final legalCase = widget.legalCase!;
      _titleController.text = legalCase.title;
      _caseNumberController.text = legalCase.caseNumber;
      _courtNameController.text = legalCase.courtName;
      _clientNameController.text = legalCase.clientName;
      _clientContactController.text = legalCase.clientContact;
      _advocateNameController.text = legalCase.advocateName;
      _advocateContactController.text = legalCase.advocateContact ?? '';
      _notesController.text = legalCase.notes ?? '';
      _selectedStatus = legalCase.status;
      _nextHearingDate = legalCase.nextHearingDate;
      if (_nextHearingDate != null) {
        _nextHearingTime = TimeOfDay.fromDateTime(_nextHearingDate!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _caseNumberController.dispose();
    _courtNameController.dispose();
    _clientNameController.dispose();
    _clientContactController.dispose();
    _advocateNameController.dispose();
    _advocateContactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextHearingDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        _nextHearingDate = picked;
        // If time is not set, set a default time
        _nextHearingTime ??= const TimeOfDay(hour: 10, minute: 0);
      });
    }
  }

  Future<void> _selectTime() async {
    if (_nextHearingDate == null) {
      await _selectDate();
      if (_nextHearingDate == null) return;
    }
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _nextHearingTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    
    if (picked != null) {
      setState(() {
        _nextHearingTime = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${_getDayName(date.weekday)}, ${date.day} ${_getMonthName(date.month)} ${date.year}';
  }
  
  String _formatTime(TimeOfDay time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour < 12 ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
  
  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
  
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      DateTime? nextHearingDateTime;
      if (_nextHearingDate != null && _nextHearingTime != null) {
        nextHearingDateTime = DateTime(
          _nextHearingDate!.year,
          _nextHearingDate!.month,
          _nextHearingDate!.day,
          _nextHearingTime!.hour,
          _nextHearingTime!.minute,
        );
      }
      
      final legalCase = LegalCase(
        id: widget.legalCase?.id ?? '',
        caseNumber: _caseNumberController.text.trim(),
        title: _titleController.text.trim(),
        courtName: _courtNameController.text.trim(),
        clientName: _clientNameController.text.trim(),
        clientContact: _clientContactController.text.trim(),
        advocateName: _advocateNameController.text.trim(),
        advocateContact: _advocateContactController.text.trim().isNotEmpty
            ? _advocateContactController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        status: _selectedStatus,
        nextHearingDate: nextHearingDateTime,
        createdBy: widget.legalCase?.createdBy,
        createdAt: widget.legalCase?.createdAt,
        updatedAt: DateTime.now(),
      );
      
      if (_isEditMode) {
        await _caseService.updateCase(legalCase);
      } else {
        await _caseService.addCase(legalCase);
      }
      
      if (mounted) {
        Get.back(result: true);
      }
    } catch (e) {
      debugPrint('Error saving case: $e');
      Get.snackbar('Error', 'Failed to save case');
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
          title: Text(_isEditMode ? 'Edit Case' : 'Add New Case'),
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
                      // Case Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Case Title *',
                          border: OutlineInputBorder(),
                          hintText: 'E.g., Smith vs. Johnson',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a case title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Case Number
                      TextFormField(
                        controller: _caseNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Case Number *',
                          border: OutlineInputBorder(),
                          hintText: 'E.g., CR-2023-1234',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a case number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Court Name
                      TextFormField(
                        controller: _courtNameController,
                        decoration: const InputDecoration(
                          labelText: 'Court Name *',
                          border: OutlineInputBorder(),
                          hintText: 'E.g., Supreme Court of India',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a court name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Client Details
                      const Text(
                        'Client Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      TextFormField(
                        controller: _clientNameController,
                        decoration: const InputDecoration(
                          labelText: 'Client Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter client name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      
                      TextFormField(
                        controller: _clientContactController,
                        decoration: const InputDecoration(
                          labelText: 'Client Contact *',
                          border: OutlineInputBorder(),
                          hintText: 'Phone number or email',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter client contact';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Advocate Details
                      const Text(
                        'Advocate Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      TextFormField(
                        controller: _advocateNameController,
                        decoration: const InputDecoration(
                          labelText: 'Advocate Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter advocate name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      
                      TextFormField(
                        controller: _advocateContactController,
                        decoration: const InputDecoration(
                          labelText: 'Advocate Contact',
                          border: OutlineInputBorder(),
                          hintText: 'Phone number or email (optional)',
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      
                      // Next Hearing Date & Time
                      const Text(
                        'Next Hearing',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectDate,
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                _nextHearingDate != null
                                    ? _formatDate(_nextHearingDate!)
                                    : 'Select Date',
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                alignment: Alignment.centerLeft,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _nextHearingDate != null ? _selectTime : null,
                              icon: const Icon(Icons.access_time),
                              label: Text(
                                _nextHearingTime != null
                                    ? _formatTime(_nextHearingTime!)
                                    : 'Select Time',
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                alignment: Alignment.centerLeft,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Status
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      DropdownButtonFormField<CaseStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: CaseStatus.values.map((status) {
                          return DropdownMenuItem<CaseStatus>(
                            value: status,
                            child: Text(
                              status.toString().split('.').last,
                              style: TextStyle(
                                color: _getStatusColor(status),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                          hintText: 'Additional notes about the case',
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
                            : Text(_isEditMode ? 'Update Case' : 'Add Case'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
  
  Color _getStatusColor(CaseStatus status) {
    switch (status) {
      case CaseStatus.pending:
        return Colors.orange;
      case CaseStatus.inProgress:
        return Colors.blue;
      case CaseStatus.completed:
        return Colors.green;
      case CaseStatus.adjourned:
        return Colors.purple;
      case CaseStatus.dismissed:
        return Colors.red;
    }
  }
}
