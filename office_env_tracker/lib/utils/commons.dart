import 'package:flutter/material.dart';
import 'app_theme.dart';
import '../services/api_service.dart';

class Commons {
  static Widget buildButton(BuildContext context, String buttonName,
      IconData icon, Function() onSelected, bool isSelected,
      {double? width}) {
    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          icon,
          color: Colors.black,
        ),
        SizedBox(width: 8),
        Text(
          buttonName,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ],
    );

    ElevatedButton button = ElevatedButton(
      onPressed: () {
        onSelected();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? AppColors.buttonSelectedColor
            : AppColors.buttonUnselectedColor,
      ),
      child: buttonContent,
    );

    if (width != null) {
      return SizedBox(width: width, child: button);
    } else {
      return button;
    }
  }
}
