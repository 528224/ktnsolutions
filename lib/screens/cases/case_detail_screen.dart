import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ktnsolutions/models/case_model.dart';
import 'package:ktnsolutions/screens/cases/case_info_tab.dart';
import 'package:ktnsolutions/screens/cases/case_timeline_tab.dart';
import 'package:ktnsolutions/services/case_service.dart';

import 'add_edit_case_screen.dart';

class CaseDetailScreen extends StatefulWidget {
  final String caseId;
  
  const CaseDetailScreen({super.key, required this.caseId});

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> with SingleTickerProviderStateMixin {
  final _caseService = CaseService();
  late Future<LegalCase?> _caseFuture;
  late TabController _tabController;
  final bool _isAdmin = true; // TODO: Get from auth service

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCase();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadCase() {
    setState(() {
      _caseFuture = _caseService.getCase(widget.caseId);
    });
  }

  Future<void> _refreshData() async {
    _loadCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Details'),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final legalCase = await _caseFuture;
                if (legalCase != null) {
                  final result = await Get.to<bool>(
                    () => AddEditCaseScreen(legalCase: legalCase),
                  );
                  if (result == true) _loadCase();
                }
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: 'Info'),
            Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
          ],
        ),
      ),
      body: FutureBuilder<LegalCase?>(
        future: _caseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error loading case details'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCase,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          final legalCase = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: TabBarView(
              controller: _tabController,
              children: [
                CaseInfoTab(legalCase: legalCase),
                CaseTimelineTab(legalCase: legalCase),
              ],
            ),
          );
        },
      ),
    );
  }
}
