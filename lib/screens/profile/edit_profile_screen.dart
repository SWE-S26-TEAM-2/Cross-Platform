import 'package:dio/dio.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../services/user_profile_services.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _bioController;

  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedAvatarFile;
  File? _selectedCoverFile;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;

    _displayNameController = TextEditingController(text: user?.userName ?? '');
    _cityController = TextEditingController(text: user?.location ?? '');
    _countryController = TextEditingController(text: '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final authState = ref.read(authProvider);
    final token = authState.tokens?.accessToken;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No access token found')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userService = UserService(dio: Dio());

      final updatedUser = await userService.updateMe(
        accessToken: token,
        displayName: _displayNameController.text.trim().isEmpty
            ? null
            : _displayNameController.text.trim(),
        location: _cityController.text.trim(),
        bio: _bioController.text.trim(),
      );

      final currentState = ref.read(authProvider);
      ref.read(authProvider.notifier).state = AuthState(
        tokens: currentState.tokens,
        user: updatedUser,
        isLoading: false,
        error: null,
        successMessage: currentState.successMessage,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final authState = ref.read(authProvider);
    final token = authState.tokens?.accessToken;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No access token found')));
      return;
    }

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) return;

      final originalFile = File(pickedFile.path);
      final compressedFile = await _compressImage(originalFile);

      setState(() {
        _selectedAvatarFile = compressedFile;
      });

      final userService = UserService(dio: Dio());

      await userService.uploadAvatar(
        accessToken: token,
        filePath: compressedFile.path,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile picture updated')));
    } catch (e) {
      print('AVATAR UPLOAD ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload avatar: $e')));
    }
  }

  Future<File> _compressImage(File file) async {
    final bytes = await file.readAsBytes();

    final Uint8List? compressedBytes =
        await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: 1080,
          minHeight: 1080,
          quality: 70,
          format: CompressFormat.jpeg,
        );

    if (compressedBytes == null) {
      return file;
    }

    final tempPath = '${file.path}_compressed.jpg';
    final compressedFile = File(tempPath);
    await compressedFile.writeAsBytes(compressedBytes);

    return compressedFile;
  }

  Widget _buildEditableRow({
    required String label,
    required TextEditingController controller,
    String? trailingText,
    bool showArrow = false,
    int? maxLength,
    int maxLines = 1,
    String? hintText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF151515), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFB3B3B3),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  maxLength: maxLength,
                  maxLines: maxLines,
                  cursorColor: Colors.white,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    counterText: '',
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      color: Color(0xFF8A8A8A),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          if (trailingText != null) ...[
            const SizedBox(width: 12),
            Text(
              trailingText,
              style: const TextStyle(
                color: Color(0xFFD0D0D0),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (showArrow) ...[
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 22),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final avatarUrl = user?.avatarUrl;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leadingWidth: 90,
        leading: TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 210,
                  width: double.infinity,
                  color: Colors.black,
                ),
                Positioned(
                  right: 20,
                  top: 82,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                ),
                Positioned(
                  left: 28,
                  bottom: -36,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      print('AVATAR AREA TAPPED');
                      _pickAndUploadAvatar();
                    },
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 42,
                              backgroundColor: const Color(0xFF1E1E1E),
                              backgroundImage: _selectedAvatarFile != null
                                  ? FileImage(_selectedAvatarFile!)
                                  : (avatarUrl != null && avatarUrl.isNotEmpty)
                                  ? NetworkImage(avatarUrl) as ImageProvider
                                  : null,
                              child:
                                  (_selectedAvatarFile == null &&
                                      (avatarUrl == null || avatarUrl.isEmpty))
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 42,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 52),
            _buildEditableRow(
              label: 'Display name',
              controller: _displayNameController,
              trailingText: '36',
              maxLength: 36,
              hintText: 'Add display name',
            ),
            _buildEditableRow(
              label: 'City',
              controller: _cityController,
              trailingText: '31',
              maxLength: 31,
              hintText: 'Add city',
            ),
            _buildEditableRow(
              label: 'Country',
              controller: _countryController,
              showArrow: true,
              hintText: 'Add country',
            ),
            _buildEditableRow(
              label: 'Bio',
              controller: _bioController,
              showArrow: true,
              maxLines: 2,
              hintText: 'Tell the world a bit about yourself',
            ),
          ],
        ),
      ),
    );
  }
}
