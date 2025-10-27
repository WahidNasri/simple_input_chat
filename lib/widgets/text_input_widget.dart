import 'package:flutter/material.dart';

class TextInputWidget extends StatefulWidget {
  final String? initialText;
  final Function(String) onTextChanged;
  final VoidCallback onSendPressed;
  final VoidCallback onVoicePressed;
  final VoidCallback onEmojiPressed;
  final VoidCallback onAttachmentPressed;
  final VoidCallback onCameraPressed;

  const TextInputWidget({
    super.key,
    this.initialText,
    required this.onTextChanged,
    required this.onSendPressed,
    required this.onVoicePressed,
    required this.onEmojiPressed,
    required this.onAttachmentPressed,
    required this.onCameraPressed,
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
    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _textController.text.isNotEmpty;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: hasText ? const Color(0xFF00C851) : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Emoji button
          GestureDetector(
            onTap: widget.onEmojiPressed,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_emotions_outlined,
                color: Color(0xFF9E9E9E),
                size: 24,
              ),
            ),
          ),
          
          // Text input field
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              onChanged: widget.onTextChanged,
              style: const TextStyle(
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                hintText: 'Message',
                hintStyle: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          
          // Attachment button
          GestureDetector(
            onTap: widget.onAttachmentPressed,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.attach_file,
                color: Color(0xFF9E9E9E),
                size: 24,
              ),
            ),
          ),
          
          // Camera button
          GestureDetector(
            onTap: widget.onCameraPressed,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFF9E9E9E),
                size: 24,
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Send or Voice button
          GestureDetector(
            onTap: hasText ? widget.onSendPressed : widget.onVoicePressed,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: hasText ? const Color(0xFF00C851) : const Color(0xFF00C851),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasText ? Icons.send : Icons.mic,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
