import 'package:flutter/material.dart';

class AdvanceButton extends StatelessWidget {
  final bool isLoading; // Whether the button is in loading state
  final VoidCallback? onPressed; // Function to handle button press
  final String buttonText; // Text to display on the button
  final Color backgroundColor; // Button background color
  final IconData?
      prefixIcon; // Icon to display before the button text (optional)

  const AdvanceButton({
    super.key,
    this.isLoading = false,
    required this.onPressed,
    required this.buttonText,
    this.backgroundColor = const Color(0xFF032A04), // Default to green
    this.prefixIcon, // Optional icon
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
        child: TextButton(
          onPressed: isLoading
              ? null
              : () {
                  onPressed!();
                },
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min, // Align icon and text tightly
                  mainAxisAlignment: MainAxisAlignment.center, // Center items
                  children: [
                    if (prefixIcon != null) ...[
                      Icon(
                        prefixIcon,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      // Add some space between icon and text
                    ],
                    Text(
                      buttonText,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
          style: TextButton.styleFrom(
            elevation: 3,
            backgroundColor: backgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
