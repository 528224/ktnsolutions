import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ktnsolutions/models/recognition.dart';
import 'package:ktnsolutions/services/recognition_service.dart';
import 'package:ktnsolutions/services/storage_service.dart';
import 'dart:io';

class AddEditRecognitionScreen extends StatefulWidget {
  final Recognition? recognition;

  const AddEditRecognitionScreen({
    super.key,
    this.recognition,
  });

  @override
  State<AddEditRecognitionScreen> createState() => _AddEditRecognitionScreenState();
}

class _AddEditRecognitionScreenState extends State<AddEditRecognitionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  final _recognitionService = RecognitionService();
  final _storageService = StorageService();
  final _picker = ImagePicker();
  
  String? _imagePath;
  bool _isLoading = false;
  DateTime? _publishDate;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    if (widget.recognition != null) {
      _titleController.text = widget.recognition!.title;
      _descriptionController.text = widget.recognition!.description;
      _linkController.text = widget.recognition?.link ?? '';
      _imagePath = widget.recognition?.imageUrl;
      _publishDate = widget.recognition!.publishedDate;
    } else {
      _publishDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  bool _isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  String _getDomainFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return '${uri.host}${uri.path.isNotEmpty ? uri.path : ''}';
    } catch (e) {
      return url;
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Image Source'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text('Camera'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('Gallery'),
            ),
          ],
        ),
      );

      if (source != null) {
        final pickedFile = await _picker.pickImage(source: source);
        if (pickedFile != null) {
          setState(() {
            _imagePath = pickedFile.path;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  Future<void> _saveRecognition() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = _imagePath;
      
      // Only upload new image if it's a local file path (not a URL)
      if (_imagePath != null && _imagePath!.startsWith('/')) {
        imageUrl = await _storageService.uploadFile(
          _imagePath!,
          'recognitions',
        );
      }

      final recognition = Recognition(
        id: widget.recognition?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
        link: _linkController.text.trim().isNotEmpty ? _linkController.text.trim() : null,
        publishedDate: _publishDate!,
        createdBy: widget.recognition?.createdBy,
        createdAt: widget.recognition?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _recognitionService.saveRecognition(recognition);
      
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving recognition: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _publishDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _publishDate) {
      setState(() {
        _publishDate = picked;
      });
    }
  }

  void _togglePreview() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _showPreview = !_showPreview;
      });
    }
  }

  Widget _buildPreview() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_linkController.text.isNotEmpty) ...[
                  Expanded(
                    child: Text(
                      _getDomainFromUrl(_linkController.text),
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Text(
                  _publishDate != null 
                      ? '${_publishDate!.day}/${_publishDate!.month}/${_publishDate!.year}'
                      : 'No date',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _titleController.text.isNotEmpty 
                  ? _titleController.text 
                  : 'Title will appear here',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _descriptionController.text.isNotEmpty
                  ? _descriptionController.text
                  : 'Description will appear here',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (_imagePath != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: _imagePath!.startsWith('http')
                    ? Image.network(
                        _imagePath!,
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(_imagePath!),
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recognition Image (Optional)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_imagePath != null) ...[
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _imagePath!.startsWith('http')
                  ? Image.network(_imagePath!, fit: BoxFit.cover)
                  : Image.file(File(_imagePath!), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Change Image'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _imagePath = null;
                  });
                },
                child: const Text('Remove Image'),
              ),
            ],
          ),
        ] else
          OutlinedButton(
            onPressed: _pickImage,
            child: const Text('Add Image'),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.recognition == null ? 'Add Recognition' : 'Edit Recognition'),
          actions: [
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: _togglePreview,
              tooltip: 'Preview',
            ),
            TextButton(
              onPressed: _isLoading ? null : _saveRecognition,
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_showPreview) _buildPreview(),
                      
                      _buildImagePicker(),
      
                      // Title Field
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
      
                      // Description Field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: const OutlineInputBorder(),
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
      
                      // Publish Date Picker
                      TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: _publishDate != null
                              ? '${_publishDate!.day}/${_publishDate!.month}/${_publishDate!.year}'
                              : 'Select date',
                        ),
                        decoration: InputDecoration(
                          labelText: 'Publish Date',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[50],
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today, size: 20),
                            onPressed: _selectDate,
                          ),
                        ),
                        onTap: _selectDate,
                      ),
                      const SizedBox(height: 16),
      
                      // Link Field (Optional)
                      TextFormField(
                        controller: _linkController,
                        decoration: InputDecoration(
                          labelText: 'Link (Optional)',
                          border: const OutlineInputBorder(),
                          hintText: 'https://example.com',
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.url,
                        validator: (value) {
                          if (value != null && value.isNotEmpty && !_isValidUrl(value)) {
                            return 'Please enter a valid URL';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
      
                      // Save Button
                      ElevatedButton(
                        onPressed: _saveRecognition,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save Recognition'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
