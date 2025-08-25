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
        appBar: AppBar(
          title: const Text('Our Recognitions'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        body: Container(
          color: Colors.grey[50],
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
      
              return LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 1200 
                      ? 3 
                      : constraints.maxWidth > 800 ? 2 : 1;
                  
                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.8,
                      mainAxisExtent: 400, // Fixed height for all cards
                    ),
                    itemCount: recognitions.length,
                    itemBuilder: (context, index) {
                      return _buildRecognitionCard(recognitions[index]);
                    },
                  );
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: recognition.link != null && recognition.link!.isNotEmpty
            ? () => _launchURL(recognition.link!)
            : null,
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 7,
              child: _buildImageWidget(recognition),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      recognition.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recognition.description,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (recognition.link != null && recognition.link!.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'View Details →',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(Recognition recognition) {
    if (recognition.imageUrl.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
      child: getRemoteImageForWeb(recognition.imageUrl,),
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

getRemoteImageForWeb(String url) {
  return OctoImage(
    image: NetworkImage(url),
    progressIndicatorBuilder: (context, progress) {
      double? value;
      var expectedBytes = progress?.expectedTotalBytes;
      if (progress != null && expectedBytes != null) {
        value = progress.cumulativeBytesLoaded / expectedBytes;
      }
      return Center(child: CircularProgressIndicator(value: value));
    },
    errorBuilder: (context, error, stacktrace) {
      return Icon(Icons.error);
      },
  );
}
