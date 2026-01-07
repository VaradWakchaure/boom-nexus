import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/event_service.dart';
import '../services/club_service.dart';
import '../models/club_model.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  DateTime? _selectedDateTime;
  String? _selectedClubId; // ✅ FIX: use String (clubId)

  final EventService _eventService = EventService();
  final ClubService _clubService = ClubService();

  bool _isLoading = false;

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate() ||
        _selectedClubId == null ||
        _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await _eventService.createEvent(
      clubId: _selectedClubId!, // ✅ FIX
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      dateTime: _selectedDateTime!,
      createdBy: uid,
    );

    setState(() => _isLoading = false);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event created')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              /// SELECT CLUB
              StreamBuilder<List<Club>>(
                stream: _clubService.getClubsForCoordinator(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final clubs = snapshot.data ?? [];

                  if (clubs.isEmpty) {
                    return const Text('Create a club first');
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedClubId,
                    hint: const Text('Select Club'),
                    items: clubs
                        .map(
                          (club) => DropdownMenuItem<String>(
                            value: club.id,
                            child: Text(club.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClubId = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Select club' : null,
                  );
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration:
                    const InputDecoration(labelText: 'Event Name'),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Enter event name'
                        : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                decoration:
                    const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Enter description'
                        : null,
              ),

              const SizedBox(height: 16),

              ListTile(
                title: Text(
                  _selectedDateTime == null
                      ? 'Pick date & time'
                      : _selectedDateTime.toString(),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDateTime,
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _createEvent,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
