import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../services/case_service.dart';

class AddCaseScreen extends StatefulWidget {
  const AddCaseScreen({super.key});

  @override
  State<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientNumberController = TextEditingController();

  // Posting fields
  final _postingTitleController = TextEditingController();
  DateTime? _postingDate;
  String? _selectedCourt;
  String? _selectedStaff;

  // Task fields
  final List<TaskFormData> _tasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Start with no tasks - user can add them if needed
  }

  @override
  void dispose() {
    _titleController.dispose();
    _clientNameController.dispose();
    _clientNumberController.dispose();
    _postingTitleController.dispose();
    // Dispose all task controllers
    for (var task in _tasks) {
      task.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Case'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveCase,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCaseDetailsSection(),
              const SizedBox(height: 24),
              _buildPostingSection(),
              const SizedBox(height: 24),
              _buildTasksSection(),
              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaseDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Case Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Case Title *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter case title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _clientNameController,
              decoration: const InputDecoration(
                labelText: 'Client Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter client name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _clientNumberController,
              decoration: const InputDecoration(
                labelText: 'Client Number *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter client number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'First Posting',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _postingTitleController,
              decoration: const InputDecoration(
                labelText: 'Posting Title',
                border: OutlineInputBorder(),
                hintText: 'Optional - leave blank if no posting yet',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCourt,
              decoration: const InputDecoration(
                labelText: 'Court',
                border: OutlineInputBorder(),
                hintText: 'Select court (optional)',
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('No court selected'),
                ),
                ...globalCourts.map((court) {
                  return DropdownMenuItem(
                    value: court.name,
                    child: Text(court.name),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCourt = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStaff,
              decoration: const InputDecoration(
                labelText: 'Staff',
                border: OutlineInputBorder(),
                hintText: 'Select staff (optional)',
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('No staff assigned'),
                ),
                ...globalUsers.map((user) {
                  return DropdownMenuItem(
                    value: user.name,
                    child: Text(user.name),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStaff = value;
                });
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectPostingDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Posting Date',
                  border: OutlineInputBorder(),
                  hintText: 'Optional - select date if posting exists',
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _postingDate != null
                          ? DateFormat('MMM dd, yyyy').format(_postingDate!)
                          : 'Select Date (Optional)',
                      style: TextStyle(
                        color: _postingDate != null
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tasks (${_tasks.length})',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (_tasks.isNotEmpty)
                      IconButton(
                        onPressed: _clearAllTasks,
                        icon: const Icon(Icons.clear_all, color: Colors.red),
                        tooltip: 'Clear All Tasks',
                      ),
                    IconButton(
                      onPressed: _addTask,
                      icon: const Icon(Icons.add),
                      tooltip: 'Add Task',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tasks are optional. Add as many as needed.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            if (_tasks.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No tasks added yet',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap + to add your first task',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._tasks.asMap().entries.map((entry) {
                final index = entry.key;
                final task = entry.value;
                return _buildTaskForm(index, task);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskForm(int index, TaskFormData task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Task ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (_tasks.length > 1)
                  IconButton(
                    onPressed: () => _removeTask(index),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Remove Task',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: task.titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
                hintText: 'Enter task description',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter task title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: task.selectedStaff,
              decoration: const InputDecoration(
                labelText: 'Assigned Staff',
                border: OutlineInputBorder(),
                hintText: 'Select staff (optional)',
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('No staff assigned'),
                ),
                ...globalUsers.map((user) {
                  return DropdownMenuItem(
                    value: user.name,
                    child: Text(user.name),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  task.selectedStaff = value;
                });
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectTaskDueDate(index),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Due Date',
                  border: OutlineInputBorder(),
                  hintText: 'Select due date (optional)',
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task.dueDate != null
                          ? DateFormat('MMM dd, yyyy').format(task.dueDate!)
                          : 'Select Date (Optional)',
                      style: TextStyle(
                        color: task.dueDate != null
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectPostingDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _postingDate = date;
      });
    }
  }

  void _selectTaskDueDate(int index) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _tasks[index].dueDate = date;
      });
    }
  }

  void _addTask() {
    setState(() {
      _tasks.add(TaskFormData());
    });
  }

  void _removeTask(int index) {
    setState(() {
      _tasks[index].dispose();
      _tasks.removeAt(index);
    });
  }

  void _clearAllTasks() {
    setState(() {
      for (var task in _tasks) {
        task.dispose();
      }
      _tasks.clear();
    });
  }

  Future<void> _saveCase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if posting is partially filled (if any posting field is filled, all should be filled)
    final hasPostingTitle = _postingTitleController.text.trim().isNotEmpty;
    final hasPostingCourt = _selectedCourt != null;
    final hasPostingStaff = _selectedStaff != null;
    final hasPostingDate = _postingDate != null;

    if (hasPostingTitle || hasPostingCourt || hasPostingStaff || hasPostingDate) {
      // If any posting field is filled, all should be filled
      if (!hasPostingTitle || !hasPostingCourt || !hasPostingStaff || !hasPostingDate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all posting fields or leave all empty'),
          ),
        );
        return;
      }
    }

    // Validate tasks - if task title is filled, due date should be filled too
    for (int i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      final hasTaskTitle = task.titleController.text.trim().isNotEmpty;
      final hasTaskDueDate = task.dueDate != null;

      if (hasTaskTitle && !hasTaskDueDate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select due date for Task ${i + 1} or remove the task')),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create posting only if all fields are filled
      Posting? posting;
      if (hasPostingTitle && hasPostingCourt && hasPostingStaff && hasPostingDate) {
        posting = Posting(
          id: Uuid().v4(), // Will be set by Firestore
          title: _postingTitleController.text.trim(),
          date: _postingDate!,
          staff: _selectedStaff!,
          court: _selectedCourt!,
        );
      }

      // Create tasks only for those with complete data
      final tasks = _tasks
          .where((taskData) => 
              taskData.titleController.text.trim().isNotEmpty && 
              taskData.dueDate != null)
          .map((taskData) {
        return Task(
          id: Uuid().v4(),
          title: taskData.titleController.text.trim(),
          staff: taskData.selectedStaff ?? 'Unassigned',
          dueDate: taskData.dueDate!,
        );
      }).toList();

      // Create legal case
      final legalCase = LegalCase(
        id: '', // Will be set by Firestore
        title: _titleController.text.trim(),
        previousPostings: [],
        nextPosting: posting,
        clientName: _clientNameController.text.trim(),
        clientNumber: _clientNumberController.text.trim(),
        tasks: tasks,
      );

      // Save to Firestore
      await CaseService.addCase(legalCase);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Case added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class TaskFormData {
  final TextEditingController titleController = TextEditingController();
  String? selectedStaff;
  DateTime? dueDate;

  void dispose() {
    titleController.dispose();
  }
}
