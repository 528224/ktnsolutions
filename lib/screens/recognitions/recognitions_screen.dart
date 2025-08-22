import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ktnsolutions/models/recognition.dart';
import 'package:ktnsolutions/screens/recognitions/add_edit_recognition_screen.dart';
import 'package:ktnsolutions/services/recognition_service.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RecognitionsScreen extends StatefulWidget {
  const RecognitionsScreen({super.key});

  @override
  State<RecognitionsScreen> createState() => _RecognitionsScreenState();
}

class _RecognitionsScreenState extends State<RecognitionsScreen> {
  final RecognitionService _recognitionService = RecognitionService();
  final bool _isAdmin = true; // TODO: Get from auth service

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recognitions'),
      ),
      body: StreamBuilder<List<Recognition>>(
        stream: _recognitionService.getRecognitions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final recognitions = snapshot.data ?? [];

          if (recognitions.isEmpty) {
            return const Center(child: Text('No recognitions found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: recognitions.length,
            itemBuilder: (context, index) {
              final recognition = recognitions[index];
              return _buildRecognitionCard(recognition);
            },
          );
        },
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () => _navigateToAddEditRecognition(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildRecognitionCard(Recognition recognition) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      child: InkWell(
        onTap: () {
          if (recognition.link != null) {
            launchUrlString(recognition.link!);
          }
        },
        onLongPress: _isAdmin ? () => _showRecognitionOptions(recognition) : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recognition.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    recognition.imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                recognition.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                recognition.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Published: ${_formatDate(recognition.publishedDate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              if (recognition.link != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Tap to view more',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showRecognitionOptions(Recognition recognition) {
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
              _navigateToAddEditRecognition(recognition: recognition);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(recognition);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Recognition recognition) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recognition'),
        content: const Text('Are you sure you want to delete this recognition?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _recognitionService.deleteRecognition(recognition.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddEditRecognition({Recognition? recognition}) {
    Get.to(
      () => AddEditRecognitionScreen(recognition: recognition),
      fullscreenDialog: true,
    );
  }
}
