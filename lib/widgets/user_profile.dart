import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:characters/characters.dart';
import 'package:flutter/services.dart';

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

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r"\s+")).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return "";
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

  void _copyToClipboard(String text, {required String label}) {
    Clipboard.setData(ClipboardData(text: text));
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('$label copied to clipboard'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildPhoneRow(String phone) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: GestureDetector(
        onTap: (){_copyToClipboard(phone, label: 'Phone');},
        child: CircleAvatar(
          radius: isMobile ? 14 : 18,
          backgroundColor: Colors.green.withOpacity(0.12),
          child: Icon(Icons.phone, color: Colors.green, size: isMobile ? 16 : 20),
        ),
      ),
      title: Text(phone, style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.w600)),
      subtitle: isMobile ? null : Text("Tap icons to Call or WhatsApp", style: TextStyle(fontSize: isMobile ? 11 : 12)),
      trailing: Wrap(
        spacing: isMobile ? 4 : 8,
        children: [
          Tooltip(
            message: "Copy",
            child: IconButton(
              onPressed: () => _copyToClipboard(phone, label: 'Phone'),
              icon: Icon(Icons.copy_rounded, size: isMobile ? 18 : 20),
            ),
          ),
          if(!isMobile)
          Tooltip(
            message: "Call",
            child: IconButton(
              onPressed: () => _launchUrl("tel:$phone"),
              icon: Icon(Icons.call, size: isMobile ? 18 : 20),
              color: Colors.green[700],
            ),
          ),
          Tooltip(
            message: "WhatsApp",
            child: IconButton(
              onPressed: () => _launchUrl("https://wa.me/$phone"),
              icon: Icon(Icons.chat_rounded, size: isMobile ? 18 : 20),
              color: Colors.teal[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeRow(String office) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: isMobile ? 14 : 18,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        child: Icon(Icons.location_on, color: Colors.redAccent, size: isMobile ? 16 : 20),
      ),
      title: Text(
        office,
        style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.w600),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(isMobile ? "Tap to open Maps" : "Open in Maps or copy", style: TextStyle(fontSize: isMobile ? 11 : 12)),
      onTap: () => _launchUrl(
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(office)}",
      ),
      trailing: Wrap(
        spacing: isMobile ? 4 : 8,
        children: [
          Tooltip(
            message: "Copy",
            child: IconButton(
              onPressed: () => _copyToClipboard(office, label: 'Address'),
              icon: Icon(Icons.copy_rounded, size: isMobile ? 18 : 20),
            ),
          ),
          Tooltip(
            message: "Open Maps",
            child: IconButton(
              onPressed: () => _launchUrl(
                "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(office)}",
              ),
              icon: Icon(Icons.directions_outlined, size: isMobile ? 18 : 20),
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 600;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 12 : 20)),
      elevation: isMobile ? 4 : 8,
      margin: EdgeInsets.all(isMobile ? 8 : 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decorative gradient header with avatar + name
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16, 
              vertical: isMobile ? 12 : 18
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.95),
                  theme.colorScheme.primaryContainer.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: isMobile ? 20 : 26,
                  backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.15),
                  child: Text(
                    _getInitials(widget.name),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: isMobile ? 14 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isMobile ? 1 : 2),
                      Text(
                        widget.designation,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary.withOpacity(0.9),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.firmName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: _expanded ? "Collapse" : "Expand",
                  icon: Icon(
                    _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: theme.colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                ),
              ],
            ),
          ),

          AnimatedCrossFade(
            crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
            firstChild: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 12 : 16, 
                isMobile ? 12 : 16, 
                isMobile ? 12 : 16, 
                isMobile ? 16 : 20
              ),
              child: Column(
                children: [
                  // Quick actions row
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.email_rounded,
                          label: "Email",
                          color: Colors.blueAccent,
                          onTap: () => _launchUrl("mailto:${widget.email}"),
                        ),
                      ),
                      SizedBox(width: isMobile ? 6 : 10),
                      if (widget.phoneNumbers.isNotEmpty) ...[
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.call_rounded,
                            label: "Call",
                            color: Colors.green,
                            onTap: () => _launchUrl("tel:${widget.phoneNumbers.first}"),
                          ),
                        ),
                        SizedBox(width: isMobile ? 6 : 10),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.chat_rounded,
                            label: "WhatsApp",
                            color: Colors.teal,
                            onTap: () => _launchUrl("https://wa.me/${widget.phoneNumbers.first}"),
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: isMobile ? 12 : 16),

                  // Phones section
                  _Section(
                    title: "Phone Numbers",
                    icon: Icons.phone_android_rounded,
                    children: widget.phoneNumbers.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Text(
                                "No phone numbers",
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                              ),
                            )
                          ]
                        : _withDividers(widget.phoneNumbers.map(_buildPhoneRow).toList()),
                  ),

                  SizedBox(height: isMobile ? 8 : 12),

                  // Email row
                  _Section(
                    title: "Email",
                    icon: Icons.alternate_email_rounded,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: isMobile ? 14 : 18,
                          backgroundColor: Colors.blueAccent.withOpacity(0.1),
                          child: Icon(Icons.email, color: Colors.blueAccent, size: isMobile ? 16 : 20),
                        ),
                        title: Text(
                          widget.email,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _launchUrl("mailto:${widget.email}"),
                        trailing: Wrap(
                          spacing: isMobile ? 4 : 8,
                          children: [
                            Tooltip(
                              message: "Copy",
                              child: IconButton(
                                onPressed: () => _copyToClipboard(widget.email, label: 'Email'),
                                icon: Icon(Icons.copy_rounded, size: isMobile ? 18 : 20),
                              ),
                            ),
                            Tooltip(
                              message: "Compose Email",
                              child: IconButton(
                                onPressed: () => _launchUrl("mailto:${widget.email}"),
                                icon: Icon(Icons.open_in_new_rounded, size: isMobile ? 18 : 20),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: isMobile ? 8 : 12),

                  // Offices section
                  _Section(
                    title: "Offices",
                    icon: Icons.apartment_rounded,
                    children: widget.offices.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Text(
                                "No office addresses",
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                              ),
                            )
                          ]
                        : _withDividers(widget.offices.map(_buildOfficeRow).toList()),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> tiles) {
    if (tiles.isEmpty) return tiles;
    final List<Widget> result = [];
    for (int i = 0; i < tiles.length; i++) {
      result.add(tiles[i]);
      if (i != tiles.length - 1) {
        result.add(const Divider(height: 8));
      }
    }
    return result;
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
        border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
      ),
      padding: EdgeInsets.fromLTRB(
        isMobile ? 10 : 12, 
        isMobile ? 10 : 12, 
        isMobile ? 10 : 12, 
        isMobile ? 4 : 6
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: isMobile ? 16 : 18, color: theme.colorScheme.primary),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 6 : 8),
          ...children.map((c) => Padding(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 2.0 : 4.0),
                child: c,
              )),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 12, 
            vertical: isMobile ? 8 : 10
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: isMobile ? 16 : 20),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
