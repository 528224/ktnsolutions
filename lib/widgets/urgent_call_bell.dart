import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/global_data_service.dart';
import '../services/urgent_call_service.dart';
import '../screens/urgent_call/urgent_call_screen.dart';

class UrgentCallBell extends StatefulWidget {
  const UrgentCallBell({super.key});

  @override
  State<UrgentCallBell> createState() => _UrgentCallBellState();
}

class _UrgentCallBellState extends State<UrgentCallBell> {
  final UrgentCallService _urgentCallService = UrgentCallService();
  bool _isAdmin = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser?.phoneNumber == null) return;
    
    try {
      final users = await GlobalDataService().getAllUsers();
      final currentUserData = users.firstWhere(
        (user) => user.mobile == currentUser!.phoneNumber,
        orElse: () => UserDetails(id: '', name: '', mobile: '', isAdmin: false),
      );
      
      setState(() {
        _isAdmin = currentUserData.isAdmin;
      });
    } catch (e) {
      print('Error checking admin status: $e');
    }
  }

  void _showUrgentCallDialog() {
    if (!_isAdmin) return;
    
    showDialog(
      context: context,
      builder: (context) => const UrgentCallDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) return const SizedBox.shrink();
    
    return Stack(
      children: [
        IconButton(
          onPressed: _isLoading ? null : _showUrgentCallDialog,
          icon: const Icon(
            Icons.notifications_active,
            color: Colors.red,
            size: 28,
          ),
          tooltip: 'Send Urgent Call',
        ),
        // You can add a badge here if needed to show pending calls
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class UrgentCallDialog extends StatefulWidget {
  const UrgentCallDialog({super.key});

  @override
  State<UrgentCallDialog> createState() => _UrgentCallDialogState();
}

class _UrgentCallDialogState extends State<UrgentCallDialog> {
  final UrgentCallService _urgentCallService = UrgentCallService();
  final GlobalDataService _globalDataService = GlobalDataService();
  final TextEditingController _messageController = TextEditingController();
  
  List<UserDetails> _allUsers = [];
  List<UserDetails> _selectedUsers = [];
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final users = await _globalDataService.getAllUsers();
      // Filter out admin users (they shouldn't receive urgent calls from themselves)
      final currentUser = FirebaseAuth.instance.currentUser;
      final filteredUsers = users.where((user) => 
        user.mobile != currentUser?.phoneNumber && !user.isAdmin
      ).toList();
      
      setState(() {
        _allUsers = filteredUsers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    }
  }

  Future<void> _sendUrgentCall() async {
    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one user')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser?.phoneNumber == null) {
        throw Exception('User not authenticated');
      }

      // Get current user details
      final users = await _globalDataService.getAllUsers();
      final currentUserData = users.firstWhere(
        (user) => user.mobile == currentUser!.phoneNumber,
        orElse: () => UserDetails(id: '', name: '', mobile: '', isAdmin: false),
      );

      await _urgentCallService.sendUrgentCall(
        fromUserId: currentUserData.id,
        fromUserName: currentUserData.name,
        fromUserMobile: currentUserData.mobile,
        targetUserIds: _selectedUsers.map((user) => user.id).toList(),
        targetUserNames: _selectedUsers.map((user) => user.name).toList(),
        message: _messageController.text.trim().isNotEmpty 
            ? _messageController.text.trim() 
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Urgent call sent successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending urgent call: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.notifications_active, color: Colors.red),
          SizedBox(width: 8),
          Text('Send Urgent Call'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select users to call urgently:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _allUsers.length,
                  itemBuilder: (context, index) {
                    final user = _allUsers[index];
                    final isSelected = _selectedUsers.contains(user);
                    
                    return CheckboxListTile(
                      title: Text(user.name),
                      subtitle: Text(user.mobile),
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedUsers.add(user);
                          } else {
                            _selectedUsers.remove(user);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message (Optional)',
                hintText: 'Add a message to the urgent call',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSending ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSending ? null : _sendUrgentCall,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isSending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Send Urgent Call'),
        ),
      ],
    );
  }
}

