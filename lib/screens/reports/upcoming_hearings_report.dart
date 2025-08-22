import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ktnsolutions/models/case_model.dart';
import 'package:ktnsolutions/services/report_service.dart';
import 'package:ktnsolutions/widgets/loading_indicator.dart';

class UpcomingHearingsReport extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final ReportService reportService;

  const UpcomingHearingsReport({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.reportService,
  });

  @override
  State<UpcomingHearingsReport> createState() => _UpcomingHearingsReportState();
}

class _UpcomingHearingsReportState extends State<UpcomingHearingsReport> {
  List<CaseEvent>? _hearings;
  bool _isLoading = true;
  String? _error;
  String? _selectedAdvocate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHearings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHearings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final hearings = await widget.reportService.getUpcomingHearingsReport(
        startDate: widget.startDate,
        endDate: widget.endDate,
        advocateName: _selectedAdvocate,
      );
      
      setState(() {
        _hearings = hearings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load hearings: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHearings,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final hearings = _hearings ?? [];
    final filteredHearings = hearings.where((hearing) {
      if (_searchController.text.isEmpty) return true;
      final query = _searchController.text.toLowerCase();
      return hearing.title.toLowerCase().contains(query) ||
             hearing.description.toLowerCase().contains(query) ||
             hearing.caseId.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: hearings.isEmpty
              ? _buildEmptyState()
              : _buildHearingsList(filteredHearings),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search Hearings',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          // TODO: Add advocate filter dropdown if needed
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No upcoming hearings found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatDate(widget.startDate)} - ${_formatDate(widget.endDate)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildHearingsList(List<CaseEvent> hearings) {
    return ListView.builder(
      itemCount: hearings.length,
      itemBuilder: (context, index) {
        final hearing = hearings[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              hearing.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(hearing.description),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(hearing.eventDate),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to case details
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy • hh:mm a').format(date);
  }
}
