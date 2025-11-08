import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'listing_form_provider.dart';
import 'add_listing_step3_inclusions_page.dart';
import 'add_listing_step1_page.dart';
import 'widgets/modern_segmented_control.dart';
import 'widgets/thousands_formatter.dart';

class AddListingStep2TypePage extends StatefulWidget {
  const AddListingStep2TypePage({super.key});

  @override
  State<AddListingStep2TypePage> createState() => _AddListingStep2TypePageState();
}

class _AddListingStep2TypePageState extends State<AddListingStep2TypePage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late final TextEditingController _tradeController;

  @override
  void initState() {
    super.initState();
    final form = Provider.of<ListingFormProvider>(context, listen: false);
    _titleController = TextEditingController(text: form.title ?? '');
    _descController = TextEditingController(text: form.description ?? '');
    _priceController = TextEditingController(text: form.price?.toStringAsFixed(0) ?? '');
    _tradeController = TextEditingController(text: form.tradeDetails ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _tradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListingFormProvider>(
      builder: (context, form, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('List Your Device')),
          body: Column(
            children: [
              LinearProgressIndicator(value: form.progress),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    Text('Listing Basics', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context,
                      label: 'Title',
                      hint: 'e.g., iPhone 14 Pro 256GB – Space Black',
                      controller: _titleController,
                      onChanged: form.updateTitle,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      context,
                      label: 'Short Description',
                      hint: 'Briefly describe condition or extras',
                      controller: _descController,
                      maxLines: 3,
                      onChanged: form.updateDescription,
                    ),
                    const SizedBox(height: 24),
                    ModernSegmentedControl(
                      groupValue: form.listingType,
                      onValueChanged: (type) => form.updateListingType(type),
                      isEnabled: !form.isTypeLocked,
                    ),
                    const SizedBox(height: 24),
                    if (form.listingType == ListingType.sell) _buildSellFields(context, form),
                    if (form.listingType == ListingType.trade) _buildTradeFields(context, form),
                    if (form.listingType == ListingType.donate) _buildDonateInfo(context),
                  ],
                ),
              ),
              _buildNextButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(BuildContext context,{required String label, required String hint, required TextEditingController controller, int maxLines = 1, required ValueChanged<String> onChanged}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(hintText: hint),
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildSellFields(BuildContext context, ListingFormProvider form){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Price (in PHP)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _priceController,
          onChanged: form.updatePrice,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            ThousandsSeparatorInputFormatter(),
          ],
          decoration: const InputDecoration(hintText: 'Enter your selling price'),
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildTradeFields(BuildContext context, ListingFormProvider form){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Desired Device for Trade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _tradeController,
          onChanged: form.updateTradeDetails,
          decoration: const InputDecoration(hintText: 'e.g., iPhone 15, MacBook Air M2'),
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
          autocorrect: false,
          enableSuggestions: false,
        ),
      ],
    );
  }

  Widget _buildDonateInfo(BuildContext context){
    return Card(
      color: Colors.blue.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          'Thank you for your generosity! Your donation will help bridge the digital divide.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: ElevatedButton(
        onPressed: (){
          final form = Provider.of<ListingFormProvider>(context, listen:false);
          // Basic validation
          if ((form.title==null || form.title!.trim().isEmpty)){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide a title.')));
            return;
          }
          if (form.listingType==ListingType.sell && (form.price==null || form.price==0)){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid price.')));
            return;
          }
          if (form.listingType==ListingType.trade && (form.tradeDetails==null || form.tradeDetails!.trim().isEmpty)){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please specify desired trade.')));
            return;
          }
          form.nextStep();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: form,
                child: const AddListingStep1Page(),
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
