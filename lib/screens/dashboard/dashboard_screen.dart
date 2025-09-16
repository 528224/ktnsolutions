import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../services/case_service.dart';
import '../../services/global_data_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateRange _selectedRange = DateRange.today;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  List<LegalCase> _cases = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Widget _buildUserDropdown({
    required String? value,
    required String label,
    required String hintText,
    required ValueChanged<String?> onChanged,
  }) {
    return FutureBuilder<List<UserDetails>>(
      future: GlobalDataService().getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              hintText: hintText,
            ),
            items: const [
              DropdownMenuItem(
                value: null,
                child: Text('Loading...'),
              ),
            ],
            onChanged: null,
          );
        }

        final users = snapshot.data ?? [];
        return DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            hintText: hintText,
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(hintText),
            ),
            ...users.map((user) {
              return DropdownMenuItem(
                value: user.name,
                child: Text(user.name),
              );
            }),
          ],
          onChanged: onChanged,
        );
      },
    );
  }

  Widget _buildCourtDropdown({
    required String? value,
    required String label,
    required String hintText,
    required ValueChanged<String?> onChanged,
  }) {
    return FutureBuilder<List<Court>>(
      future: GlobalDataService().getAllCourts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              hintText: hintText,
            ),
            items: const [
              DropdownMenuItem(
                value: null,
                child: Text('Loading...'),
              ),
            ],
            onChanged: null,
          );
        }

        final courts = snapshot.data ?? [];
        return DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            hintText: hintText,
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(hintText),
            ),
            ...courts.map((court) {
              return DropdownMenuItem(
                value: court.name,
                child: Text(court.name),
              );
            }),
          ],
          onChanged: onChanged,
        );
      },
    );
  }

  Future<void> _loadCases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allCases = await CaseService.getAllCases();
      final filteredCases = _filterCasesByDateRange(allCases);
      
      setState(() {
        _cases = filteredCases;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading cases: $e')),
        );
      }
    }
  }

  List<LegalCase> _filterCasesByDateRange(List<LegalCase> allCases) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (_selectedRange) {
      case DateRange.today:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case DateRange.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
        endDate = DateTime(weekStart.year, weekStart.month, weekStart.day + 6, 23, 59, 59);
        break;
      case DateRange.custom:
        if (_customStartDate == null || _customEndDate == null) {
          return [];
        }
        startDate = DateTime(_customStartDate!.year, _customStartDate!.month, _customStartDate!.day);
        endDate = DateTime(_customEndDate!.year, _customEndDate!.month, _customEndDate!.day, 23, 59, 59);
        break;
    }

    return allCases.where((case_) {
      // Check if case has postings or tasks within the date range
      bool hasRelevantPostings = false;
      bool hasRelevantTasks = false;

      // Check next posting
      if (case_.nextPosting != null) {
        final postingDate = case_.nextPosting!.date;
        if (postingDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
            postingDate.isBefore(endDate.add(const Duration(days: 1)))) {
          hasRelevantPostings = true;
        }
      }

      // Check previous postings
      for (final posting in case_.previousPostings) {
        final postingDate = posting.date;
        if (postingDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
            postingDate.isBefore(endDate.add(const Duration(days: 1)))) {
          hasRelevantPostings = true;
          break;
        }
      }

      // Check tasks
      for (final task in case_.tasks) {
        final taskDate = task.dueDate;
        if (taskDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
            taskDate.isBefore(endDate.add(const Duration(days: 1)))) {
          hasRelevantTasks = true;
          break;
        }
      }

      return hasRelevantPostings || hasRelevantTasks;
    }).toList();
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
        _selectedRange = DateRange.custom;
      });
      _loadCases();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadCases,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateRangeSelector(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cases.isEmpty
                    ? _buildEmptyState()
                    : _buildCasesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Date Range',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateRangeButton(
                  'Today',
                  DateRange.today,
                  Icons.today,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDateRangeButton(
                  'This Week',
                  DateRange.thisWeek,
                  Icons.date_range,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDateRangeButton(
                  'Custom',
                  DateRange.custom,
                  Icons.calendar_today,
                ),
              ),
            ],
          ),
          if (_selectedRange == DateRange.custom) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCustomDateButton(
                    'Start Date',
                    _customStartDate,
                    () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _customStartDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _customStartDate = date;
                        });
                        _loadCases();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCustomDateButton(
                    'End Date',
                    _customEndDate,
                    () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _customEndDate ?? DateTime.now(),
                        firstDate: _customStartDate ?? DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _customEndDate = date;
                        });
                        _loadCases();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateRangeButton(String label, DateRange range, IconData icon) {
    final isSelected = _selectedRange == range;
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _selectedRange = range;
        });
        _loadCases();
      },
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        foregroundColor: isSelected 
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
        elevation: isSelected ? 2 : 0,
      ),
    );
  }

  Widget _buildCustomDateButton(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null ? DateFormat('MMM dd, yyyy').format(date) : label,
                style: TextStyle(
                  color: date != null 
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No cases found for selected date range',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCasesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cases.length,
      itemBuilder: (context, index) {
        final case_ = _cases[index];
        return _buildCaseCard(case_);
      },
    );
  }

  Widget _buildCaseCard(LegalCase case_) {
    final now = DateTime.now();
    final startDate = _getStartDate();
    final endDate = _getEndDate();

    // Filter postings and tasks within the selected date range
    final relevantPostings = <Posting>[];
    final relevantTasks = <Task>[];

    // Add next posting if within range
    if (case_.nextPosting != null) {
      final postingDate = case_.nextPosting!.date;
      if (postingDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
          postingDate.isBefore(endDate.add(const Duration(days: 1)))) {
        relevantPostings.add(case_.nextPosting!);
      }
    }

    // Add previous postings within range
    for (final posting in case_.previousPostings) {
      final postingDate = posting.date;
      if (postingDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
          postingDate.isBefore(endDate.add(const Duration(days: 1)))) {
        relevantPostings.add(posting);
      }
    }

    // Add tasks within range
    for (final task in case_.tasks) {
      final taskDate = task.dueDate;
      if (taskDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
          taskDate.isBefore(endDate.add(const Duration(days: 1)))) {
        relevantTasks.add(task);
      }
    }

    final hasRelevantItems = relevantPostings.isNotEmpty || relevantTasks.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        case_.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasRelevantItems) ...[
                  const SizedBox(height: 8),
                  _buildSimplifiedSummary(relevantPostings, relevantTasks, startDate, endDate),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimplifiedSummary(List<Posting> relevantPostings, List<Task> relevantTasks, DateTime startDate, DateTime endDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // All postings within the selected date range
        if (relevantPostings.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.event,
                size: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                'Postings:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...relevantPostings.map((posting) => _buildPostingItem(posting)),
          const SizedBox(height: 8),
        ],
        
        // All tasks grouped by status
        if (relevantTasks.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.assignment,
                size: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                'Tasks:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              // Completed tasks
              ...relevantTasks.where((task) => task.isCompleted).map((task) => _buildTaskChip(task.title, true)),
              // Pending tasks
              ...relevantTasks.where((task) => !task.isCompleted).map((task) => _buildTaskChip(task.title, false)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPostingItem(Posting posting) {
    // Check if posting is completed
    // A posting is completed if it's in the previousPostings list
    // A posting is pending if it's the nextPosting
    bool isCompleted = false;
    bool isNextPosting = false;
    
    // Find the case that contains this posting
    for (final case_ in _cases) {
      // Check if this posting is in previousPostings (completed)
      if (case_.previousPostings.any((p) => p.id == posting.id)) {
        isCompleted = true;
        break;
      }
      // Check if this posting is the nextPosting (pending)
      if (case_.nextPosting?.id == posting.id) {
        isCompleted = false;
        isNextPosting = true;
        break;
      }
    }
    
    // Define colors based on posting status
    final Color backgroundColor = isCompleted 
        ? Colors.green.withOpacity(0.15)  // Completed postings - green
        : Colors.blue.withOpacity(0.15);  // Pending postings - blue
    
    final Color borderColor = isCompleted 
        ? Colors.green.withOpacity(0.4)
        : Colors.blue.withOpacity(0.4);
    
    final Color iconColor = isCompleted 
        ? Colors.green.shade600
        : Colors.blue.shade600;
    
    final Color textColor = isCompleted 
        ? Colors.green.shade700
        : Colors.blue.shade700;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: GestureDetector(
        onTap: isNextPosting ? () => _completePosting(posting) : null,
        child: Row(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.schedule,
              size: 16,
              color: iconColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    posting.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    '${posting.staff} • ${posting.court} • ${DateFormat('MMM dd').format(posting.date)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isNextPosting)
              Icon(
                Icons.touch_app,
                size: 14,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskChip(String title, bool isCompleted) {
    return GestureDetector(
      onTap: () => _toggleTaskCompletion(title, isCompleted),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isCompleted 
              ? Colors.green.withOpacity(0.1)
              : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isCompleted 
                ? Colors.green.withOpacity(0.3)
                : Colors.orange.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 12,
              color: isCompleted ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isCompleted ? Colors.green.shade700 : Colors.orange.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completePosting(Posting posting) async {
    final completionNoteController = TextEditingController();
    bool addNewPosting = false;
    
    // New posting fields
    final newPostingTitleController = TextEditingController();
    final newPostingNoteController = TextEditingController();
    DateTime newPostingDate = DateTime.now();
    String? selectedCourt;
    String? selectedStaff;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Complete Posting'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Posting: ${posting.title}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Date: ${DateFormat('MMM dd, yyyy').format(posting.date)}'),
                      Text('Court: ${posting.court}'),
                      Text('Staff: ${posting.staff}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: completionNoteController,
                  decoration: const InputDecoration(
                    labelText: 'Completion Note *',
                    border: OutlineInputBorder(),
                    hintText: 'Describe what was accomplished',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Add New Posting'),
                  subtitle: const Text('Create a new posting after completing this one'),
                  value: addNewPosting,
                  onChanged: (value) {
                    setState(() {
                      addNewPosting = value ?? false;
                    });
                  },
                ),
                if (addNewPosting) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'New Posting Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPostingTitleController,
                    decoration: const InputDecoration(
                      labelText: 'New Posting Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCourtDropdown(
                    value: selectedCourt,
                    label: 'Court',
                    hintText: 'Select Court',
                    onChanged: (value) {
                      setState(() {
                        selectedCourt = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildUserDropdown(
                    value: selectedStaff,
                    label: 'Staff',
                    hintText: 'Select Staff',
                    onChanged: (value) {
                      setState(() {
                        selectedStaff = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPostingNoteController,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(DateFormat('MMM dd, yyyy').format(newPostingDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: newPostingDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          newPostingDate = date;
                        });
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (completionNoteController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Completion note is required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('Complete'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      Posting? newPosting;
      if (addNewPosting && newPostingTitleController.text.trim().isNotEmpty) {
        newPosting = Posting(
          id: Uuid().v4(),
          title: newPostingTitleController.text.trim(),
          court: selectedCourt ?? '',
          staff: selectedStaff ?? '',
          note: newPostingNoteController.text.trim(),
          date: newPostingDate,
        );
      }

      try {
        // Find the case that contains this posting as nextPosting
        for (final case_ in _cases) {
          if (case_.nextPosting?.id == posting.id) {
            // Complete the posting using the CaseService
            await CaseService.completePosting(
              caseId: case_.id,
              completionNote: completionNoteController.text.trim(),
              newPosting: newPosting,
            );
            
            // Refresh the UI
            _loadCases();
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(newPosting != null 
                      ? 'Posting completed and new posting added successfully!'
                      : 'Posting completed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            return; // Exit after successful completion
          }
        }
        
        // If we reach here, the posting was not found as nextPosting
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Posting not found or already completed'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error completing posting: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleTaskCompletion(String taskTitle, bool currentStatus) async {
    // Find the case and task first
    Task? taskToUpdate;
    LegalCase? caseToUpdate;
    
    for (final case_ in _cases) {
      final taskIndex = case_.tasks.indexWhere((task) => task.title == taskTitle);
      if (taskIndex != -1) {
        taskToUpdate = case_.tasks[taskIndex];
        caseToUpdate = case_;
        break;
      }
    }
    
    if (taskToUpdate == null || caseToUpdate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show confirmation dialog
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(currentStatus ? 'Mark Task as Pending' : 'Complete Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentStatus 
                  ? 'Are you sure you want to mark this task as pending?'
                  : 'Are you sure you want to mark this task as completed?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: currentStatus ? Colors.orange[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: currentStatus ? Colors.orange[200]! : Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task: ${taskToUpdate?.title}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Due: ${DateFormat('MMM dd, yyyy').format(taskToUpdate!.dueDate)}'),
                  Text('Staff: ${taskToUpdate?.staff}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentStatus ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(currentStatus ? 'Mark Pending' : 'Mark Complete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final updatedTask = taskToUpdate.copyWith(
          doneDate: currentStatus ? null : DateTime.now(),
        );
        
        // Create updated tasks list
        final updatedTasks = List<Task>.from(caseToUpdate.tasks);
        final taskIndex = updatedTasks.indexWhere((task) => task.title == taskTitle);
        updatedTasks[taskIndex] = updatedTask;
        
        // Update the case with new tasks while preserving all other data
        final updatedCase = caseToUpdate.copyWith(tasks: updatedTasks);
        
        // Update in Firestore
        await CaseService.updateCase(caseToUpdate.id, updatedCase);
        
        // Refresh the UI
        _loadCases();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                currentStatus 
                    ? 'Task marked as pending' 
                    : 'Task marked as completed',
              ),
              backgroundColor: currentStatus ? Colors.orange : Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating task: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }


  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedRange) {
      case DateRange.today:
        return DateTime(now.year, now.month, now.day);
      case DateRange.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return DateTime(weekStart.year, weekStart.month, weekStart.day);
      case DateRange.custom:
        return _customStartDate ?? DateTime.now();
    }
  }

  DateTime _getEndDate() {
    final now = DateTime.now();
    switch (_selectedRange) {
      case DateRange.today:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case DateRange.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return DateTime(weekStart.year, weekStart.month, weekStart.day + 6, 23, 59, 59);
      case DateRange.custom:
        return _customEndDate ?? DateTime.now();
    }
  }
}

enum DateRange {
  today,
  thisWeek,
  custom,
}
