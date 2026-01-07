import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/club_service.dart';

class CreateClubPage extends StatefulWidget {
  const CreateClubPage({super.key});

  @override
  State<CreateClubPage> createState() => _CreateClubPageState();
}

class _CreateClubPageState extends State<CreateClubPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  final ClubService _clubService = ClubService();
  bool _isLoading = false;

  Future<void> _createClub() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await _clubService.createClub(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      ownerUid: uid,
    );

    setState(() => _isLoading = false);

    Navigator.pop(context); // go back to dashboard

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Club created successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Club')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Club Name',
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Enter club name'
                        : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Enter description'
                        : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _createClub,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Club'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
