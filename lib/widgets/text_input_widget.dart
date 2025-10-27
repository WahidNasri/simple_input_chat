
import 'package:flutter/material.dart';

class TextInputWidget extends StatefulWidget {
  final String? initialText;
  final TextEditingController? controller;
  final Function(String)? onTextChanged;
  final Function(String) onSendPressed;
  final VoidCallback onVoicePressed;
  final VoidCallback onAttachmentPressed;
  final VoidCallback onCameraPressed;

  const TextInputWidget({
    super.key,
    this.initialText,
    this.onTextChanged,
    this.controller,
    required this.onSendPressed,
    required this.onVoicePressed,
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
    _textController = widget.controller ?? TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    if(widget.controller == null) {
      _textController.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: _textController.text.trim().isNotEmpty ? Theme.of(context).primaryColor : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Text input field
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              onChanged: (v){
                widget.onTextChanged?.call(v);
                setState(() {

                });
              },
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
          

          // Send or Voice button
          GestureDetector(
            onTap: _textController.text.trim().isNotEmpty ? (){
              widget.onSendPressed(_textController.text.trim());
            _textController.clear();} : widget.onVoicePressed,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _textController.text.trim().isNotEmpty ? Icons.send : Icons.mic,
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
