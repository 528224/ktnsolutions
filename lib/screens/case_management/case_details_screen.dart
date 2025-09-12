import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';

class CaseDetailsScreen extends StatelessWidget {
  final LegalCase legalCase;

  const CaseDetailsScreen({
    super.key,
    required this.legalCase,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(legalCase.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
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
            Text(
              legalCase.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Client: ${legalCase.clientName}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Text(
              'Client Number: ${legalCase.clientNumber}',
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
                  '${legalCase.completedTasksCount}/${legalCase.totalTasksCount} tasks completed',
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
    final nextPosting = legalCase.nextPosting;
    
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
                Text(
                  'Next Posting',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
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
    final dueTasks = legalCase.tasks.where((task) => !task.isCompleted).toList();
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
                Text(
                  'Due Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const Spacer(),
                if (overdueTasks.isNotEmpty)
                  Container(
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
    for (final posting in legalCase.previousPostings) {
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
    for (final task in legalCase.tasks.where((task) => task.doneDate != null)) {
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
