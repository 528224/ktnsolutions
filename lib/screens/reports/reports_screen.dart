import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ktnsolutions/screens/reports/case_status_report.dart';
import 'package:ktnsolutions/screens/reports/court_cases_report.dart';
import 'package:ktnsolutions/screens/reports/upcoming_hearings_report.dart';
import 'package:ktnsolutions/services/report_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReportService _reportService = Get.find();
  
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now().add(const Duration(days: 30)),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _dateRange,
    );
    
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.assignment), text: 'Status'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Hearings'),
            Tab(icon: Icon(Icons.gavel), text: 'Courts'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Select Date Range',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CaseStatusReport(
            startDate: _dateRange.start,
            endDate: _dateRange.end,
            reportService: _reportService,
          ),
          UpcomingHearingsReport(
            startDate: _dateRange.start,
            endDate: _dateRange.end,
            reportService: _reportService,
          ),
          CourtCasesReport(
            startDate: _dateRange.start,
            endDate: _dateRange.end,
            reportService: _reportService,
          ),
        ],
      ),
    );
  }
}
