import 'package:flutter/material.dart';

class CustomDropdownWithOther extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CustomDropdownWithOther({
    super.key,
    required this.label,
    this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  State<CustomDropdownWithOther> createState() => _CustomDropdownWithOtherState();
}

class _CustomDropdownWithOtherState extends State<CustomDropdownWithOther> {
  late final TextEditingController _otherController;
  bool _showOtherField = false;
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
    // Check if the initial value is a custom one
    if (_selectedValue != null && !widget.items.contains(_selectedValue)) {
      _showOtherField = true;
      _otherController = TextEditingController(text: _selectedValue);
    } else {
      _otherController = TextEditingController();
    }

    _otherController.addListener(() {
      widget.onChanged(_otherController.text);
    });
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A86FF), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullItems = [...widget.items, 'Other...'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedValue,
          onChanged: (val) {
            setState(() {
              if (val == 'Other...') {
                _showOtherField = true;
                _selectedValue = val;
                widget.onChanged(''); // Clear value while user types
              } else {
                _showOtherField = false;
                _selectedValue = val;
                _otherController.clear();
                widget.onChanged(val);
              }
            });
          },
          items: fullItems.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          decoration: _buildInputDecoration('Select ${widget.label}'),
          style: const TextStyle(color: Color(0xFF1D3557), fontSize: 16),
          dropdownColor: Colors.white,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1D3557)),
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
        ),
        if (_showOtherField)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: TextField(
              controller: _otherController,
              decoration: _buildInputDecoration('Please specify'),
              style: const TextStyle(color: Color(0xFF1D3557)),
            ),
          ),
      ],
    );
  }
}