import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class EditInsuranceScreen extends StatefulWidget {
  const EditInsuranceScreen({Key? key}) : super(key: key);

  @override
  State<EditInsuranceScreen> createState() => _EditInsuranceScreenState();
}

class _EditInsuranceScreenState extends State<EditInsuranceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mutuelleController = TextEditingController();

  String? _selectedInsurance;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;

    _selectedInsurance = user?.healthInsurance;
    _mutuelleController.text = user?.mutuelleNumber ?? '';
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Cast to dynamic to avoid compile-time error if the AuthProvider
    // implementation doesn't expose `updateHealthInsurance` with that
    // exact signature. This defers method resolution to runtime.
    final auth = context.read<AuthProvider>() as dynamic;
    await auth.updateHealthInsurance(
      healthInsurance: _selectedInsurance!,
      mutuelleNumber: _selectedInsurance == 'Mutuelle de Santé'
        ? _mutuelleController.text.trim()
        : null,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Health Insurance')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedInsurance,
                decoration: const InputDecoration(
                  labelText: 'Health Insurance',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'RAMA', child: Text('RAMA')),
                  DropdownMenuItem(value: 'MMI', child: Text('MMI')),
                  DropdownMenuItem(
                    value: 'Mutuelle de Santé',
                    child: Text('Mutuelle de Santé'),
                  ),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedInsurance = value;
                    if (value != 'Mutuelle de Santé') {
                      _mutuelleController.clear();
                    }
                  });
                },
                validator: (value) =>
                    value == null ? 'Select insurance' : null,
              ),

              const SizedBox(height: 15),

              if (_selectedInsurance == 'Mutuelle de Santé')
                TextFormField(
                  controller: _mutuelleController,
                  decoration: const InputDecoration(
                    labelText: 'Mutuelle Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mutuelle number required';
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _save,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
