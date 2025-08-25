import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ktnsolutions/models/case_model.dart';
import 'package:ktnsolutions/screens/cases/add_edit_case_screen.dart';
import 'package:ktnsolutions/screens/cases/case_detail_screen.dart';
import 'package:ktnsolutions/services/case_service.dart';

class CasesScreen extends StatefulWidget {
  const CasesScreen({super.key});

  @override
  State<CasesScreen> createState() => _CasesScreenState();
}

class _CasesScreenState extends State<CasesScreen> with SingleTickerProviderStateMixin {
  final CaseService _caseService = CaseService();
  final bool _isAdmin = true; // TODO: Get from auth service
  late TabController _tabController;
  
  final List<LegalCase> _todayCases = [];
  final List<LegalCase> _upcomingCases = [];
  final List<LegalCase> _pastCases = [];
  
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCases();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCases() async {
    setState(() => _isLoading = true);
    
    try {
      final cases = await _caseService.getCases();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      _todayCases.clear();
      _upcomingCases.clear();
      _pastCases.clear();
      
      for (final legalCase in cases) {
        if (legalCase.nextHearingDate == null) continue;
        
        final caseDate = DateTime(
          legalCase.nextHearingDate!.year,
          legalCase.nextHearingDate!.month,
          legalCase.nextHearingDate!.day,
        );
        
        if (caseDate.isAtSameMomentAs(today)) {
          _todayCases.add(legalCase);
        } else if (caseDate.isAfter(today)) {
          _upcomingCases.add(legalCase);
        } else {
          _pastCases.add(legalCase);
        }
      }
      
      // Sort cases by date
      _todayCases.sort((a, b) => a.nextHearingDate!.compareTo(b.nextHearingDate!));
      _upcomingCases.sort((a, b) => a.nextHearingDate!.compareTo(b.nextHearingDate!));
      _pastCases.sort((a, b) => b.nextHearingDate!.compareTo(a.nextHearingDate!));
      
      setState(() {});
    } catch (e) {
      debugPrint('Error loading cases: $e');
      Get.snackbar('Error', 'Failed to load cases');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _navigateToAddCase() async {
    final result = await Get.to<bool>(
      () => const AddEditCaseScreen(),
      fullscreenDialog: true,
    );
    
    if (result == true) {
      await _loadCases();
    }
  }
  
  void _navigateToCaseDetail(LegalCase legalCase) async {
    final result = await Get.to<bool>(
      () => CaseDetailScreen(caseId: legalCase.id,),
    );
    
    if (result == true) {
      await _loadCases();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Cases'),
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Today'),
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
              ],
              labelColor: Theme.of(context).colorScheme.primary,
              indicatorColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
            ),
          ),
          body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCaseList(_todayCases),
                      _buildCaseList(_upcomingCases),
                      _buildCaseList(_pastCases),
                    ],
                  ),
          floatingActionButton: _isAdmin
              ? Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: FloatingActionButton(
                    onPressed: _navigateToAddCase,
                    child: const Icon(Icons.add),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildCaseList(List<LegalCase> cases) {
    if (cases.isEmpty) {
      return const Center(
        child: Text('No cases found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: cases.length,
      itemBuilder: (context, index) {
        final legalCase = cases[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildCaseCard(legalCase),
        );
      },
    );
  }

  Widget _buildCaseCard(LegalCase legalCase) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToCaseDetail(legalCase),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                legalCase.caseNumber,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                legalCase.title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (legalCase.nextHearingDate != null) ...{
                const SizedBox(height: 8),
                Text(
                  'Next Hearing: ${legalCase.nextHearingDate?.toLocal().toString().split('.')[0]}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}
