import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/financial_target_provider.dart';
import '../data/models/financial_target_model.dart';

class CreateEditTargetScreen extends ConsumerStatefulWidget {
  final FinancialTargetModel? target;

  const CreateEditTargetScreen({super.key, this.target});

  @override
  ConsumerState<CreateEditTargetScreen> createState() => _CreateEditTargetScreenState();
}

class _CreateEditTargetScreenState extends ConsumerState<CreateEditTargetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedCategory = 'tabungan';
  
  final List<String> _categories = [
    'tabungan',
    'investasi',
    'asuransi',
    'properti',
    'pendidikan',
    'lainnya'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.target != null) {
      final t = widget.target!;
      _nameController.text = t.name;
      _descriptionController.text = t.description ?? '';
      _targetAmountController.text = t.targetAmount.toInt().toString();
      _currentAmountController.text = t.currentAmount.toInt().toString();
      _selectedCategory = t.category;
      try {
        _selectedDate = DateTime.parse(t.targetDate);
      } catch (e) {
        // ignore
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a target date')),
      );
      return;
    }

    final data = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'category': _selectedCategory,
      'target_amount': _targetAmountController.text,
      'current_amount': _currentAmountController.text.isNotEmpty ? _currentAmountController.text : '0',
      'target_date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'status': widget.target?.status ?? 'active',
      'priority': widget.target?.priority ?? 1,
    };

    bool success;
    if (widget.target != null) {
      success = await ref.read(financialTargetProvider.notifier).updateTarget(widget.target!.id, data);
    } else {
      success = await ref.read(financialTargetProvider.notifier).createTarget(data);
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.target == null ? 'Target created!' : 'Target updated!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.target != null;
    final isLoading = ref.watch(financialTargetProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Target' : 'New Target', style: const TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Target Name',
                hintText: 'e.g. Dream House, Emergency Fund',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.track_changes),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.category),
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category.toUpperCase()),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) setState(() => _selectedCategory = newValue);
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _targetAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target Amount (Rp)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.monetization_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter target amount';
                if (double.tryParse(value) == null) return 'Must be a valid number';
                return null;
              },
            ),
            const SizedBox(height: 20),
            if (!isEditing)
              TextFormField(
                controller: _currentAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Initial Saved Amount (Rp) - Optional',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.savings),
                ),
              ),
            if (!isEditing) const SizedBox(height: 20),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Target Date',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDate == null ? 'Select a date' : DateFormat('dd MMM yyyy').format(_selectedDate!),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEditing ? 'Update Target' : 'Create Target', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
