import 'package:flutter/material.dart';
import 'package:ktnsolutions/models/case_model.dart';
import 'package:ktnsolutions/services/report_service.dart';
import 'package:ktnsolutions/widgets/loading_indicator.dart';

class CaseStatusReport extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final ReportService reportService;

  const CaseStatusReport({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.reportService,
  });

  @override
  State<CaseStatusReport> createState() => _CaseStatusReportState();
}

class _CaseStatusReportState extends State<CaseStatusReport> {
  Map<CaseStatus, int>? _statusCounts;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final counts = await widget.reportService.getCaseStatusReport(
        startDate: widget.startDate,
        endDate: widget.endDate,
      );
      
      setState(() {
        _statusCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load report: $e';
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
              onPressed: _loadReport,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final counts = _statusCounts!;
    final total = counts.values.fold(0, (sum, count) => sum + count);
    
    final colors = {
      CaseStatus.pending: Colors.orange,
      CaseStatus.inProgress: Colors.blue,
      CaseStatus.completed: Colors.green,
      CaseStatus.adjourned: Colors.purple,
      CaseStatus.dismissed: Colors.red,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(total),
          const SizedBox(height: 24),
          _buildStatusList(counts, colors, total),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int total) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Case Status Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Cases: $total',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Date Range: ${_formatDate(widget.startDate)} - ${_formatDate(widget.endDate)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusList(
    Map<CaseStatus, int> counts,
    Map<CaseStatus, Color> colors,
    int total,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...counts.entries.map((entry) {
              final status = entry.key;
              final count = entry.value;
              final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          status.toString().split('.').last,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text('$count (${percentage}%)'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: total > 0 ? count / total : 0,
                      backgroundColor: colors[status]!.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(colors[status]!),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
