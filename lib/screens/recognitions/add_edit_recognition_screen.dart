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

  @override
  void initState() {
    super.initState();
    if (widget.recognition != null) {
      _titleController.text = widget.recognition!.title;
      _descriptionController.text = widget.recognition!.description;
      _linkController.text = widget.recognition?.link ?? '';
      _imagePath = widget.recognition!.imageUrl;
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imagePath == null || _imagePath!.isEmpty) {
      Get.snackbar('Error', 'Please select an image');
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl = _imagePath;
      
      // Upload new image if it's a local file path
      if (_imagePath != null && !_imagePath!.startsWith('http')) {
        imageUrl = await _storageService.uploadFile(
          _imagePath!,
          'recognitions',
        );
      }

      final recognition = Recognition(
        id: widget.recognition?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl!,
        link: _linkController.text.trim().isNotEmpty ? _linkController.text.trim() : null,
        publishedDate: _publishDate!,
        createdBy: widget.recognition?.createdBy, // Will be set on the server if null
        createdAt: widget.recognition?.createdAt,
        updatedAt: DateTime.now(),
      );

      await _recognitionService.saveRecognition(recognition);
      
      if (mounted) {
        Get.back(result: true);
      }
    } catch (e) {
      debugPrint('Error saving recognition: $e');
      Get.snackbar('Error', 'Failed to save recognition');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.recognition == null ? 'Add Recognition' : 'Edit Recognition'),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _submitForm,
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
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image Picker
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: _imagePath == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Tap to add image'),
                                  ],
                                )
                              : _imagePath!.startsWith('http')
                                  ? Image.network(
                                      _imagePath!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : Image.file(
                                      File(_imagePath!),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                        ),
                      ),
                      const SizedBox(height: 16),
      
                      // Title Field
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
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
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
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
                      ListTile(
                        title: const Text('Publish Date'),
                        subtitle: Text(
                          _publishDate != null
                              ? '${_publishDate!.day}/${_publishDate!.month}/${_publishDate!.year}'
                              : 'Select date',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _selectDate,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      const SizedBox(height: 16),
      
                      // Link Field (Optional)
                      TextFormField(
                        controller: _linkController,
                        decoration: const InputDecoration(
                          labelText: 'Link (Optional)',
                          border: OutlineInputBorder(),
                          hintText: 'https://example.com',
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 24),
      
                      // Save Button
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
