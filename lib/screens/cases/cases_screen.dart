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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cases'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Today'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildCaseList(_todayCases, 'No cases scheduled for today'),
                  _buildCaseList(_upcomingCases, 'No upcoming cases'),
                  _buildCaseList(_pastCases, 'No past cases'),
                ],
              ),
        floatingActionButton: _isAdmin
            ? FloatingActionButton(
                onPressed: _navigateToAddCase,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
  
  Widget _buildCaseList(List<LegalCase> cases, String emptyMessage) {
    if (cases.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: cases.length,
      itemBuilder: (context, index) {
        final legalCase = cases[index];
        return _buildCaseCard(legalCase);
      },
    );
  }
  
  Widget _buildCaseCard(LegalCase legalCase) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      child: InkWell(
        onTap: () => _navigateToCaseDetail(legalCase),
        onLongPress: _isAdmin ? () => _showCaseOptions(legalCase) : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      legalCase.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(legalCase.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatStatus(legalCase.status),
                      style: TextStyle(
                        color: _getStatusColor(legalCase.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Case No: ${legalCase.caseNumber}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Court: ${legalCase.courtName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Client: ${legalCase.clientName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Advocate: ${legalCase.advocateName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              if (legalCase.nextHearingDate != null) ...[
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Next Hearing: ${_formatDate(legalCase.nextHearingDate!)}\n${_formatTime(legalCase.nextHearingDate!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  void _showCaseOptions(LegalCase legalCase) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(context);
              _navigateToEditCase(legalCase);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(legalCase);
            },
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(LegalCase legalCase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Case'),
        content: const Text('Are you sure you want to delete this case? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCase(legalCase);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteCase(LegalCase legalCase) async {
    try {
      await _caseService.deleteCase(legalCase.id);
      await _loadCases();
    } catch (e) {
      debugPrint('Error deleting case: $e');
      Get.snackbar('Error', 'Failed to delete case');
    }
  }
  
  Future<void> _navigateToEditCase(LegalCase legalCase) async {
    final result = await Get.to<bool>(
      () => AddEditCaseScreen(legalCase: legalCase),
      fullscreenDialog: true,
    );
    
    if (result == true) {
      await _loadCases();
    }
  }
  
  Color _getStatusColor(CaseStatus status) {
    switch (status) {
      case CaseStatus.pending:
        return Colors.orange;
      case CaseStatus.inProgress:
        return Colors.blue;
      case CaseStatus.completed:
        return Colors.green;
      case CaseStatus.adjourned:
        return Colors.purple;
      case CaseStatus.dismissed:
        return Colors.red;
    }
  }
  
  String _formatStatus(CaseStatus status) {
    return status.toString().split('.').last;
  }
  
  String _formatDate(DateTime date) {
    return '${_getDayName(date.weekday)}, ${date.day} ${_getMonthName(date.month)} ${date.year}';
  }
  
  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final period = date.hour < 12 ? 'AM' : 'PM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
  
  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
  
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
