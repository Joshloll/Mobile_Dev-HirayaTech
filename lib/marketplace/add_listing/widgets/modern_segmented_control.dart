import 'package:flutter/material.dart';
import 'package:mobiledev_ecowaste/marketplace/add_listing/listing_form_provider.dart';

class ModernSegmentedControl extends StatelessWidget {
  final ListingType groupValue;
  final ValueChanged<ListingType> onValueChanged;
  final bool isEnabled; // <-- NEW PROPERTY

  const ModernSegmentedControl({
    super.key,
    required this.groupValue,
    required this.onValueChanged,
    this.isEnabled = true, // <-- Default to enabled
  });

  @override
  Widget build(BuildContext context) {
    // Visually indicate that the control is disabled
    final backgroundColor = isEnabled ? Colors.grey.shade200 : Colors.grey.shade300;
    final textColor = isEnabled ? Colors.grey.shade700 : Colors.grey.shade500;

    return AbsorbPointer(
      absorbing: !isEnabled, // Disable taps if not enabled
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: ListingType.values.map((type) {
            bool isSelected = groupValue == type;
            return Expanded(
              child: GestureDetector(
                onTap: () => onValueChanged(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                      colors: [Color(0xFF3A86FF), Color(0xFF5A9BFF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                        : null,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    type.name[0].toUpperCase() + type.name.substring(1),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}