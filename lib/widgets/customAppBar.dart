import 'package:flutter/material.dart';

PreferredSizeWidget customAppBar(
    String title, {
      Function? onPressed,
      Color? backgroundColor,
      Color? textColor,
      IconData? leadingIcon,
      List<Widget>? actions
    }) {
  return AppBar(
    title: Text(
      title,
      style: TextStyle(
        color: textColor ?? Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 20, // Adjust font size for better visibility
      ),
    ),
    backgroundColor: backgroundColor ?? Colors.green.shade900,
    leading: leadingIcon != null
        ? IconButton(
      icon: Icon(
        leadingIcon,
        color: textColor ?? Colors.white,
      ),
      onPressed: () {
        if (onPressed != null) {
          onPressed();
        }
      },
    )
        : null, // If no icon is provided, remove the leading widget
    actions: actions,
    elevation: 4.0, // Add elevation for shadow effect
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(16.0), // Rounded bottom corners
      ),
    ),

  );
}
