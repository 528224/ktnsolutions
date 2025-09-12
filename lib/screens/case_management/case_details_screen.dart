import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/models.dart';
import '../../models/court.dart';
import '../../services/case_service.dart';

class CaseDetailsScreen extends StatefulWidget {
  final LegalCase legalCase;

  const CaseDetailsScreen({
    super.key,
    required this.legalCase,
  });

  @override
  State<CaseDetailsScreen> createState() => _CaseDetailsScreenState();
}

class _CaseDetailsScreenState extends State<CaseDetailsScreen> {
  late LegalCase _currentCase;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentCase = widget.legalCase;
  }

  bool get _isAdmin {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser?.phoneNumber == null) return false;
    
    // Check if current user is admin by matching phone number
    return globalUsers.any((user) => 
        user.mobile == currentUser!.phoneNumber && user.isAdmin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentCase.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCaseHeader(),
                const SizedBox(height: 24),
                _buildNextPostingSection(context),
                const SizedBox(height: 24),
                _buildDueTasksSection(context),
                const SizedBox(height: 24),
                _buildTimelineSection(context),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCaseHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _currentCase.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_isAdmin)
                  IconButton(
                    onPressed: () => _showEditCaseDialog(),
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit Case Details',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Client: ${_currentCase.clientName}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Text(
              'Client Number: ${_currentCase.clientNumber}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.task_alt,
                  size: 16,
                  color: Colors.green[700],
                ),
                const SizedBox(width: 4),
                Text(
                  '${_currentCase.completedTasksCount}/${_currentCase.totalTasksCount} tasks completed',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextPostingSection(BuildContext context) {
    final nextPosting = _currentCase.nextPosting;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Next Posting',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                if (_isAdmin)
                  IconButton(
                    onPressed: () => _showEditNextPostingDialog(),
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit Next Posting',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (nextPosting != null) ...[
              Text(
                nextPosting.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, MMMM dd, yyyy').format(nextPosting.date),
                style: TextStyle(
                  fontSize: 14,
                  color: _getDateColor(nextPosting.date),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Court: ${nextPosting.court}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Staff: ${nextPosting.staff}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              if (nextPosting.note.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    nextPosting.note,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ] else ...[
              Text(
                'No upcoming posting scheduled',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDueTasksSection(BuildContext context) {
    final dueTasks = _currentCase.tasks.where((task) => !task.isCompleted).toList();
    final overdueTasks = dueTasks.where((task) => task.dueDate.isBefore(DateTime.now())).toList();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Due Tasks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                if (overdueTasks.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${overdueTasks.length} Overdue',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (_isAdmin)
                  IconButton(
                    onPressed: () => _showEditTasksDialog(),
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit Tasks',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (dueTasks.isEmpty) ...[
              Text(
                'No pending tasks',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ] else ...[
              ...dueTasks.map((task) => _buildTaskItem(task)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    final isOverdue = task.dueDate.isBefore(DateTime.now());
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOverdue ? Colors.red[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOverdue ? Colors.red[300]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.warning : Icons.assignment_outlined,
            color: isOverdue ? Colors.red : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isOverdue ? Colors.red[800] : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Due: ${DateFormat('MMM dd, yyyy').format(task.dueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOverdue ? Colors.red[600] : Colors.grey[600],
                  ),
                ),
                Text(
                  'Staff: ${task.staff}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(BuildContext context) {
    // Combine postings and tasks for timeline
    final List<TimelineItem> timelineItems = [];
    
    // Add previous postings
    for (final posting in _currentCase.previousPostings) {
      timelineItems.add(TimelineItem(
        type: TimelineItemType.posting,
        date: posting.date,
        title: posting.title,
        note: posting.note,
        staff: posting.staff,
        court: posting.court,
      ));
    }
    
    // Add tasks with done dates
    for (final task in _currentCase.tasks.where((task) => task.doneDate != null)) {
      timelineItems.add(TimelineItem(
        type: TimelineItemType.taskCompleted,
        date: task.doneDate!,
        title: task.title,
        staff: task.staff,
      ));
    }
    
    // Sort by date (most recent first)
    timelineItems.sort((a, b) => b.date.compareTo(a.date));
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Timeline',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (timelineItems.isEmpty) ...[
              Text(
                'No timeline items yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ] else ...[
              ...timelineItems.map((item) => _buildTimelineItem(item)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(TimelineItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getTimelineItemColor(item.type),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Timeline content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getTimelineItemIcon(item.type),
                      size: 16,
                      color: _getTimelineItemColor(item.type),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getTimelineItemTypeLabel(item.type),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getTimelineItemColor(item.type),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM dd, yyyy').format(item.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (item.staff.isNotEmpty) ...[
                  Text(
                    'Staff: ${item.staff}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                if (item.court.isNotEmpty) ...[
                  Text(
                    'Court: ${item.court}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                if (item.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.note,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDateColor(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final caseDate = DateTime(date.year, date.month, date.day);
    
    if (caseDate.isBefore(today)) {
      return Colors.red; // Overdue
    } else if (caseDate.isAtSameMomentAs(today)) {
      return Colors.orange; // Today
    } else {
      return Colors.green; // Future
    }
  }

  Color _getTimelineItemColor(TimelineItemType type) {
    switch (type) {
      case TimelineItemType.posting:
        return Colors.blue;
      case TimelineItemType.taskCompleted:
        return Colors.green;
    }
  }

  IconData _getTimelineItemIcon(TimelineItemType type) {
    switch (type) {
      case TimelineItemType.posting:
        return Icons.event;
      case TimelineItemType.taskCompleted:
        return Icons.check_circle;
    }
  }

  String _getTimelineItemTypeLabel(TimelineItemType type) {
    switch (type) {
      case TimelineItemType.posting:
        return 'POSTING';
      case TimelineItemType.taskCompleted:
        return 'TASK COMPLETED';
    }
  }

  // Edit Dialog Methods
  Future<void> _showEditCaseDialog() async {
    final titleController = TextEditingController(text: _currentCase.title);
    final clientNameController = TextEditingController(text: _currentCase.clientName);
    final clientNumberController = TextEditingController(text: _currentCase.clientNumber);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Case Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Case Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: clientNameController,
                decoration: const InputDecoration(
                  labelText: 'Client Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: clientNumberController,
                decoration: const InputDecoration(
                  labelText: 'Client Number',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _updateCase(
        title: titleController.text.trim(),
        clientName: clientNameController.text.trim(),
        clientNumber: clientNumberController.text.trim(),
      );
    }
  }

  Future<void> _showEditNextPostingDialog() async {
    final nextPosting = _currentCase.nextPosting;
    final titleController = TextEditingController(text: nextPosting?.title ?? '');
    final noteController = TextEditingController(text: nextPosting?.note ?? '');
    DateTime selectedDate = nextPosting?.date ?? DateTime.now();
    
    // Initialize dropdown values
    String? selectedCourt = nextPosting?.court;
    String? selectedStaff = nextPosting?.staff;
    
    // Check if the existing court value exists in our court list
    if (selectedCourt != null && !globalCourts.any((court) => court.name == selectedCourt)) {
      selectedCourt = null; // Reset to null if court not found in list
    }
    
    // Check if the existing staff value exists in our staff list
    if (selectedStaff != null && !globalUsers.any((user) => user.name == selectedStaff)) {
      selectedStaff = null; // Reset to null if staff not found in list
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Next Posting'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Posting Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (nextPosting?.court != null && selectedCourt == null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      border: Border.all(color: Colors.orange[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Current court "${nextPosting?.court}" is not in the list. Please select a new one.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                DropdownButtonFormField<String>(
                  value: selectedCourt,
                  decoration: const InputDecoration(
                    labelText: 'Court',
                    border: OutlineInputBorder(),
                    hintText: 'Select court',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Select Court'),
                    ),
                    ...globalCourts.map((court) {
                      return DropdownMenuItem(
                        value: court.name,
                        child: Text(court.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCourt = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (nextPosting?.staff != null && selectedStaff == null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      border: Border.all(color: Colors.orange[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Current staff "${nextPosting?.staff}" is not in the list. Please select a new one.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                DropdownButtonFormField<String>(
                  value: selectedStaff,
                  decoration: const InputDecoration(
                    labelText: 'Staff',
                    border: OutlineInputBorder(),
                    hintText: 'Select staff',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Select Staff'),
                    ),
                    ...globalUsers.map((user) {
                      return DropdownMenuItem(
                        value: user.name,
                        child: Text(user.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStaff = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      await _updateNextPosting(
        title: titleController.text.trim(),
        court: selectedCourt ?? '',
        staff: selectedStaff ?? '',
        note: noteController.text.trim(),
        date: selectedDate,
      );
    }
  }

  Future<void> _showEditTasksDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tasks'),
        content: const Text('Task editing functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Update Methods
  Future<void> _updateCase({
    required String title,
    required String clientName,
    required String clientNumber,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedCase = _currentCase.copyWith(
        title: title,
        clientName: clientName,
        clientNumber: clientNumber,
      );

      await CaseService.updateCase(_currentCase.id, updatedCase);

      setState(() {
        _currentCase = updatedCase;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Case details updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating case: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateNextPosting({
    required String title,
    required String court,
    required String staff,
    required String note,
    required DateTime date,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedPosting = Posting(
        id: _currentCase.nextPosting?.id ?? '',
        title: title,
        court: court,
        staff: staff,
        note: note,
        date: date,
      );

      final updatedCase = _currentCase.copyWith(
        nextPosting: updatedPosting,
      );

      await CaseService.updateCase(_currentCase.id, updatedCase);

      setState(() {
        _currentCase = updatedCase;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Next posting updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating posting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

enum TimelineItemType {
  posting,
  taskCompleted,
}

class TimelineItem {
  final TimelineItemType type;
  final DateTime date;
  final String title;
  final String note;
  final String staff;
  final String court;

  TimelineItem({
    required this.type,
    required this.date,
    required this.title,
    this.note = '',
    this.staff = '',
    this.court = '',
  });
}
