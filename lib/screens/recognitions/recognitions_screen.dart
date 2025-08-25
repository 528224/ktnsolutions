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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recognitions'),
          elevation: 0,
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: recognitions.length,
                itemBuilder: (context, index) {
                  final recognition = recognitions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildRecognitionCard(recognition),
                  );
                },
              );
            },
        ),
        floatingActionButton: _isAdmin
            ? Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: FloatingActionButton(
                  onPressed: _navigateToAddEditRecognition,
                  child: const Icon(Icons.add),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildRecognitionCard(Recognition recognition) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: recognition.hasValidLink ? () => launchUrlString(recognition.link!) : null,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Favicon and source info row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rounded favicon container
                  if (recognition.hasValidLink)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: recognition.faviconUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(
                                recognition.faviconUrl!,
                                width: 20,
                                height: 20,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.public,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.public,
                              size: 20,
                              color: Colors.grey,
                            ),
                    ),
                  
                  const SizedBox(width: 12),
                  
                  // Domain and URL column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display Name (formatted domain)
                        if (recognition.sourceTitle != null)
                          Text(
                            recognition.sourceTitle!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        
                        // Domain URL
                        if (recognition.sourceSubTitle != null)
                          Text(
                            recognition.sourceSubTitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  
                  // Date
                  Text(
                    recognition.formattedDate,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  
                  // Admin options
                  if (_isAdmin) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showRecognitionOptions(recognition),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Title
              Text(
                recognition.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Description
              Text(
                recognition.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Image (if available)
              if (recognition.imageUrl.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Image.network(
                    recognition.imageUrl,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 140,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getDomainFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return '${uri.host}${uri.path.isNotEmpty ? uri.path : ''}';
    } catch (e) {
      return url;
    }
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
