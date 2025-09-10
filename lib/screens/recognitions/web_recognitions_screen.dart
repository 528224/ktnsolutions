import 'package:flutter/material.dart';
import 'package:ktnsolutions/models/recognition.dart';
import 'package:ktnsolutions/services/recognition_service.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../rich_text_with_multiple_color.dart';
import '../../widgets/user_profile.dart';

class WebRecognitionsScreen extends StatelessWidget {
  final RecognitionService _recognitionService = RecognitionService();

  WebRecognitionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        // appBar: AppBar(
        //   title: const Text('Our Recognitions'),
        //   centerTitle: true,
        //   elevation: 0,
        //   backgroundColor: Colors.white,
        //   foregroundColor: Colors.black87,
        // ),
        body: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child:
          SingleChildScrollView(
            child: Column(children: [
                AdvocateProfile(
                  name: "Adv. PRABHU K N",
                  designation: "Supreme Court & All High Courts",
                  firmName: "KTN Solutions Lawyers",
                  email: "ktnsolutionslawyers@gmail.com",
                  phoneNumbers: ["9388118177", "9544322000"],
                  offices: [
                    "Chamber No.D 422, D Block, Additional Building Complex, Supreme Court, New Delhi - 110 001",
                    "4th Floor, Peace Tower, Opp North Gate Of Collectorate & District Panchayath Ayyanthole, Thrissur - 680 003",
                    "2nd Floor, Delma Express, Opposite Cherupushpam Girls Higher Secondary School, Vadakkencherry, Palakkad - 678 683",
                  ],
                ),
                FutureBuilder<List<Recognition>>(
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
                        shrinkWrap: true, // let it fit inside parent ListView
                        physics: NeverScrollableScrollPhysics(), // Disable inner scrolling
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                        itemCount: recognitions.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16.0),
                        itemBuilder: (context, index) {
                          return _buildRecognitionCard(recognitions[index], context);
                        },
                      );
                    },
                  ),
              ],)
          ),
        ),
      ),
    );
  }

  Widget _buildRecognitionCard(Recognition recognition, BuildContext context) {
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
                    // Left: favicon + titles
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                        width: 32,
                                        height: 32,
                                        errorBuilder: (context, error, stackTrace) => 
                                            const Icon(Icons.public, size: 20, color: Colors.grey),
                                      ),
                                    )
                                  : const Icon(Icons.public, size: 20, color: Colors.grey),
                            ),
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
                    // Right: date
                    Text(
                      recognition.formattedDate,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
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

              // Image if available
              if (recognition.imageUrl != null && recognition.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    recognition.imageUrl!,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300,
                      color: Colors.grey[100],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],

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
                        onTap: (item.link).trim().isNotEmpty ? () => _launchURL(item.link) : null,
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

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
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
