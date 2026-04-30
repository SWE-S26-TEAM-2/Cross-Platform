import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/track_provider.dart';

class UploadTrackSheet extends ConsumerStatefulWidget {
  const UploadTrackSheet({super.key});

  @override
  ConsumerState<UploadTrackSheet> createState() => _UploadTrackSheetState();
}

class _UploadTrackSheetState extends ConsumerState<UploadTrackSheet> {
  String? filePath;
  String? fileName;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac'],
      allowMultiple: false,
    );

    if (result == null) return;

    final pickedPath = result.files.single.path;

    if (pickedPath == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read selected file.')),
      );
      return;
    }

    setState(() {
      filePath = pickedPath;
      fileName = result.files.single.name;
    });
  }

  Future<void> upload() async {
    final String title = titleController.text.trim();
    final String description = descController.text.trim();

    if (filePath == null || filePath!.isEmpty || title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select an audio file and enter a title.'),
        ),
      );
      return;
    }

    try {
      await ref
          .read(createTrackProvider.notifier)
          .create(title: title, description: description, filePath: filePath!);

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Track uploaded successfully.')),
      );
    } catch (e) {
      if (!mounted) return;

      final String message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(createTrackProvider);
    final bool isUploading = uploadState.isLoading;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Upload Track',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                enabled: !isUploading,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                enabled: !isUploading,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: isUploading ? null : pickFile,
                icon: const Icon(Icons.audio_file),
                label: Text(fileName ?? 'Pick Audio File'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isUploading ? null : upload,
                  child: isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Upload'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
