import 'package:flutter/material.dart';
import 'package:ktnsolutions/models/recognition.dart';
import 'package:ktnsolutions/services/recognition_service.dart';
import 'package:octo_image/octo_image.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WebRecognitionsScreen extends StatelessWidget {
  final RecognitionService _recognitionService = RecognitionService();

  WebRecognitionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Our Recognitions'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        body: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: StreamBuilder<List<Recognition>>(
            stream: _recognitionService.getRecognitions(),
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
        ),
      ),
    );
  }

  Widget _buildRecognitionCard(Recognition recognition) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: recognition.hasValidLink ? () => _launchURL(recognition.link!) : null,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Source info row with favicon and URL
              if (recognition.hasValidLink) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rounded favicon container
                    GestureDetector(
                      onTap: recognition.sourceUrl != null
                          ? () => _launchURL(recognition.sourceUrl!)
                          : null,
                      child: Container(
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
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Title
              Text(
                recognition.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[700],
                  height: 1.3,
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
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Image (if available)
              if (recognition.imageUrl.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: getRemoteImageForWeb(recognition.imageUrl),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }
}

Widget getRemoteImageForWeb(String url) {
  return OctoImage(
    width: double.infinity,
    height: 200,
    fit: BoxFit.cover,
    image: NetworkImage(url),
    progressIndicatorBuilder: (context, progress) {
      double? value;
      var expectedBytes = progress?.expectedTotalBytes;
      if (progress != null && expectedBytes != null) {
        value = progress.cumulativeBytesLoaded / expectedBytes;
      }
      return Container(
        height: 200,
        color: Colors.grey[100],
        child: Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(value: value),
          ),
        ),
      );
    },
    errorBuilder: (context, error, stacktrace) {
      return Container(
        height: 200,
        color: Colors.grey[100],
        child: const Center(
          child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
        ),
      );
    },
  );
}
