import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/ebook_entity.dart';
import '../bloc/ebook_bloc.dart';
import '../bloc/ebook_event.dart';
import '../bloc/ebook_state.dart';

class UploadEbookPage extends StatefulWidget {
  const UploadEbookPage({super.key});

  @override
  State<UploadEbookPage> createState() => _UploadEbookPageState();
}

class _UploadEbookPageState extends State<UploadEbookPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _yearController = TextEditingController(text: DateTime.now().year.toString());

  String _selectedCategory = AppStrings.catScience;
  String _selectedFormat = 'PDF';
  final String _selectedFileSize = '4.5 MB';

  final List<String> _categories = [
    AppStrings.catScience,
    AppStrings.catFiction,
    AppStrings.catBusiness,
    AppStrings.catHistory,
    AppStrings.catPhilosophy,
  ];

  final List<String> _formats = ['PDF', 'EPUB', 'MOBI'];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _coverUrlController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _submitUpload() {
    if (_formKey.currentState!.validate()) {
      final ebook = EbookEntity(
        id: '',
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        coverUrl: _coverUrlController.text.trim(),
        downloadUrl: 'https://example.com/ebooks/uploaded.pdf',
        fileSize: _selectedFileSize,
        format: _selectedFormat,
        publishedYear: int.tryParse(_yearController.text) ?? DateTime.now().year,
        rating: 5.0,
      );

      context.read<EbookBloc>().add(UploadEbook(ebook));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          AppStrings.uploadButton,
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<EbookBloc, EbookState>(
        listener: (context, state) {
          if (state is EbookOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          } else if (state is EbookError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New E-Book to Library',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Provide book details to index it in your personal digital repository.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Title
                _buildLabel(AppStrings.titleLabel),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('e.g. Masterlink Architecture'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),

                // Author
                _buildLabel(AppStrings.authorLabel),
                TextFormField(
                  controller: _authorController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('e.g. Ada Lovelace'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Author is required' : null,
                ),
                const SizedBox(height: 16),

                // Category & Format Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(AppStrings.categoryLabel),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            dropdownColor: AppColors.surface,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: _inputDecoration('Category'),
                            items: _categories.map((c) {
                              return DropdownMenuItem(value: c, child: Text(c));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedCategory = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(AppStrings.formatLabel),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedFormat,
                            dropdownColor: AppColors.surface,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: _inputDecoration('Format'),
                            items: _formats.map((f) {
                              return DropdownMenuItem(value: f, child: Text(f));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedFormat = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cover Image URL
                _buildLabel('Cover Image URL (Optional)'),
                TextFormField(
                  controller: _coverUrlController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('https://images.unsplash.com/...'),
                ),
                const SizedBox(height: 16),

                // Description
                _buildLabel(AppStrings.descriptionLabel),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('Enter a comprehensive overview of the book...'),
                ),
                const SizedBox(height: 32),

                // Submit Button
                BlocBuilder<EbookBloc, EbookState>(
                  builder: (context, state) {
                    final isUploading = state is EbookUploading;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isUploading ? null : _submitUpload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isUploading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Uploading...', style: TextStyle(color: Colors.white, fontSize: 16)),
                                ],
                              )
                            : const Text(
                                AppStrings.uploadButton,
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
