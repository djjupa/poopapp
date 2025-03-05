import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:poopapp/core/theme/app_colors.dart';
import 'package:poopapp/core/widgets/loading_indicator.dart';
import 'package:poopapp/features/poop_tracking/domain/entities/child.dart';
import 'package:poopapp/features/poop_tracking/domain/entities/poop_entry.dart';
import 'package:poopapp/features/poop_tracking/presentation/bloc/poop_bloc.dart';
import 'package:poopapp/features/poop_tracking/presentation/widgets/feeling_selector.dart';
import 'package:poopapp/features/poop_tracking/presentation/widgets/poop_characteristics_selector.dart';

class AddPoopEntryScreen extends StatefulWidget {
  final Child child;
  final PoopEntry? poopEntry;
  final bool isEditing;

  const AddPoopEntryScreen({
    super.key,
    required this.child,
    this.poopEntry,
    this.isEditing = false,
  });

  @override
  State<AddPoopEntryScreen> createState() => _AddPoopEntryScreenState();
}

class _AddPoopEntryScreenState extends State<AddPoopEntryScreen> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late PoopConsistency _selectedConsistency;
  late PoopColor _selectedColor;
  late FeelingSentiment? _selectedFeeling;
  late bool _hasBlood;
  late bool _hasMucus;
  late TextEditingController _notesController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  void _initializeValues() {
    if (widget.poopEntry != null) {
      final entry = widget.poopEntry!;
      _selectedDate = entry.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(entry.dateTime);
      _selectedConsistency = entry.consistency;
      _selectedColor = entry.color;
      _selectedFeeling = entry.feeling;
      _hasBlood = entry.hasBlood;
      _hasMucus = entry.hasMucus;
      _notesController = TextEditingController(text: entry.notes);
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _selectedConsistency = PoopConsistency.normal;
      _selectedColor = PoopColor.brown;
      _selectedFeeling = null;
      _hasBlood = false;
      _hasMucus = false;
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PoopBloc, PoopState>(
      listener: (context, state) {
        if (state is PoopActionSuccessState) {
          setState(() {
            _isSubmitting = false;
          });
          Navigator.pop(context);
        } else if (state is PoopErrorState) {
          setState(() {
            _isSubmitting = false;
          });
          _showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit Poop Entry' : 'Add Poop Entry'),
          actions: [
            if (widget.isEditing)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _confirmDelete,
                tooltip: 'Delete Entry',
              ),
          ],
        ),
        body: _isSubmitting
            ? const LoadingIndicator(message: 'Saving entry...')
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateTimeSelector(),
                    const SizedBox(height: 24.0),
                    PoopCharacteristicsSelector(
                      selectedConsistency: _selectedConsistency,
                      selectedColor: _selectedColor,
                      hasBlood: _hasBlood,
                      hasMucus: _hasMucus,
                      onConsistencySelected: (consistency) {
                        setState(() {
                          _selectedConsistency = consistency;
                        });
                      },
                      onColorSelected: (color) {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      onBloodChanged: (value) {
                        setState(() {
                          _hasBlood = value;
                        });
                      },
                      onMucusChanged: (value) {
                        setState(() {
                          _hasMucus = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24.0),
                    FeelingSelectorWidget(
                      selectedFeeling: _selectedFeeling,
                      onFeelingSelected: (feeling) {
                        setState(() {
                          _selectedFeeling = feeling;
                        });
                      },
                    ),
                    const SizedBox(height: 24.0),
                    _buildNotesField(),
                    const SizedBox(height: 32.0),
                    _buildSubmitButton(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    final dateFormatter = DateFormat('EEEE, MMMM d, yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'When did it happen?',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateFormatter.format(_selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            SizedBox(
              width: 120.0,
              child: InkWell(
                onTap: _pickTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedTime.format(context)),
                      const Icon(Icons.access_time),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Notes',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: _notesController,
          decoration: const InputDecoration(
            hintText: 'Add any notes or observations...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(16.0),
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitEntry,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        child: Text(
          widget.isEditing ? 'Update Poop Entry' : 'Save Poop Entry',
          style: const TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
            timePickerTheme: TimePickerThemeData(
              dialBackgroundColor: AppColors.primary.withOpacity(0.1),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _submitEntry() {
    if (_selectedConsistency == null || _selectedColor == null) {
      _showErrorSnackBar('Please select poop consistency and color');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final DateTime entryDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final poopEntry = PoopEntry(
      id: widget.poopEntry?.id,
      childId: widget.child.id!,
      dateTime: entryDateTime,
      consistency: _selectedConsistency,
      color: _selectedColor,
      hasBlood: _hasBlood,
      hasMucus: _hasMucus,
      feeling: _selectedFeeling,
      notes: _notesController.text.trim(),
    );

    if (widget.isEditing) {
      context.read<PoopBloc>().add(UpdatePoopEntryEvent(poopEntry));
    } else {
      context.read<PoopBloc>().add(AddPoopEntryEvent(poopEntry));
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
          'Are you sure you want to delete this poop entry? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEntry();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteEntry() {
    if (widget.poopEntry == null || widget.poopEntry!.id == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    context.read<PoopBloc>().add(
          DeletePoopEntryEvent(
            widget.poopEntry!.id!,
            widget.child.id!,
          ),
        );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
} 