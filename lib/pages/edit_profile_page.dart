import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/cloudinary/cloudinary_service.dart';
import '../services/database/database_provider.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile user;

  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _birthDateController;
  File? _pickedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _usernameController = TextEditingController(text: widget.user.username);
    _bioController = TextEditingController(text: widget.user.bio);
    _birthDateController = TextEditingController(
      text: widget.user.birthDate ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<void> _selectBirthDate() async {
    DateTime initialDate =
        widget.user.birthDate != null && widget.user.birthDate!.isNotEmpty
            ? DateTime.tryParse(widget.user.birthDate!) ?? DateTime(2000)
            : DateTime(2000);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthDateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    String? imageUrl = widget.user.profileImageUrl;

    if (_pickedImage != null) {
      final uploadedUrl = await CloudinaryService.uploadImageToCloudinary(
        _pickedImage!,
      );
      if (uploadedUrl != null) {
        imageUrl = uploadedUrl;
      }
    }

    await Provider.of<DatabaseProvider>(
      context,
      listen: false,
    ).updateUserProfile(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      profileImageUrl: imageUrl,
      birthDate: _birthDateController.text.trim(),
    );

    await Provider.of<DatabaseProvider>(
      context,
      listen: false,
    ).updateBio(_bioController.text.trim());

    setState(() {
      _isSaving = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.inversePrimary),
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          title: Text("Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.inversePrimary),),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveChanges,
            child: _isSaving
                ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
                : const Text(
              "Save",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : (widget.user.profileImageUrl != null &&
                                widget.user.profileImageUrl!.isNotEmpty)
                            ? NetworkImage(widget.user.profileImageUrl!)
                                as ImageProvider
                            : null,
                    child:
                        _pickedImage == null &&
                                (widget.user.profileImageUrl == null ||
                                    widget.user.profileImageUrl!.isEmpty)
                            ? Icon(Icons.person, size: 60)
                            : null,
                  ),
                ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _nameController,
                labelText: "Name",
                icon: Icons.person,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _usernameController,
                labelText: "Username",
                icon: Icons.account_circle,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _bioController,
                labelText: "Bio",
                icon: Icons.info,
                maxLines: 4,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _birthDateController,
                labelText: "Birth Date",
                icon: Icons.calendar_today,
                readOnly: true,
                onTap: _selectBirthDate,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
    int? maxLines,
  }) {
    return TextField(

      style: TextStyle(fontSize: 16,),
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
        filled: true,
        // fillColor: Colors.grey[100],
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      ),
    );
  }
}

