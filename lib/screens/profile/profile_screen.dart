import 'package:flutter/material.dart';
import 'package:ktnsolutions/constants/profile_constants.dart';
import 'package:ktnsolutions/models/home_details.dart';
import 'package:ktnsolutions/services/home_details_service.dart';
import 'package:ktnsolutions/utils/profile_initializer.dart';
import 'package:ktnsolutions/widgets/user_profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final HomeDetailsService _homeDetailsService = HomeDetailsService();
  HomeDetails? _homeDetails;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _designationController = TextEditingController();
  final _firmNameController = TextEditingController();
  final _emailController = TextEditingController();
  final List<TextEditingController> _phoneControllers = [];
  final List<TextEditingController> _officeControllers = [];
  
  // Tab controller
  late TabController _tabController;

  // Default values - using constants from ProfileConstants

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _firmNameController.dispose();
    _emailController.dispose();
    for (var controller in _phoneControllers) {
      controller.dispose();
    }
    for (var controller in _officeControllers) {
      controller.dispose();
    }
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final homeDetails = await _homeDetailsService.getHomeDetails();
      
      setState(() {
        _homeDetails = homeDetails;
        _isLoading = false;
      });

      // Initialize form controllers with current data or defaults
      _initializeControllers();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  void _initializeControllers() {
    final data = _homeDetails;
    
    _nameController.text = data?.name.isNotEmpty == true ? data!.name : ProfileConstants.defaultName;
    _designationController.text = data?.designation.isNotEmpty == true ? data!.designation : ProfileConstants.defaultDesignation;
    _firmNameController.text = data?.firmName.isNotEmpty == true ? data!.firmName : ProfileConstants.defaultFirmName;
    _emailController.text = data?.email.isNotEmpty == true ? data!.email : ProfileConstants.defaultEmail;

    // Initialize phone controllers
    _phoneControllers.clear();
    final phoneNumbers = data?.phoneNumbers.isNotEmpty == true ? data!.phoneNumbers : ProfileConstants.defaultPhoneNumbers;
    for (String phone in phoneNumbers) {
      _phoneControllers.add(TextEditingController(text: phone));
    }

    // Initialize office controllers
    _officeControllers.clear();
    final offices = data?.offices.isNotEmpty == true ? data!.offices : ProfileConstants.defaultOffices;
    for (String office in offices) {
      _officeControllers.add(TextEditingController(text: office));
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
    
    if (!_isEditing) {
      // Reset controllers to current data when canceling edit
      _initializeControllers();
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Collect data from controllers
      final phoneNumbers = _phoneControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
      
      final offices = _officeControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      final updatedProfileData = ProfileData(
        name: _nameController.text.trim(),
        designation: _designationController.text.trim(),
        firmName: _firmNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumbers: phoneNumbers,
        offices: offices,
      );

      final updatedHomeDetails = HomeDetails(
        id: _homeDetails?.id ?? '',
        profileData: updatedProfileData,
        usersList: _homeDetails?.usersList ?? [],
        courtList: _homeDetails?.courtList ?? [],
        createdAt: _homeDetails?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _homeDetailsService.saveHomeDetails(updatedHomeDetails);
      
      setState(() {
        _homeDetails = updatedHomeDetails;
        _isEditing = false;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    }
  }

  void _addPhoneField() {
    setState(() {
      _phoneControllers.add(TextEditingController());
    });
  }

  void _removePhoneField(int index) {
    if (_phoneControllers.length > 1) {
      setState(() {
        _phoneControllers[index].dispose();
        _phoneControllers.removeAt(index);
      });
    }
  }

  void _addOfficeField() {
    setState(() {
      _officeControllers.add(TextEditingController());
    });
  }

  void _removeOfficeField(int index) {
    if (_officeControllers.length > 1) {
      setState(() {
        _officeControllers[index].dispose();
        _officeControllers.removeAt(index);
      });
    }
  }

  Future<void> _initializeProfileData() async {
    try {
      await ProfileInitializer.initializeProfileData();
      await _loadProfileData(); // Reload data after initialization
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile data initialized successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing profile data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        surfaceTintColor: Colors.transparent,
        actions: [
          if (_isEditing) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isSaving 
                        ? const Color(0xFF94A3B8).withOpacity(0.1)
                        : const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isSaving 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.save_rounded,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                ),
                onPressed: _isSaving ? null : _saveProfile,
                tooltip: 'Save',
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                ),
                onPressed: _isSaving ? null : _toggleEdit,
                tooltip: 'Cancel',
              ),
            ),
          ] else ...[
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                onPressed: _toggleEdit,
                tooltip: 'Edit Profile',
              ),
            ),
          ],
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF6366F1),
                    unselectedLabelColor: const Color(0xFF64748B),
                    indicatorColor: const Color(0xFF6366F1),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.person_outline),
                        text: 'Profile',
                      ),
                      Tab(
                        icon: Icon(Icons.people_outline),
                        text: 'Users',
                      ),
                      Tab(
                        icon: Icon(Icons.gavel_outlined),
                        text: 'Courts',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _isEditing ? _buildEditView() : _buildViewMode(),
                      _buildUsersView(),
                      _buildCourtsView(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading profile...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewMode() {
    final data = _homeDetails;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        children: [
          // Profile Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AdvocateProfile(
                name: data?.name.isNotEmpty == true ? data!.name : ProfileConstants.defaultName,
                designation: data?.designation.isNotEmpty == true ? data!.designation : ProfileConstants.defaultDesignation,
                firmName: data?.firmName.isNotEmpty == true ? data!.firmName : ProfileConstants.defaultFirmName,
                email: data?.email.isNotEmpty == true ? data!.email : ProfileConstants.defaultEmail,
                phoneNumbers: data?.phoneNumbers.isNotEmpty == true ? data!.phoneNumbers : ProfileConstants.defaultPhoneNumbers,
                offices: data?.offices.isNotEmpty == true ? data!.offices : ProfileConstants.defaultOffices,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Additional Info Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF6366F1),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Profile Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildModernInfoRow('Last Updated', _formatDate(data?.updatedAt ?? DateTime.now())),
                  const SizedBox(height: 12),
                  _buildModernInfoRow('Data Source', data != null ? 'Firestore' : 'Default'),
                  const SizedBox(height: 20),
                  if (data == null)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _initializeProfileData,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.cloud_upload_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Initialize Profile Data',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information
          _buildModernSection(
            'Basic Information',
            Icons.person_outline_rounded,
            [
              _buildModernTextField('Name', _nameController),
              _buildModernTextField('Designation', _designationController),
              _buildModernTextField('Firm Name', _firmNameController),
              _buildModernTextField('Email', _emailController, keyboardType: TextInputType.emailAddress),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Phone Numbers
          _buildModernSection(
            'Phone Numbers',
            Icons.phone_outlined,
            [
              ...List.generate(_phoneControllers.length, (index) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildModernTextField(
                        'Phone ${index + 1}',
                        _phoneControllers[index],
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    if (_phoneControllers.length > 1)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () => _removePhoneField(index),
                          icon: const Icon(Icons.remove_rounded, color: Color(0xFFEF4444)),
                          tooltip: 'Remove phone',
                        ),
                      ),
                  ],
                );
              }),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextButton.icon(
                  onPressed: _addPhoneField,
                  icon: const Icon(Icons.add_rounded, color: Color(0xFF10B981)),
                  label: const Text('Add Phone Number', style: TextStyle(color: Color(0xFF10B981))),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Offices
          _buildModernSection(
            'Office Addresses',
            Icons.location_on_outlined,
            [
              ...List.generate(_officeControllers.length, (index) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildModernTextField(
                        'Office ${index + 1}',
                        _officeControllers[index],
                        maxLines: 3,
                      ),
                    ),
                    if (_officeControllers.length > 1)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () => _removeOfficeField(index),
                          icon: const Icon(Icons.remove_rounded, color: Color(0xFFEF4444)),
                          tooltip: 'Remove office',
                        ),
                      ),
                  ],
                );
              }),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextButton.icon(
                  onPressed: _addOfficeField,
                  icon: const Icon(Icons.add_rounded, color: Color(0xFF10B981)),
                  label: const Text('Add Office Address', style: TextStyle(color: Color(0xFF10B981))),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Save Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isSaving
                    ? [
                        const Color(0xFF94A3B8),
                        const Color(0xFF94A3B8),
                      ]
                    : [
                        const Color(0xFF10B981),
                        const Color(0xFF059669),
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: _isSaving
                  ? null
                  : [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isSaving ? null : _saveProfile,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Saving...',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.save_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
        ),
      ),
    );
  }

  Widget _buildModernInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildUsersView() {
    final users = _homeDetails?.usersList ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        children: [
          // Users Header
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.people_outline,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Users List (${users.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Manage your team members and their admin privileges.',
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Users List
          ...users.map((user) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: user.isAdmin 
                    ? const Color(0xFF6366F1).withOpacity(0.1)
                    : const Color(0xFF10B981).withOpacity(0.1),
                child: Icon(
                  user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                  color: user.isAdmin ? const Color(0xFF6366F1) : const Color(0xFF10B981),
                  size: 20,
                ),
              ),
              title: Text(
                user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.mobile,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                  if (user.isAdmin)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Admin',
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCourtsView() {
    final courts = _homeDetails?.courtList ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        children: [
          // Courts Header
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.gavel_outlined,
                          color: Color(0xFFF59E0B),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Courts List (${courts.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Manage the list of courts where your firm practices.',
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Courts List
          ...courts.map((court) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.gavel_outlined,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              title: Text(
                court.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
