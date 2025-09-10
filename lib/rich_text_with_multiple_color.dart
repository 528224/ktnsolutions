import 'package:flutter/material.dart';
const RUNNING_TEXT_VELOCITY = 30.0;

class SubTextColor {
  String subText = '';
  String colorHex = ''; // Store color as hex string like "#FF2196F3"

  SubTextColor({required this.subText, required this.colorHex});

  SubTextColor.fromSnapshot(Map<String, dynamic> snapshot) {
    subText = snapshot.containsKey("subText") ? snapshot["subText"] : '';
    colorHex = snapshot.containsKey("color") ? snapshot["color"] : '';
  }

  Map<String, dynamic> toSnapShot() {
    return {
      "subText": subText,
      "color": colorHex,
    };
  }
}

Widget getRunningMultiColorText(String mainText, {bool isMulticolor = true, bool isRunning = true, List<SubTextColor> subTextColors = const []}) {
  const nonMatchingTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  List<TextSpan> spans = [];

  if (isMulticolor){
    int start = 0;

    while (start < mainText.length) {
      SubTextColor? match;
      int matchIndex = mainText.length;

      for (var subTextColor in subTextColors) {
        if (subTextColor.subText.isEmpty) continue;

        // for case-insensitive match
        int index = mainText.toLowerCase().indexOf(subTextColor.subText.toLowerCase(), start);

        if (index != -1 && index < matchIndex) {
          matchIndex = index;
          match = subTextColor;
        }
      }

      if (match == null || matchIndex == -1) {
        spans.add(TextSpan(text: mainText.substring(start), style: nonMatchingTextStyle));
        break;
      }

      // Add non-matching text
      if (matchIndex > start) {
        spans.add(TextSpan(text: mainText.substring(start, matchIndex),
            style: nonMatchingTextStyle));
      }

      // Add matching colored text
      spans.add(
        TextSpan(
          text: mainText.substring(matchIndex, matchIndex + match.subText.length),
          style: nonMatchingTextStyle.copyWith(color: HexColor(match.colorHex))
        ),
      );

      start = matchIndex + match.subText.length;
    }
  }else{
    spans.add(TextSpan(text: mainText, style: nonMatchingTextStyle));
  }

  if(isRunning){
    return RichTextMarquee(textSpans: spans, padding: const EdgeInsets.symmetric(horizontal: 0.0), defaultTextStyle: nonMatchingTextStyle,
      velocity: RUNNING_TEXT_VELOCITY,);
  }else{
    return Center(child: Text.rich(TextSpan(children: spans),
      maxLines: 2, // ✅ prevents overflow
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,),
    );
  }
}


class RichTextMarquee extends StatefulWidget {
  final List<TextSpan> textSpans;
  final double velocity; // pixels per second
  final double blankSpace; // space between repetitions
  final EdgeInsetsGeometry padding;
  final TextStyle? defaultTextStyle;

  const RichTextMarquee({
    Key? key,
    required this.textSpans,
    this.velocity = RUNNING_TEXT_VELOCITY,
    this.blankSpace = 20.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.defaultTextStyle,
  }) : super(key: key);

  @override
  _RichTextMarqueeState createState() => _RichTextMarqueeState();
}

class _RichTextMarqueeState extends State<RichTextMarquee>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late double _textWidth;
  late double _containerWidth;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAnimation());
  }

  void _startAnimation() {
    final RenderBox renderBox =
    _textKey.currentContext?.findRenderObject() as RenderBox;
    _textWidth = renderBox.size.width;
    _containerWidth = context.size!.width;

    final double scrollDistance = _textWidth + widget.blankSpace;

    final double durationSeconds = scrollDistance / widget.velocity;

    _animationController = AnimationController(
      duration: Duration(seconds: (durationSeconds * 1.25).toInt()),
      vsync: this,
    );

    _animation =
    Tween<double>(begin: 0.0, end: scrollDistance).animate(_animationController)
      ..addListener(() {
        _scrollController.jumpTo(_animation.value);
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.repeat();
        }
      });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        child: Row(
          key: _textKey,
          children: [
            RichText(
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              text: TextSpan(
                style: widget.defaultTextStyle ?? DefaultTextStyle.of(context).style,
                children: widget.textSpans,
              ),
            ),
            SizedBox(width: widget.blankSpace),
            RichText(
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              text: TextSpan(
                style: widget.defaultTextStyle ?? DefaultTextStyle.of(context).style,
                children: widget.textSpans,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class TextColorPickerDialog extends StatefulWidget {
  final Function(String, List<SubTextColor>) onDone;
  final String initialText;
  final List<SubTextColor> initialTextColors;
  const TextColorPickerDialog({super.key,required this.initialText, required this.initialTextColors, required this.onDone});

  @override
  State<TextColorPickerDialog> createState() => _TextColorPickerDialogState();
}

class _TextColorPickerDialogState extends State<TextColorPickerDialog> {
  final TextEditingController _controller = TextEditingController();
  final List<SubTextColor> _selectedTextColors = [];

  final List<Color> _availableColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.black,
  ];

  Color? _selectedColor;

  TextSelection get selection => _controller.selection;

  void _applyColorToSelectedText() {
    final selectedText = selection.textInside(_controller.text).trim();
    if (selectedText.isNotEmpty && _selectedColor != null) {
      final colorHex = '#${_selectedColor!.value.toRadixString(16).padLeft(8, '0')}';
      setState(() {
        _selectedTextColors.add(SubTextColor(subText: selectedText, colorHex: colorHex));
      });
    }
  }

  @override
  void initState() {
    _controller.text = widget.initialText;
    _selectedTextColors.addAll(widget.initialTextColors);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildColorDots() {
    return Wrap(
      spacing: 8,
      children: _availableColors.map((color) {
        final isSelected = color == _selectedColor;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Text & Color"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: null,
              decoration: const InputDecoration(labelText: 'Enter text'),
            ),
            const SizedBox(height: 16),
            const Text('Select a color:'),
            const SizedBox(height: 8),
            _buildColorDots(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _applyColorToSelectedText,
              child: const Text("Apply Color to Selected Text"),
            ),
            const SizedBox(height: 12),
            if (_selectedTextColors.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Colored Segments:'),
                  ..._selectedTextColors.map((e) => Text('${e.subText} -> ${e.colorHex}')),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _selectedTextColors.clear();
            });
          },
          child: const Text("Clear All"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onDone(_controller.text, _selectedTextColors);
            Navigator.pop(context);
          },
          child: const Text("Done"),
        ),
      ],
    );
  }
}


getRichMultiTextEditor(BuildContext context, String title, List<SubTextColor> subTitleColors,
    Function(String, List<SubTextColor>) onDone) {
  return GestureDetector(
    onTap: () {
      showDialog(
        context: context,
        builder: (context) => TextColorPickerDialog(
          initialText: title,
          initialTextColors: subTitleColors,
          onDone: onDone,
        ),
      );
    },
    child: _getTitleEditWidget(title, subTitleColors),
  );
}

_getTitleEditWidget(String title, List<SubTextColor> subTitleColors) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(8),
    ),
    child: title.isEmpty
        ? const Text("Tap to enter title", style: TextStyle(color: Colors.grey))
        : getRunningMultiColorText(title, subTextColors: subTitleColors),
  );
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}