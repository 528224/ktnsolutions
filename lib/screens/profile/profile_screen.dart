import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ktnsolutions/models/home_details.dart';
import 'package:ktnsolutions/services/home_details_service.dart';
import 'package:ktnsolutions/utils/profile_initializer.dart';
import 'package:ktnsolutions/widgets/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  // Default values
  static const String _defaultName = "Adv. PRABHU K N";
  static const String _defaultDesignation = "Supreme Court & All High Courts";
  static const String _defaultFirmName = "KTN Solutions Lawyers";
  static const String _defaultEmail = "ktnsolutionslawyers@gmail.com";
  static const List<String> _defaultPhoneNumbers = ["9388118177", "9544322000"];
  static const List<String> _defaultOffices = [
    "Chamber No.D 422, D Block, Additional Building Complex, Supreme Court, New Delhi - 110 001",
    "4th Floor, Peace Tower, Opp North Gate Of Collectorate & District Panchayath Ayyanthole, Thrissur - 680 003",
    "2nd Floor, Delma Express, Opposite Cherupushpam Girls Higher Secondary School, Vadakkencherry, Palakkad - 678 683",
  ];

  @override
  void initState() {
    super.initState();
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
    
    _nameController.text = data?.name.isNotEmpty == true ? data!.name : _defaultName;
    _designationController.text = data?.designation.isNotEmpty == true ? data!.designation : _defaultDesignation;
    _firmNameController.text = data?.firmName.isNotEmpty == true ? data!.firmName : _defaultFirmName;
    _emailController.text = data?.email.isNotEmpty == true ? data!.email : _defaultEmail;

    // Initialize phone controllers
    _phoneControllers.clear();
    final phoneNumbers = data?.phoneNumbers.isNotEmpty == true ? data!.phoneNumbers : _defaultPhoneNumbers;
    for (String phone in phoneNumbers) {
      _phoneControllers.add(TextEditingController(text: phone));
    }

    // Initialize office controllers
    _officeControllers.clear();
    final offices = data?.offices.isNotEmpty == true ? data!.offices : _defaultOffices;
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

      final updatedHomeDetails = HomeDetails(
        id: _homeDetails?.id ?? '',
        name: _nameController.text.trim(),
        designation: _designationController.text.trim(),
        firmName: _firmNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumbers: phoneNumbers,
        offices: offices,
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
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isEditing) ...[
            IconButton(
              onPressed: _isSaving ? null : _saveProfile,
              icon: _isSaving 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
              tooltip: 'Save',
            ),
            IconButton(
              onPressed: _isSaving ? null : _toggleEdit,
              icon: const Icon(Icons.close),
              tooltip: 'Cancel',
            ),
          ] else ...[
            IconButton(
              onPressed: _toggleEdit,
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profile',
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isEditing
              ? _buildEditView()
              : _buildViewMode(),
    );
  }

  Widget _buildViewMode() {
    final data = _homeDetails;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Card
          AdvocateProfile(
            name: data?.name.isNotEmpty == true ? data!.name : _defaultName,
            designation: data?.designation.isNotEmpty == true ? data!.designation : _defaultDesignation,
            firmName: data?.firmName.isNotEmpty == true ? data!.firmName : _defaultFirmName,
            email: data?.email.isNotEmpty == true ? data!.email : _defaultEmail,
            phoneNumbers: data?.phoneNumbers.isNotEmpty == true ? data!.phoneNumbers : _defaultPhoneNumbers,
            offices: data?.offices.isNotEmpty == true ? data!.offices : _defaultOffices,
          ),
          
          const SizedBox(height: 24),
          
          // Additional Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Last Updated', _formatDate(data?.updatedAt ?? DateTime.now())),
                  const SizedBox(height: 8),
                  _buildInfoRow('Data Source', data != null ? 'Firestore' : 'Default'),
                  const SizedBox(height: 16),
                  if (data == null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _initializeProfileData,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Initialize Profile Data'),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information
          _buildSection(
            'Basic Information',
            [
              _buildTextField('Name', _nameController),
              _buildTextField('Designation', _designationController),
              _buildTextField('Firm Name', _firmNameController),
              _buildTextField('Email', _emailController, keyboardType: TextInputType.emailAddress),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Phone Numbers
          _buildSection(
            'Phone Numbers',
            [
              ...List.generate(_phoneControllers.length, (index) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Phone ${index + 1}',
                        _phoneControllers[index],
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    if (_phoneControllers.length > 1)
                      IconButton(
                        onPressed: () => _removePhoneField(index),
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        tooltip: 'Remove phone',
                      ),
                  ],
                );
              }),
              TextButton.icon(
                onPressed: _addPhoneField,
                icon: const Icon(Icons.add),
                label: const Text('Add Phone Number'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Offices
          _buildSection(
            'Office Addresses',
            [
              ...List.generate(_officeControllers.length, (index) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Office ${index + 1}',
                        _officeControllers[index],
                        maxLines: 3,
                      ),
                    ),
                    if (_officeControllers.length > 1)
                      IconButton(
                        onPressed: () => _removeOfficeField(index),
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        tooltip: 'Remove office',
                      ),
                  ],
                );
              }),
              TextButton.icon(
                onPressed: _addOfficeField,
                icon: const Icon(Icons.add),
                label: const Text('Add Office Address'),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Saving...'),
                      ],
                    )
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
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
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
