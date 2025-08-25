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
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Reports'),
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              indicatorColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
              tabs: const [
                Tab(icon: Icon(Icons.assignment), text: 'Status'),
                Tab(icon: Icon(Icons.calendar_today), text: 'Hearings'),
                Tab(icon: Icon(Icons.gavel), text: 'Courts'),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () => _selectDateRange(context),
                  tooltip: 'Select Date Range',
                ),
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
        ),
      ),
    );
  }
}
