import 'package:flutter/material.dart';
import 'package:ktnsolutions/constants/profile_constants.dart';
import 'package:ktnsolutions/models/recognition.dart';
import 'package:ktnsolutions/models/home_details.dart';
import 'package:ktnsolutions/services/recognition_service.dart';
import 'package:ktnsolutions/services/home_details_service.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../rich_text_with_multiple_color.dart';

class WebRecognitionsScreen extends StatelessWidget {
  final RecognitionService _recognitionService = RecognitionService();
  final HomeDetailsService _homeDetailsService = HomeDetailsService();

  WebRecognitionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Enhanced Profile Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFF1F5F9),
                    const Color(0xFFE2E8F0),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  child: Column(
                    children: [
                      // Profile Header Content
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildAdvocateProfileWithFallback(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Recognitions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.emoji_events_rounded,
                              color: Color(0xFF6366F1),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Recent Recognitions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      FutureBuilder<List<Recognition>>(
                          future: _recognitionService.getRecognitions(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return _buildErrorState(snapshot.error.toString());
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return _buildLoadingState();
                            }

                            final recognitions = snapshot.data ?? [];

                            if (recognitions.isEmpty) {
                              return _buildEmptyState();
                            }

                            return Column(
                              children: recognitions.asMap().entries.map((entry) {
                                final index = entry.key;
                                final recognition = entry.value;
                                return Container(
                                  margin: EdgeInsets.only(
                                    bottom: index < recognitions.length - 1 ? 24 : 0,
                                  ),
                                  child: _buildModernRecognitionCard(recognition, context),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvocateProfileWithFallback() {
    // Using constants from ProfileConstants

    return FutureBuilder<HomeDetails?>(
      future: _homeDetailsService.getHomeDetails(),
      builder: (context, snapshot) {
        // Always show default values immediately, update with Firestore data when available
        String name = ProfileConstants.defaultName;
        String designation = ProfileConstants.defaultDesignation;
        String firmName = ProfileConstants.defaultFirmName;
        String email = ProfileConstants.defaultEmail;
        List<String> phoneNumbers = ProfileConstants.defaultPhoneNumbers;
        List<String> offices = ProfileConstants.defaultOffices;

        // Update with Firestore data if available and no errors
        if (snapshot.hasData && snapshot.data != null && !snapshot.hasError) {
          final homeDetails = snapshot.data!;
          name = homeDetails.name.isNotEmpty ? homeDetails.name : ProfileConstants.defaultName;
          designation = homeDetails.designation.isNotEmpty ? homeDetails.designation : ProfileConstants.defaultDesignation;
          firmName = homeDetails.firmName.isNotEmpty ? homeDetails.firmName : ProfileConstants.defaultFirmName;
          email = homeDetails.email.isNotEmpty ? homeDetails.email : ProfileConstants.defaultEmail;
          phoneNumbers = homeDetails.phoneNumbers.isNotEmpty ? homeDetails.phoneNumbers : ProfileConstants.defaultPhoneNumbers;
          offices = homeDetails.offices.isNotEmpty ? homeDetails.offices : ProfileConstants.defaultOffices;
        }

        return _buildEnhancedProfileCard(
          name: name,
          designation: designation,
          firmName: firmName,
          email: email,
          phoneNumbers: phoneNumbers,
          offices: offices,
        );
      },
    );
  }

  Widget _buildEnhancedProfileCard({
    required String name,
    required String designation,
    required String firmName,
    required String email,
    required List<String> phoneNumbers,
    required List<String> offices,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Row(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Profile Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        designation,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          firmName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Contact Information Grid
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Email Row
                    _buildContactRow(
                      icon: Icons.email_rounded,
                      label: 'Email',
                      value: email,
                      onTap: () => _launchURL('mailto:$email'),
                    ),
                    
                    // Phone Numbers - Show all with WhatsApp option
                    ...phoneNumbers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final phone = entry.value;
                      return Column(
                        children: [
                          if (index > 0) const SizedBox(height: 16),
                          _buildPhoneContactRow(
                            label: phoneNumbers.length > 1 ? 'Phone ${index + 1}' : 'Phone',
                            value: phone,
                            phoneNumber: phone,
                          ),
                        ],
                      );
                    }).toList(),
                    
                    // Office Addresses - Show all
                    ...offices.asMap().entries.map((entry) {
                      final index = entry.key;
                      final office = entry.value;
                      return Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildContactRow(
                            icon: Icons.location_on_rounded,
                            label: offices.length > 1 ? 'Office ${index + 1}' : 'Office',
                            value: office,
                            onTap: () => _launchURL(
                              'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(office)}',
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r"\s+")).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return "";
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneContactRow({
    required String label,
    required String value,
    required String phoneNumber,
  }) {
    return InkWell(
      onTap: () => _launchURL('tel:$phoneNumber'),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.phone_rounded,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Action icons on the right
            Row(
              children: [
                _buildIconButton(
                  icon: Icons.call_rounded,
                  color: const Color(0xFF10B981),
                  onTap: () => _launchURL('tel:$phoneNumber'),
                  tooltip: 'Call',
                ),
                const SizedBox(width: 8),
                _buildIconButton(
                  icon: Icons.chat_rounded,
                  color: const Color(0xFF25D366),
                  onTap: () => _launchURL('https://wa.me/$phoneNumber'),
                  tooltip: 'WhatsApp',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading recognitions...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFEF4444),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to load recognitions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.star_outline_rounded,
              color: Color(0xFF6366F1),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No recognitions available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for new recognitions and achievements.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernRecognitionCard(Recognition recognition, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: recognition.hasValidLink ? () => _launchURL(recognition.link!) : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with source info and date
                Row(
                  children: [
                    // Source info
                    if (recognition.hasValidLink) ...[
                      Expanded(
                        child: Row(
                          children: [
                            // Favicon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              child: recognition.faviconUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        recognition.faviconUrl!,
                                        width: 36,
                                        height: 36,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => 
                                            const Icon(
                                              Icons.public_rounded,
                                              size: 20,
                                              color: Color(0xFF64748B),
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.public_rounded,
                                      size: 20,
                                      color: Color(0xFF64748B),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            // Source title and subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (recognition.sourceTitle != null)
                                    Text(
                                      recognition.sourceTitle!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Color(0xFF1E293B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  if (recognition.sourceSubTitle != null)
                                    Text(
                                      recognition.sourceSubTitle!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
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
                      const SizedBox(width: 16),
                    ],
                    // Date badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        recognition.formattedDate,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Title
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: getRunningMultiColorText(
                    recognition.title,
                    isMulticolor: true,
                    isRunning: false,
                    subTextColors: recognition.titleSubTextColors ?? [],
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      height: 1.3,
                    ),
                  ),
                ),

                // Images if available
                if (recognition.imageUrls != null && recognition.imageUrls!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  if (recognition.imageUrls!.length == 1) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        recognition.imageUrls!.first,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_rounded,
                                  size: 48,
                                  color: Color(0xFF94A3B8),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Image unavailable',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Multiple images - modern horizontal scroll
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recognition.imageUrls!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(
                              right: index < recognition.imageUrls!.length - 1 ? 12 : 0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                recognition.imageUrls![index],
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image_rounded,
                                      size: 32,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],

                // Description
                if (recognition.description.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: getRunningMultiColorText(
                      recognition.description,
                      isMulticolor: true,
                      isRunning: false,
                      subTextColors: recognition.descSubTextColors ?? [],
                      textStyle: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],

                // Action buttons
                if ((recognition.itemsWithLink ?? []).isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final item in recognition.itemsWithLink!)
                        _ModernLinkButton(
                          title: item.name.isNotEmpty ? item.name : 'Open',
                          url: item.link,
                          onTap: item.link.trim().isNotEmpty ? () => _launchURL(item.link) : null,
                        ),
                    ],
                  ),
                ],
              ],
            ),
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

class _ModernLinkButton extends StatelessWidget {
  final String title;
  final String url;
  final VoidCallback? onTap;

  const _ModernLinkButton({required this.title, required this.url, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: onTap != null
              ? [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                ]
              : [
                  const Color(0xFF94A3B8),
                  const Color(0xFF94A3B8),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: onTap != null
            ? [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: onTap != null ? Colors.white : const Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: onTap != null ? Colors.white : const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
