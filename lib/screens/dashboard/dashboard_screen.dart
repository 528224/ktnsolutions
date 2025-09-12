import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../services/case_service.dart';

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
  Set<String> _expandedCases = {}; // Track which cases are expanded

  @override
  void initState() {
    super.initState();
    _loadCases();
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

    final isExpanded = _expandedCases.contains(case_.id);
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
                    if (hasRelevantItems) ...[
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedCases.remove(case_.id);
                            } else {
                              _expandedCases.add(case_.id);
                            }
                          });
                        },
                        icon: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        tooltip: isExpanded ? 'Collapse details' : 'Expand details',
                      ),
                    ],
                  ],
                ),
                if (hasRelevantItems) ...[
                  const SizedBox(height: 8),
                  _buildSimplifiedSummary(relevantPostings, relevantTasks, startDate, endDate),
                ],
              ],
            ),
            if (isExpanded && hasRelevantItems) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              if (relevantPostings.isNotEmpty) ...[
                const Text(
                  'Postings',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...relevantPostings.map((posting) => _buildPostingItem(posting, case_)),
                const SizedBox(height: 12),
              ],
              if (relevantTasks.isNotEmpty) ...[
                const Text(
                  'Tasks',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...relevantTasks.map((task) => _buildTaskItem(task)),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSimplifiedSummary(List<Posting> relevantPostings, List<Task> relevantTasks, DateTime startDate, DateTime endDate) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59);
    
    // Get today's posting (should be only one)
    final todayPosting = relevantPostings.where((posting) {
      return posting.date.isAfter(todayStart.subtract(const Duration(minutes: 1))) && 
             posting.date.isBefore(todayEnd.add(const Duration(minutes: 1)));
    }).firstOrNull;
    
    // Group tasks by status and today's due date
    final todayTasks = relevantTasks.where((task) {
      return task.dueDate.isAfter(todayStart.subtract(const Duration(minutes: 1))) && 
             task.dueDate.isBefore(todayEnd.add(const Duration(minutes: 1)));
    }).toList();
    
    final completedTodayTasks = todayTasks.where((task) => task.isCompleted).toList();
    final pendingTodayTasks = todayTasks.where((task) => !task.isCompleted).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Today's posting (single)
        if (todayPosting != null) ...[
          _buildTodayPostingItem(todayPosting),
          const SizedBox(height: 8),
        ],
        
        // Today's tasks grouped by status
        if (todayTasks.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.assignment,
                size: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                'Tasks Today:',
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
              ...completedTodayTasks.map((task) => _buildTaskChip(task.title, true)),
              // Pending tasks
              ...pendingTodayTasks.map((task) => _buildTaskChip(task.title, false)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTodayPostingItem(Posting posting) {
    // Check if posting is completed
    bool isCompleted = false;
    for (final case_ in _cases) {
      if (case_.previousPostings.any((p) => p.id == posting.id)) {
        isCompleted = true;
        break;
      }
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted 
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted 
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.schedule,
            size: 16,
            color: isCompleted ? Colors.green : Colors.orange,
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
                    color: isCompleted ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
                Text(
                  '${posting.staff} • ${posting.court}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskChip(String title, bool isCompleted) {
    return Container(
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
    );
  }

  Widget _buildCollapsedItemChip(String title, bool isCompleted, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isCompleted 
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
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
            icon,
            size: 10,
            color: isCompleted ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isCompleted ? Colors.green.shade700 : Colors.orange.shade700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedPostingItem(Posting posting) {
    // Check if posting is completed by looking through all cases
    bool isCompleted = false;
    for (final case_ in _cases) {
      if (case_.previousPostings.any((p) => p.id == posting.id)) {
        isCompleted = true;
        break;
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
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
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.schedule,
            size: 12,
            color: isCompleted ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              posting.title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isCompleted ? Colors.green.shade700 : Colors.orange.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            DateFormat('HH:mm').format(posting.date),
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostingItem(Posting posting, LegalCase case_) {
    final isCompleted = case_.previousPostings.contains(posting);
    final isNextPosting = case_.nextPosting?.id == posting.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isNextPosting 
              ? Colors.blue.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.schedule,
            color: isCompleted ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  posting.title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${DateFormat('MMM dd, yyyy').format(posting.date)} • ${posting.court}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                if (posting.note.isNotEmpty)
                  Text(
                    posting.note,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),
          if (isNextPosting)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: task.isCompleted 
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: task.isCompleted ? Colors.green : Colors.grey,
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
                    fontWeight: FontWeight.w500,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  'Due: ${DateFormat('MMM dd, yyyy').format(task.dueDate)} • ${task.staff}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
