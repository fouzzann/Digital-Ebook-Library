import 'dart:io' as io;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/ebook_entity.dart';
import '../bloc/ebook_bloc.dart';
import '../bloc/ebook_event.dart';
import '../bloc/ebook_state.dart';
import '../widgets/glass_container.dart';

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
  String _selectedFileSize = '0 MB';
  PlatformFile? _selectedFile;
  String? _fileError;

  bool _useLocalCover = true;
  PlatformFile? _selectedCoverFile;
  Uint8List? _coverBytes;

  final List<String> _categories = [
    AppStrings.catScience,
    AppStrings.catFiction,
    AppStrings.catBusiness,
    AppStrings.catHistory,
    AppStrings.catPhilosophy,
  ];

  final List<String> _formats = ['PDF', 'EPUB', 'MOBI', 'TXT'];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _coverUrlController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  String _formatTitleFromFileName(String fileName) {
    String name = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    name = name.replaceAll(RegExp(r'[-_]'), ' ');
    name = name.replaceAll(RegExp(r'(?<=[a-z])(?=[A-Z])'), ' ');
    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (name.isEmpty) return '';

    return name.split(' ').map((word) {
      if (word.isEmpty) return '';
      if (word.length == 1) return word.toUpperCase();
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub', 'mobi', 'txt'],
      );

      if (result.isNotEmpty) {
        final file = result.first;
        final ext = (file.extension ?? '').toUpperCase();
        String computedFormat = 'PDF';
        if (ext == 'EPUB') computedFormat = 'EPUB';
        if (ext == 'MOBI') computedFormat = 'MOBI';
        if (ext == 'TXT') computedFormat = 'TXT';
        if (ext == 'PDF') computedFormat = 'PDF';

        final int byteLength = await file.length();
        final double sizeInMb = byteLength / (1024 * 1024);
        final String formattedSize = sizeInMb >= 0.1
            ? '${sizeInMb.toStringAsFixed(1)} MB'
            : '${(byteLength / 1024).toStringAsFixed(1)} KB';

        setState(() {
          _selectedFile = file;
          _fileError = null;
          _selectedFormat = computedFormat;
          _selectedFileSize = formattedSize;

          if (_titleController.text.trim().isEmpty) {
            _titleController.text = _formatTitleFromFileName(file.name);
          }
        });
      }
    } catch (e) {
      setState(() {
        _fileError = 'Failed to pick file: $e';
      });
    }
  }

  Future<void> _pickCoverFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      );

      if (result.isNotEmpty) {
        final file = result.first;
        Uint8List? bytes;
        if (kIsWeb || file.path == null) {
          bytes = await file.readAsBytes();
        }

        if (!mounted) return;

        setState(() {
          _selectedCoverFile = file;
          _coverBytes = bytes;
          _coverUrlController.text = file.path ?? file.name;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick cover image: $e')),
      );
    }
  }

  void _submitUpload() {
    final bool hasFile = _selectedFile != null;
    if (!hasFile) {
      setState(() {
        _fileError = 'Please select a PDF or e-book file to upload';
      });
    }

    String coverUrl = _coverUrlController.text.trim();
    if (_useLocalCover && _selectedCoverFile != null) {
      coverUrl = _selectedCoverFile!.path ?? _selectedCoverFile!.name;
    }

    if (_formKey.currentState!.validate() && hasFile) {
      final ebook = EbookEntity(
        id: '',
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        coverUrl: coverUrl,
        downloadUrl: _selectedFile?.path ?? _selectedFile?.name ?? 'https://example.com/ebooks/uploaded.pdf',
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
                backgroundColor: AppColors.emerald,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          } else if (state is EbookError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Index New E-Book',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Add PDF publications to your digital workspace',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // File Selector Zone
                _buildFilePickerSection(),
                const SizedBox(height: 20),

                // Title
                _buildLabel(AppStrings.titleLabel),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('e.g. Designing Data-Intensive Applications'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),

                // Author
                _buildLabel(AppStrings.authorLabel),
                TextFormField(
                  controller: _authorController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('e.g. Martin Kleppmann'),
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

                // Cover Image Section (Local File or URL)
                _buildCoverImageSection(),
                const SizedBox(height: 16),

                // Description
                _buildLabel(AppStrings.descriptionLabel),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('Provide key takeaways and overview...'),
                ),
                const SizedBox(height: 32),

                // Submit Button
                BlocBuilder<EbookBloc, EbookState>(
                  builder: (context, state) {
                    final isUploading = state is EbookUploading;
                    return Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isUploading ? null : _submitUpload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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
                                  Text('Indexing E-Book...', style: TextStyle(color: Colors.white, fontSize: 16)),
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

  Widget _buildCoverImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel('Book Cover Image (Optional)'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _useLocalCover = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _useLocalCover ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.sd_storage_rounded, size: 13, color: _useLocalCover ? Colors.white : AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            'Local File',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _useLocalCover ? Colors.white : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _useLocalCover = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: !_useLocalCover ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.link_rounded, size: 13, color: !_useLocalCover ? Colors.white : AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            'URL Link',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: !_useLocalCover ? Colors.white : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_useLocalCover) ...[
          if (_selectedCoverFile == null)
            GestureDetector(
              onTap: _pickCoverFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Browse Cover Image (PNG, JPG, WEBP)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.image_rounded, color: AppColors.emerald, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedCoverFile!.name,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: _pickCoverFile,
                    child: const Text('Change', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.error, size: 18),
                    onPressed: () {
                      setState(() {
                        _selectedCoverFile = null;
                        _coverUrlController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
        ] else ...[
          TextFormField(
            controller: _coverUrlController,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration('https://images.unsplash.com/...'),
          ),
        ],
        _buildCoverPreview(),
      ],
    );
  }

  Widget _buildCoverPreview() {
    if (_selectedCoverFile == null && _coverUrlController.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    Widget imageWidget;
    if (_useLocalCover && _selectedCoverFile != null) {
      if (!kIsWeb && _selectedCoverFile!.path != null) {
        imageWidget = Image.file(
          io.File(_selectedCoverFile!.path!),
          height: 140,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _errorCoverWidget(),
        );
      } else if (_coverBytes != null) {
        imageWidget = Image.memory(
          _coverBytes!,
          height: 140,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _errorCoverWidget(),
        );
      } else {
        imageWidget = _errorCoverWidget();
      }
    } else if (_coverUrlController.text.trim().isNotEmpty) {
      imageWidget = Image.network(
        _coverUrlController.text.trim(),
        height: 140,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _errorCoverWidget(),
      );
    } else {
      return const SizedBox.shrink();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: GlassContainer(
          padding: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageWidget,
          ),
        ),
      ),
    );
  }

  Widget _errorCoverWidget() {
    return Container(
      height: 140,
      width: 100,
      color: AppColors.surfaceLight,
      child: const Center(
        child: Icon(Icons.broken_image_rounded, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildFilePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('E-Book File (PDF Format Supported) *'),
        const SizedBox(height: 4),
        if (_selectedFile == null)
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _fileError != null ? AppColors.error : AppColors.primary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Select PDF or E-Book File',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to browse device storage (PDF, EPUB, MOBI)',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: ['PDF (Default)', 'EPUB', 'MOBI', 'TXT'].map((fmt) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: fmt.startsWith('PDF')
                              ? AppColors.primary.withValues(alpha: 0.25)
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: fmt.startsWith('PDF') ? AppColors.primary : AppColors.border,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          fmt,
                          style: TextStyle(
                            color: fmt.startsWith('PDF') ? Colors.white : AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.6), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.emerald.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: AppColors.emerald,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFile!.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _selectedFormat,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedFileSize,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
                  tooltip: 'Change File',
                  onPressed: _pickFile,
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.error),
                  tooltip: 'Remove File',
                  onPressed: () {
                    setState(() {
                      _selectedFile = null;
                    });
                  },
                ),
              ],
            ),
          ),
        if (_fileError != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              _fileError!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        ],
      ],
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
      fillColor: AppColors.surface.withValues(alpha: 0.7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}

