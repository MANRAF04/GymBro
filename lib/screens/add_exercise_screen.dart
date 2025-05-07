import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro/models/exercise.dart';
import 'package:gymbro/services/database_helper.dart';
import 'package:intl/intl.dart';

class AddExerciseScreen extends StatefulWidget {
  final Exercise? prefilledExercise;
  
  AddExerciseScreen({this.prefilledExercise});
  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  DateTime _date = DateTime.now();
  int? _duration;
  int? _reps;
  String? _notes;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If we have a pre-filled exercise, populate the fields
    if (widget.prefilledExercise != null) {
      final exercise = widget.prefilledExercise!;
      _name = exercise.name;
      _date = exercise.date;
      _duration = exercise.duration;
      _reps = exercise.reps;
      _notes = exercise.notes;
      
      _nameController.text = _name;
      if (_duration != null) {
        _durationController.text = _duration.toString();
      }
      if (_reps != null) {
        _repsController.text = _reps.toString();
      }
      if (_notes != null) {
        _notesController.text = _notes.toString();
      }
    }
    
    _dateController.text = DateFormat('yyyy-MM-dd').format(_date);
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_date);
      });
    }
  }

  void _saveExercise() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_duration == null && _reps == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter either duration or repetitions.')),
        );
        return;
      }

      Exercise exercise = Exercise(
        name: _name,
        date: _date,
        duration: _duration,
        reps: _reps,
        notes: _notes,
      );
      await _databaseHelper.insertExercise(exercise);
      Navigator.pop(context, true); // Return to the previous screen
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _nameController.dispose();
    _durationController.dispose();
    _repsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Exercise'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Exercise Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an exercise name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _pickDate(context),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(labelText: 'Duration (minutes)'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                onSaved: (value) => _duration = (value != null && value.isNotEmpty) ? int.tryParse(value) : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _repsController,
                decoration: InputDecoration(labelText: 'Repetitions'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                onSaved: (value) => _reps = (value != null && value.isNotEmpty) ? int.tryParse(value) : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 3,
                onSaved: (value) => _notes = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveExercise,
                child: Text(widget.prefilledExercise != null ? 'Save Copy' : 'Save Exercise'),
              ),
            ],
          ),
        ),
      )
    );
  }
}