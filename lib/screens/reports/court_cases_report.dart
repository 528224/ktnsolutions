import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ktnsolutions/services/report_service.dart';
import 'package:ktnsolutions/widgets/loading_indicator.dart';

class CourtCasesReport extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final ReportService reportService;

  const CourtCasesReport({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.reportService,
  });

  @override
  State<CourtCasesReport> createState() => _CourtCasesReportState();
}

class _CourtCasesReportState extends State<CourtCasesReport> {
  Map<String, int>? _courtCounts;
  bool _isLoading = true;
  String? _error;
  bool _showAsPieChart = true;

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
      final counts = await widget.reportService.getCasesByCourtReport(
        startDate: widget.startDate,
        endDate: widget.endDate,
      );
      
      setState(() {
        _courtCounts = counts;
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

    final counts = _courtCounts!;
    final total = counts.values.fold(0, (sum, count) => sum + count);
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        _buildHeader(total),
        _buildToggleViewButton(),
        Expanded(
          child: _showAsPieChart
              ? _buildPieChart(entries, total)
              : _buildList(entries, total),
        ),
      ],
    );
  }

  Widget _buildHeader(int total) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Court Cases Distribution',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Total Cases: $total',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatDate(widget.startDate)} - ${_formatDate(widget.endDate)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleViewButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: ToggleButtons(
          isSelected: [_showAsPieChart, !_showAsPieChart],
          onPressed: (index) {
            setState(() {
              _showAsPieChart = index == 0;
            });
          },
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.pie_chart, size: 20),
                  SizedBox(width: 4),
                  Text('Chart'),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.view_list, size: 20),
                  SizedBox(width: 4),
                  Text('List'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(List<MapEntry<String, int>> entries, int total) {
    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
        position: LegendPosition.bottom,
      ),
      series: <CircularSeries>[
        DoughnutSeries<MapEntry<String, int>, String>(
          dataSource: entries,
          xValueMapper: (entry, _) => '${entry.key} (${_getPercentage(entry.value, total)}%)',
          yValueMapper: (entry, _) => entry.value,
          dataLabelMapper: (entry, _) => '${entry.key}\n${entry.value}',
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            connectorLineSettings: ConnectorLineSettings(length: '10%'),
          ),
          radius: '70%',
          innerRadius: '30%',
        ),
      ],
    );
  }

  Widget _buildList(List<MapEntry<String, int>> entries, int total) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final percentage = _getPercentage(entry.value, total);
        
        return Card(
          child: ListTile(
            title: Text(entry.key),
            trailing: Text(
              '${entry.value} (${percentage}%)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: LinearProgressIndicator(
              value: entry.value / total,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getPercentage(int value, int total) {
    if (total == 0) return '0';
    return (value / total * 100).toStringAsFixed(1);
  }
}
