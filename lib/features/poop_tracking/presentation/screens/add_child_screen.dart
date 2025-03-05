import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poopapp/core/theme/app_colors.dart';
import 'package:poopapp/core/widgets/loading_indicator.dart';
import 'package:poopapp/features/poop_tracking/domain/entities/child.dart';
import 'package:poopapp/features/poop_tracking/presentation/bloc/child_bloc.dart';
import 'package:path/path.dart' as path;

class AddChildScreen extends StatefulWidget {
  final Child? child;
  final bool isEditing;

  const AddChildScreen({
    super.key,
    this.child,
    this.isEditing = false,
  });

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  DateTime? _birthDate;
  File? _avatarFile;
  String? _avatarPath;
  bool _isSubmitting = false;
  Gender _selectedGender = Gender.unknown;

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  void _initializeValues() {
    if (widget.child != null) {
      _nameController = TextEditingController(text: widget.child!.name);
      _birthDate = widget.child!.birthDate;
      _avatarPath = widget.child!.avatarPath;
      _selectedGender = widget.child!.gender;
    } else {
      _nameController = TextEditingController();
      _birthDate = null;
      _avatarPath = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChildBloc, ChildState>(
      listener: (context, state) {
        if (state is ChildActionSuccessState) {
          setState(() {
            _isSubmitting = false;
          });
          Navigator.pop(context);
        } else if (state is ChildErrorState) {
          setState(() {
            _isSubmitting = false;
          });
          _showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit Child Profile' : 'Add Child Profile'),
          actions: [
            if (widget.isEditing)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _confirmDelete,
                tooltip: 'Delete Profile',
              ),
          ],
        ),
        body: _isSubmitting
            ? const LoadingIndicator(message: 'Saving profile...')
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAvatarSelector(),
                      const SizedBox(height: 32.0),
                      _buildNameField(),
                      const SizedBox(height: 24.0),
                      _buildBirthDateField(),
                      const SizedBox(height: 24.0),
                      _buildGenderSelector(),
                      const SizedBox(height: 48.0),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAvatarSelector() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 60.0,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              backgroundImage: _getAvatarImage(),
              child: _hasAvatar()
                  ? null
                  : const Icon(
                      Icons.person,
                      size: 70.0,
                      color: AppColors.primary,
                    ),
            ),
          ),
          const SizedBox(height: 12.0),
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt),
            label: Text(_hasAvatar() ? 'Change Photo' : 'Add Photo'),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getAvatarImage() {
    if (_avatarFile != null) {
      return FileImage(_avatarFile!);
    } else if (_avatarPath != null && _avatarPath!.isNotEmpty) {
      return FileImage(File(_avatarPath!));
    }
    return null;
  }

  bool _hasAvatar() {
    return _avatarFile != null || (_avatarPath != null && _avatarPath!.isNotEmpty);
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Child\'s Name',
        hintText: 'Enter your child\'s name',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.child_care),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a name';
        }
        return null;
      },
    );
  }

  Widget _buildBirthDateField() {
    final dateFormatter = DateFormat('MMMM d, yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Birth Date',
          style: TextStyle(
            fontSize: 16.0,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8.0),
        InkWell(
          onTap: _pickBirthDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _birthDate == null
                      ? 'Select birth date'
                      : dateFormatter.format(_birthDate!),
                  style: TextStyle(
                    color: _birthDate == null
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (_birthDate != null) ...[
          const SizedBox(height: 8.0),
          Text(
            'Age: ${_calculateAge(_birthDate!)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 16.0,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(Gender.male, 'Boy', Icons.male),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: _buildGenderOption(Gender.female, 'Girl', Icons.female),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: _buildGenderOption(Gender.unknown, 'Other', Icons.person),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(Gender gender, String label, IconData icon) {
    final isSelected = _selectedGender == gender;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 28.0,
            ),
            const SizedBox(height: 8.0),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitProfile,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        child: Text(
          widget.isEditing ? 'Update Profile' : 'Save Profile',
          style: const TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _avatarFile = File(image.path);
      });
    }
  }

  Future<void> _pickBirthDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
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
        _birthDate = pickedDate;
      });
    }
  }

  String _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    final years = today.year - birthDate.year;
    final months = today.month - birthDate.month;
    final days = today.day - birthDate.day;

    if (years > 0) {
      return '$years ${years == 1 ? 'year' : 'years'}';
    } else if (months > 0) {
      return '$months ${months == 1 ? 'month' : 'months'}';
    } else {
      return '$days ${days == 1 ? 'day' : 'days'}';
    }
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Save avatar file if new one was selected
    String? newAvatarPath = _avatarPath;
    if (_avatarFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}${path.extension(_avatarFile!.path)}';
      final savedImage = await _avatarFile!.copy('${appDir.path}/$fileName');
      newAvatarPath = savedImage.path;
    }

    final child = Child(
      id: widget.child?.id,
      name: _nameController.text.trim(),
      birthDate: _birthDate,
      avatarPath: newAvatarPath,
      gender: _selectedGender,
      isSelected: widget.child?.isSelected ?? false,
    );

    if (widget.isEditing) {
      context.read<ChildBloc>().add(UpdateChildEvent(child));
    } else {
      context.read<ChildBloc>().add(AddChildEvent(child));
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: const Text(
          'Are you sure you want to delete this child profile? All associated poop entries will also be deleted. This action cannot be undone.',
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
              _deleteProfile();
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

  void _deleteProfile() {
    if (widget.child == null || widget.child!.id == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    context.read<ChildBloc>().add(DeleteChildEvent(widget.child!.id!));
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