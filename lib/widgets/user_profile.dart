import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdvocateProfile extends StatefulWidget {
  final String name;
  final String designation;
  final String firmName;
  final String email;
  final List<String> phoneNumbers; // multiple phones
  final List<String> offices; // multiple offices

  const AdvocateProfile({
    super.key,
    required this.name,
    required this.designation,
    required this.firmName,
    required this.email,
    required this.phoneNumbers,
    required this.offices,
  });

  @override
  State<AdvocateProfile> createState() => _AdvocateProfileState();
}

class _AdvocateProfileState extends State<AdvocateProfile> {
  bool _expanded = true;

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $url");
    }
  }

  Widget _buildPhoneRow(String phone) {
    return Wrap(
      spacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(Icons.phone, color: Colors.green[700]),
        GestureDetector(
          onTap: () => _launchUrl("tel:$phone"),
          child: Text(phone, style: const TextStyle(fontSize: 16)),
        ),
        IconButton(
          icon: const Icon(Icons.message, color: Colors.teal),
          onPressed: () => _launchUrl("https://wa.me/$phone"),
        ),
      ],
    );
  }

  Widget _buildOfficeRow(String office) {
    return GestureDetector(
      onTap: () => _launchUrl(
          "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(office)}"),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on, color: Colors.redAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              office,
              style: const TextStyle(fontSize: 16, decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header with expand/collapse button
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                )
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 4),
              Text(widget.designation,
                  style: const TextStyle(
                      fontSize: 16, fontStyle: FontStyle.italic)),
              Text(widget.firmName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              const Divider(height: 24),

              // Phones
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.phoneNumbers.map(_buildPhoneRow).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // Email
              Row(
                children: [
                  const Icon(Icons.email, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _launchUrl("mailto:${widget.email}"),
                    child: Text(widget.email,
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            decoration: TextDecoration.underline)),
                  )
                ],
              ),
              const SizedBox(height: 16),

              // Offices
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.offices.map(_buildOfficeRow).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
