import 'package:flutter/material.dart';

class AdvanceTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType type;
  final String label;
  final Icon? prefixIcon;
  final bool isPasswordField;
  final bool isObscuredInitially;
  final bool readOnly;
  final String? Function(String?)? validator;  // Validator function type updated

  const AdvanceTextField({
    super.key,
    required this.controller,
    required this.type,
    required this.label,
    this.isPasswordField = false,
    this.isObscuredInitially = true,
    this.readOnly = false,
    this.validator,
    this.prefixIcon,// No need to assign null here
  });

  @override
  _AdvanceTextFieldState createState() => _AdvanceTextFieldState();
}

class _AdvanceTextFieldState extends State<AdvanceTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isObscuredInitially;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        readOnly: widget.readOnly,
        controller: widget.controller,
        obscureText: widget.isPasswordField ? _isObscured : false,
        keyboardType: widget.type,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.green.shade900
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
          suffixIcon: widget.isPasswordField
              ? IconButton(
            icon: Icon(
              _isObscured ? Icons.visibility_off : Icons.visibility,
              color: Color(0xFF57636C),
            ),
            onPressed: () {
              setState(() {
                _isObscured = !_isObscured;
              });
            },
          )
              : null,
        ),
        validator: widget.validator, // Use widget.validator correctly here
        style: TextStyle(
          color: Color(0xFF101213),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
