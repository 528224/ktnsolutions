import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ktnsolutions/models/case_model.dart';
import 'package:ktnsolutions/screens/cases/add_edit_event_screen.dart';
import 'package:ktnsolutions/services/case_service.dart';

class CaseTimelineTab extends StatefulWidget {
  final LegalCase legalCase;
  
  const CaseTimelineTab({super.key, required this.legalCase});

  @override
  State<CaseTimelineTab> createState() => _CaseTimelineTabState();
}

class _CaseTimelineTabState extends State<CaseTimelineTab> {
  final _caseService = CaseService();
  final bool _isAdmin = true; // TODO: Get from auth service

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add Event Button (for admin/staff)
        if (_isAdmin)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _addNewEvent,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Event'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),
          ),
          
        // Timeline Events List
        Expanded(
          child: StreamBuilder<List<CaseEvent>>(
            stream: _caseService.getCaseEvents(widget.legalCase.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Error loading timeline events'),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              
              final events = snapshot.data ?? [];
              
              if (events.isEmpty) {
                return const Center(
                  child: Text('No events found'),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return _buildTimelineItem(events[index], index, events.length);
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimelineItem(CaseEvent event, int index, int totalItems) {
    final isFirst = index == 0;
    final isLast = index == totalItems - 1;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 1.5,
                height: 12,
                color: Colors.grey[300],
              ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _getEventColor(event.eventType),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                _getEventIcon(event.eventType),
                size: 12,
                color: Colors.white,
              ),
            ),
            if (!isLast)
              Expanded(
                child: Container(
                  width: 1.5,
                  color: Colors.grey[300],
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        
        // Event content
        Expanded(
          child: Card(
            margin: const EdgeInsets.only(bottom: 16, right: 16),
            child: InkWell(
              onTap: _isAdmin ? () => _editEvent(event) : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_isAdmin)
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 20),
                            onSelected: (value) => _handleEventAction(value, event),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(event.eventDate)} • ${_formatTime(event.eventDate)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    if (event.description?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 8),
                      Text(event.description!),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Future<void> _addNewEvent() async {
    final result = await Get.to<bool>(
      () => AddEditEventScreen(caseId: widget.legalCase.id),
    );
    
    if (result == true) {
      // Refresh the timeline
      setState(() {});
    }
  }
  
  Future<void> _editEvent(CaseEvent event) async {
    final result = await Get.to<bool>(
      () => AddEditEventScreen(caseId: event.caseId, event: event),
    );
    
    if (result == true) {
      // Refresh the timeline
      setState(() {});
    }
  }
  
  Future<void> _handleEventAction(String action, CaseEvent event) async {
    switch (action) {
      case 'edit':
        await _editEvent(event);
        break;
      case 'delete':
        await _confirmDeleteEvent(event);
        break;
    }
  }
  
  Future<void> _confirmDeleteEvent(CaseEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await _caseService.deleteCaseEvent(event.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event deleted successfully')),
          );
        }
      } catch (e) {
        debugPrint('Error deleting event: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete event')),
          );
        }
      }
    }
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
  
  String _formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
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
  
  IconData _getEventIcon(EventType eventType) {
    switch (eventType) {
      case EventType.hearing:
        return Icons.gavel;
      case EventType.filing:
        return Icons.description;
      case EventType.deadline:
        return Icons.event_available;
      case EventType.general:
        return Icons.event_note;
      case EventType.other:
        return Icons.info;
    }
  }
}
