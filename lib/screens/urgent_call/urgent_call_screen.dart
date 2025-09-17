import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/urgent_call.dart';
import '../../models/user.dart';
import '../../services/urgent_call_service.dart';
import '../../services/global_data_service.dart';

class UrgentCallScreen extends StatefulWidget {
  const UrgentCallScreen({super.key});

  @override
  State<UrgentCallScreen> createState() => _UrgentCallScreenState();
}

class _UrgentCallScreenState extends State<UrgentCallScreen> {
  final UrgentCallService _urgentCallService = UrgentCallService();
  String? _currentUserId;
  List<UrgentCall> _urgentCalls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser?.phoneNumber == null) return;
    
    try {
      final users = await GlobalDataService().getAllUsers();
      final currentUserData = users.firstWhere(
        (user) => user.mobile == currentUser!.phoneNumber,
        orElse: () => UserDetails(id: '', name: '', mobile: '', isAdmin: false),
      );
      
      setState(() {
        _currentUserId = currentUserData.id;
      });
      
      if (_currentUserId != null) {
        _loadUrgentCalls();
      }
    } catch (e) {
      print('Error getting current user ID: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadUrgentCalls() {
    if (_currentUserId == null) return;
    
    _urgentCallService.getUrgentCallsForUser(_currentUserId!).listen((calls) {
      if (mounted) {
        setState(() {
          _urgentCalls = calls;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _respondToCall(UrgentCall call, CallResponseType responseType) async {
    if (_currentUserId == null) return;
    
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final users = await GlobalDataService().getAllUsers();
      final currentUserData = users.firstWhere(
        (user) => user.mobile == currentUser!.phoneNumber,
        orElse: () => UserDetails(id: '', name: '', mobile: '', isAdmin: false),
      );

      await _urgentCallService.respondToUrgentCall(
        urgentCallId: call.id,
        userId: _currentUserId!,
        userName: currentUserData.name,
        responseType: responseType,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Response sent: ${responseType.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending response: $e')),
        );
      }
    }
  }

  Future<void> _callUser(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw Exception('Could not launch phone app');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error calling: $e')),
        );
      }
    }
  }

  Widget _buildUrgentCallCard(UrgentCall call) {
    final timeAgo = DateTime.now().difference(call.createdAt);
    final timeString = timeAgo.inMinutes < 1 
        ? 'Just now'
        : timeAgo.inMinutes < 60
            ? '${timeAgo.inMinutes}m ago'
            : '${timeAgo.inHours}h ago';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Urgent Call from ${call.fromUserName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  timeString,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            if (call.message != null) ...[
              const SizedBox(height: 8),
              Text(
                call.message!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
            
            const SizedBox(height: 8),
            Text(
              'Call from: ${call.fromUserMobile}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callUser(call.fromUserMobile),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Call Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _respondToCall(call, CallResponseType.acknowledged),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Acknowledge'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _respondToCall(call, CallResponseType.busy),
                    icon: const Icon(Icons.block, size: 18),
                    label: const Text('Busy'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _respondToCall(call, CallResponseType.unavailable),
                    icon: const Icon(Icons.person_off, size: 18),
                    label: const Text('Unavailable'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Urgent Calls',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You will receive urgent calls here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Urgent Calls'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadUrgentCalls,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _urgentCalls.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _urgentCalls.length,
                  itemBuilder: (context, index) {
                    return _buildUrgentCallCard(_urgentCalls[index]);
                  },
                ),
    );
  }
}
