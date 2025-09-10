import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ktnsolutions/models/recognition.dart';
import 'package:ktnsolutions/rich_text_with_multiple_color.dart';
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
        body: FutureBuilder<List<Recognition>>(
          future: _recognitionService.getRecognitions(), // 👈 now returns Future
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading recognitions: ${snapshot.error}'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final recognitions = snapshot.data ?? [];

            if (recognitions.isEmpty) {
              return const Center(
                child: Text('No recognitions available at the moment'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
              itemCount: recognitions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16.0),
              itemBuilder: (context, index) {
                return _buildRecognitionCard(recognitions[index]);
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
              // Source info row with date inline on right (or date top-right when no link)
              if (recognition.hasValidLink) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: favicon + titles
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                      width: 32,
                                      height: 32,
                                      errorBuilder: (context, error, stackTrace) => 
                                          const Icon(Icons.public, size: 20, color: Colors.grey),
                                    ),
                                  )
                                : const Icon(Icons.public, size: 20, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (recognition.sourceTitle != null)
                                  Text(
                                    recognition.sourceTitle!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right: published date
                    Text(
                      recognition.formattedDate,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),

                    if (_isAdmin)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: PopupMenuButton<String>(
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _navigateToAddEditRecognition(recognition: recognition);
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(recognition);
                            }
                          },
                          icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (!recognition.hasValidLink) ...[
                Row(
                  children: [
                    const Spacer(),
                    Text(
                      recognition.formattedDate,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (_isAdmin)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: PopupMenuButton<String>(
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _navigateToAddEditRecognition(recognition: recognition);
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(recognition);
                            }
                          },
                          icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              getRunningMultiColorText(recognition.title, isMulticolor: true,
                  isRunning: false, subTextColors: recognition.titleSubTextColors??[],
                  textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
              
              const SizedBox(height: 8),
              
              // Description
              if (recognition.description.isNotEmpty)
                getRunningMultiColorText(recognition.description, isMulticolor: true,
                    isRunning: false, subTextColors: recognition.descSubTextColors??[],
                  textStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          height: 1.4,),),

              const SizedBox(height: 12),
              
              // Image if available
              if (recognition.imageUrl != null && recognition.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    recognition.imageUrl!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey[100],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(height: 12),

              // Items with Link buttons (bottom of card)
              if ((recognition.itemsWithLink ?? []).isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in recognition.itemsWithLink!)
                      _ItemLinkButton(
                        title: (item.name).isNotEmpty ? item.name : 'Open',
                        url: item.link,
                        onTap: (item.link).trim().isNotEmpty ? () => launchUrlString(item.link) : null,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              
              // Bottom row removed (View Source deleted)
            ],
          ),
        ),
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

class _ItemLinkButton extends StatelessWidget {
  final String title;
  final String url;
  final VoidCallback? onTap;

  const _ItemLinkButton({required this.title, required this.url, this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5)),
      ),
      icon: const Icon(Icons.link, size: 16),
      label: Text(title, overflow: TextOverflow.ellipsis),
    );
  }
}
