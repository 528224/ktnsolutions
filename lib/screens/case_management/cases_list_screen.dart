import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../services/case_service.dart';
import 'add_case_screen.dart';
import 'case_details_screen.dart';

class CasesListScreen extends StatefulWidget {
  const CasesListScreen({super.key});

  @override
  State<CasesListScreen> createState() => _CasesListScreenState();
}

class _CasesListScreenState extends State<CasesListScreen> {
  List<LegalCase> _allCases = [];
  List<LegalCase> _activeCases = [];
  List<LegalCase> _completedCases = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<LegalCase> cases = await CaseService.getAllCases();

      setState(() {
        _allCases = cases;
        _isLoading = false;
      });

      _categorizeAndSortCases();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _categorizeAndSortCases() {
    // Separate active and completed cases
    _activeCases = _allCases.where((case_) => case_.doneDate == null).toList();
    _completedCases = _allCases.where((case_) => case_.doneDate != null).toList();

    // Sort active cases by nextPosting date
    _activeCases.sort((a, b) {
      // Cases with no nextPosting go to the end
      if (a.nextPosting == null && b.nextPosting == null) return 0;
      if (a.nextPosting == null) return 1;
      if (b.nextPosting == null) return -1;

      // Today's items first, then future items
      final now = DateTime.now();
      final aDate = a.nextPosting!.date;
      final bDate = b.nextPosting!.date;

      // Check if dates are today
      final aIsToday = _isSameDay(aDate, now);
      final bIsToday = _isSameDay(bDate, now);

      if (aIsToday && !bIsToday) return -1;
      if (!aIsToday && bIsToday) return 1;
      if (aIsToday && bIsToday) return 0;

      // Both are future dates, sort by date
      return aDate.compareTo(bDate);
    });

    // Sort completed cases by doneDate (most recent first)
    _completedCases.sort((a, b) => b.doneDate!.compareTo(a.doneDate!));

    setState(() {});
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cases'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddCase,
            tooltip: 'Add New Case',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCases,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  void _navigateToAddCase() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCaseScreen(),
      ),
    ).then((_) {
      // Refresh the list when returning from add case screen
      _loadCases();
    });
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCases,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCases,
      child: CustomScrollView(
        slivers: [
            // Active Cases Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Active Cases (${_activeCases.length})',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            if (_activeCases.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No active cases',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return ActiveCaseListItem(
                      case_: _activeCases[index],
                      onTap: () => _onCaseTap(_activeCases[index]),
                    );
                  },
                  childCount: _activeCases.length,
                ),
              ),

            // Completed Cases Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                child: Text(
                  'Completed Cases (${_completedCases.length})',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ),
            if (_completedCases.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No completed cases',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return CompletedCaseListItem(
                      case_: _completedCases[index],
                      onTap: () => _onCaseTap(_completedCases[index]),
                    );
                  },
                  childCount: _completedCases.length,
                ),
              ),
          ],
        ),
      );
  }

  void _onCaseTap(LegalCase case_) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CaseDetailsScreen(legalCase: case_),
      ),
    );
  }

}

class ActiveCaseListItem extends StatelessWidget {
  final LegalCase case_;
  final VoidCallback onTap;

  const ActiveCaseListItem({
    super.key,
    required this.case_,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nextPosting = case_.nextPosting;
    final nextPostingDate = nextPosting?.date;
    final nextPostingTitle = nextPosting?.title ?? 'No upcoming posting';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _getDateColor(context, nextPostingDate),
          child: Icon(
            Icons.cases,
            color: Colors.white,
          ),
        ),
        title: Text(
          case_.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (nextPostingDate != null) ...[
              Text(
                'Next: $nextPostingTitle',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('MMM dd, yyyy').format(nextPostingDate),
                style: TextStyle(
                  color: _getDateColor(context, nextPostingDate),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else
              Text(
                'No upcoming posting',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Color _getDateColor(BuildContext context, DateTime? date) {
    if (date == null) return Colors.grey;
    
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
}

class CompletedCaseListItem extends StatelessWidget {
  final LegalCase case_;
  final VoidCallback onTap;

  const CompletedCaseListItem({
    super.key,
    required this.case_,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final doneDate = case_.doneDate!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: const Icon(
            Icons.check,
            color: Colors.white,
          ),
        ),
        title: Text(
          case_.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completed on',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('MMM dd, yyyy').format(doneDate),
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
