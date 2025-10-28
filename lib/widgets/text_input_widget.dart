import 'package:flutter/material.dart';

class TextInputWidget extends StatefulWidget {
  final String? initialText;
  final TextEditingController? controller;
  final Function(String)? onTextChanged;
  final Function(String) onSendPressed;
  final VoidCallback onVoicePressed;
  final VoidCallback onAttachmentPressed;
  final VoidCallback onCameraPressed;
  final String? hint;
  final Color? fillColor;

  const TextInputWidget({
    super.key,
    this.initialText,
    this.onTextChanged,
    this.controller,
    required this.onSendPressed,
    required this.onVoicePressed,
    required this.onAttachmentPressed,
    required this.onCameraPressed,
    this.hint,
    this.fillColor,
  });

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController =
        widget.controller ?? TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _textController.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            onChanged: (v) {
              widget.onTextChanged?.call(v);
              setState(() {});
            },
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              filled: true,
              fillColor: widget.fillColor ?? Theme.of(context).colorScheme.surface,
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 15,
              ),
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor
                ),
              ),
              errorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Attachment button
                  IconButton(
                    onPressed: widget.onAttachmentPressed,
                    icon: const Icon(
                      Icons.attach_file,
                      color: Color(0xFF9E9E9E),
                      size: 24,
                    ),
                  ),

                  // Camera button
                  IconButton(
                    onPressed: widget.onCameraPressed,
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFF9E9E9E),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        // Send or Voice button
        GestureDetector(
          onTap: _textController.text.trim().isNotEmpty
              ? () {
                  widget.onSendPressed(_textController.text.trim());
                  _textController.clear();
                }
              : widget.onVoicePressed,
          child: Container(
            width: 48,
            height: 48,
            margin: EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(
                  milliseconds: 200), // Adjust duration as needed
              transitionBuilder: (child, anim) => RotationTransition(
                turns: child.key == ValueKey('send')
                    ? Tween<double>(begin: 1, end: 1).animate(anim)
                    : Tween<double>(begin: 0.75, end: 1).animate(anim),
                child: ScaleTransition(scale: anim, child: child),
              ),
              child: Icon(
                key: ValueKey(_textController.text.trim().isNotEmpty ? 'send' : 'record'),
                _textController.text.trim().isNotEmpty ? Icons.send : Icons.mic,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
