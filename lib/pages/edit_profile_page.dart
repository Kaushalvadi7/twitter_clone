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
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
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
                          ? const Icon(Icons.person, size: 50)
                          : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: "Bio"),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _birthDateController,
                readOnly: true,
                onTap: _selectBirthDate,
                decoration: const InputDecoration(labelText: "Birth Date"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                child:
                    _isSaving
                        ? const CircularProgressIndicator()
                        : const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
