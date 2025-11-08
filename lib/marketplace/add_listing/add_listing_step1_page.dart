import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'listing_form_provider.dart';
import 'add_listing_step2_type_page.dart';
import 'add_listing_step3_inclusions_page.dart';
import 'widgets/custom_dropdown_with_other.dart';

class AddListingStep1Page extends StatelessWidget {
  const AddListingStep1Page({super.key});

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<ListingFormProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('List Your Device')),
      body: Column(
        children: [
          LinearProgressIndicator(value: formProvider.progress),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                Text(
                    'Device Information',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 24),
                CustomDropdownWithOther(
                  label: 'Device Type *',
                  value: formProvider.deviceType,
                  items: const ['Phone', 'Laptop', 'Tablet', 'Smartwatch', 'Headphones'],
                  onChanged: (val) => formProvider.updateDeviceType(val),
                ),
                const SizedBox(height: 16),
                CustomDropdownWithOther(
                  label: 'Brand *',
                  value: formProvider.brand,
                  items: const ['Apple', 'Samsung', 'Google', 'Sony', 'Dell', 'HP'],
                  onChanged: (val) => formProvider.updateBrand(val),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context,
                  label: 'Model *',
                  placeholder: 'e.g., iPhone 14 Pro, Galaxy S23 Ultra',
                  onChanged: (val) => formProvider.updateModel(val),
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context,
                  label: 'Storage Capacity *',
                  placeholder: 'e.g., 256GB',
                  onChanged: (val) => formProvider.updateStorageCapacity(val),
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  context,
                  label: 'Color',
                  placeholder: 'e.g., Space Black, Sierra Blue',
                  onChanged: (val) => formProvider.updateColor(val),
                  autocorrect: false,
                  enableSuggestions: false,
                ),
              ],
            ),
          ),
          _buildNextButton(context),
        ],
      ),
    );
  }

  Widget _buildTextField(
      BuildContext context, {
        required String label,
        required String placeholder,
        required ValueChanged<String> onChanged,
        bool autocorrect = true,
        bool enableSuggestions = true,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          decoration: InputDecoration(hintText: placeholder),
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: ElevatedButton(
        onPressed: () {
          final formProvider = Provider.of<ListingFormProvider>(context, listen: false);
          final missing = <String>[];
          if (formProvider.deviceType == null || formProvider.deviceType!.trim().isEmpty) missing.add('Device Type');
          if (formProvider.brand == null || formProvider.brand!.trim().isEmpty) missing.add('Brand');
          if (formProvider.model == null || formProvider.model!.trim().isEmpty) missing.add('Model');
          if (formProvider.storageCapacity == null || formProvider.storageCapacity!.trim().isEmpty) missing.add('Storage Capacity');

          if (missing.isNotEmpty) {
            final msg = 'Please complete: ' + missing.join(', ');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg)),
            );
            return;
          }

          formProvider.nextStep();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: formProvider,
                child: const AddListingStep3InclusionsPage(),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          minimumSize: const Size(double.infinity, 50),
          shape: const StadiumBorder(),
        ),
        child: const Text('Next'),
      ),
    );
  }
}