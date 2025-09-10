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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.green.withOpacity(0.12),
        child: const Icon(Icons.phone, color: Colors.green),
      ),
      title: Text(phone, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      subtitle: const Text("Tap icons to Call or WhatsApp"),
      trailing: Wrap(
        spacing: 8,
        children: [
          Tooltip(
            message: "Copy",
            child: IconButton(
              onPressed: () => _copyToClipboard(phone, label: 'Phone'),
              icon: const Icon(Icons.copy_rounded),
            ),
          ),
          Tooltip(
            message: "Call",
            child: IconButton(
              onPressed: () => _launchUrl("tel:$phone"),
              icon: const Icon(Icons.call),
              color: Colors.green[700],
            ),
          ),
          Tooltip(
            message: "WhatsApp",
            child: IconButton(
              onPressed: () => _launchUrl("https://wa.me/$phone"),
              icon: const Icon(Icons.chat_rounded),
              color: Colors.teal[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeRow(String office) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        child: const Icon(Icons.location_on, color: Colors.redAccent),
      ),
      title: Text(
        office,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: const Text("Open in Maps or copy"),
      onTap: () => _launchUrl(
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(office)}",
      ),
      trailing: Wrap(
        spacing: 8,
        children: [
          Tooltip(
            message: "Copy",
            child: IconButton(
              onPressed: () => _copyToClipboard(office, label: 'Address'),
              icon: const Icon(Icons.copy_rounded),
            ),
          ),
          Tooltip(
            message: "Open Maps",
            child: IconButton(
              onPressed: () => _launchUrl(
                "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(office)}",
              ),
              icon: const Icon(Icons.directions_outlined),
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

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      margin: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decorative gradient header with avatar + name
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                  radius: 26,
                  backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.15),
                  child: Text(
                    _getInitials(widget.name),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                      const SizedBox(height: 2),
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
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
                      const SizedBox(width: 10),
                      if (widget.phoneNumbers.isNotEmpty) ...[
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.call_rounded,
                            label: "Call",
                            color: Colors.green,
                            onTap: () => _launchUrl("tel:${widget.phoneNumbers.first}"),
                          ),
                        ),
                        const SizedBox(width: 10),
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

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 12),

                  // Email row
                  _Section(
                    title: "Email",
                    icon: Icons.alternate_email_rounded,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blueAccent.withOpacity(0.1),
                          child: const Icon(Icons.email, color: Colors.blueAccent),
                        ),
                        title: Text(
                          widget.email,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _launchUrl("mailto:${widget.email}"),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            Tooltip(
                              message: "Copy",
                              child: IconButton(
                                onPressed: () => _copyToClipboard(widget.email, label: 'Email'),
                                icon: const Icon(Icons.copy_rounded),
                              ),
                            ),
                            Tooltip(
                              message: "Compose Email",
                              child: IconButton(
                                onPressed: () => _launchUrl("mailto:${widget.email}"),
                                icon: const Icon(Icons.open_in_new_rounded),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 12),

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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children.map((c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
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
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
