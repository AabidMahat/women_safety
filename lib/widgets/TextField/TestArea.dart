import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdvanceTextArea extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Icon? prefixIcon;
  final String? Function(String?)? validator;

  const AdvanceTextArea({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.prefixIcon,
  });

  @override
  _AdvanceTextAreaState createState() => _AdvanceTextAreaState();
}

class _AdvanceTextAreaState extends State<AdvanceTextArea> {
  int _currentCharacterCount = 0;
  final int _maxCharacters = 100;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateCharacterCount);
  }

  void _updateCharacterCount() {
    setState(() {
      _currentCharacterCount = widget.controller.text.length;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateCharacterCount);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextFormField(
            controller: widget.controller,
            keyboardType: TextInputType.text,
            inputFormatters: [
              LengthLimitingTextInputFormatter(_maxCharacters),
            ],
            maxLines: 5, // Increase height by setting maxLines
            minLines: 3,
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green.shade900,
              ),
              prefixIcon: widget.prefixIcon,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFF1F4F8),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.green.shade900,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Color(0xFFF1F4F8),
            ),
            validator: widget.validator,
            style: TextStyle(
              color: Color(0xFF101213),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '$_currentCharacterCount / $_maxCharacters',
            style: TextStyle(
              color: _currentCharacterCount > _maxCharacters ? Colors.red : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
