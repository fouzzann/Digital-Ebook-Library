import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/image_utils.dart';
import '../../domain/entities/ebook_entity.dart';
import '../bloc/download_bloc.dart';
import '../bloc/download_event.dart';
import '../bloc/download_state.dart';
import '../bloc/ebook_bloc.dart';
import '../bloc/ebook_event.dart';
import '../widgets/glass_container.dart';
import 'pdf_reader_page.dart';

class EbookDetailPage extends StatelessWidget {
  final EbookEntity ebook;

  const EbookDetailPage({super.key, required this.ebook});

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          AppStrings.confirmDeleteTitle,
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          AppStrings.confirmDeleteMessage,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancelButton, style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<EbookBloc>().add(DeleteEbook(ebook.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(AppStrings.deleteButton, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Cover Image Blur Effect
          Positioned.fill(
            child: buildEbookCoverImage(coverUrl: ebook.coverUrl, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                color: AppColors.background.withValues(alpha: 0.85),
              ),
            ),
          ),

          // Main Scrollable Details Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Image & Title Header
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                backgroundColor: AppColors.surface.withValues(alpha: 0.6),
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GlassContainer(
                    onTap: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(12),
                    child: const Center(
                      child: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GlassContainer(
                      onTap: () => _showDeleteConfirmation(context),
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned(
                        top: 80,
                        child: Hero(
                          tag: 'cover_${ebook.id}',
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: buildEbookCoverImage(
                                coverUrl: ebook.coverUrl,
                                width: 160,
                                height: 230,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Book Title & Metadata Overview
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    children: [
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          ebook.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        ebook.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Author
                      Text(
                        'by ${ebook.author}',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stat Cards Grid Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(child: _buildStatTile('Rating', ebook.rating.toStringAsFixed(1), Icons.star_rounded, AppColors.accent)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildStatTile('Format', ebook.format, Icons.description_rounded, AppColors.primaryLight)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildStatTile('Size', ebook.fileSize, Icons.folder_rounded, AppColors.secondary)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildStatTile('Year', ebook.publishedYear.toString(), Icons.calendar_today_rounded, AppColors.emerald)),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Description Section
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Synopsis & Key Insights',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          ebook.description.isNotEmpty
                              ? ebook.description
                              : 'No detailed synopsis available for this title in the digital index.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.65,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Action Buttons Row: Read Now (Primary) & Download (Secondary)
                      Column(
                        children: [
                          // Primary Action: Read Now
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PdfReaderPage(ebook: ebook),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 24),
                              label: const Text(
                                'Read Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Secondary Action: Download E-Book
                          BlocConsumer<DownloadBloc, DownloadState>(
                            listener: (context, state) {
                              if (state is DownloadSuccess && state.ebookId == ebook.id) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('E-book downloaded successfully! Available for offline reading.'),
                                    backgroundColor: AppColors.emerald,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } else if (state is DownloadFailure && state.ebookId == ebook.id) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(state.message),
                                    backgroundColor: AppColors.error,
                                    behavior: SnackBarBehavior.floating,
                                    action: SnackBarAction(
                                      label: 'Retry',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        context.read<DownloadBloc>().add(StartDownload(
                                              ebookId: ebook.id,
                                              downloadUrl: ebook.downloadUrl,
                                              title: ebook.title,
                                            ));
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                            builder: (context, state) {
                              final isDownloading = state is DownloadInProgress && state.ebookId == ebook.id;
                              final isDownloaded = (state is DownloadSuccess && state.ebookId == ebook.id) || ebook.isDownloaded;
                              final progress = isDownloading ? state.progress : 0.0;

                              return Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isDownloaded ? AppColors.emerald : AppColors.border,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: OutlinedButton.icon(
                                      onPressed: isDownloading
                                          ? null
                                          : () {
                                              context.read<DownloadBloc>().add(StartDownload(
                                                    ebookId: ebook.id,
                                                    downloadUrl: ebook.downloadUrl,
                                                    title: ebook.title,
                                                  ));
                                              context.read<EbookBloc>().add(DownloadEbook(ebook.id));
                                            },
                                      icon: Icon(
                                        isDownloaded
                                            ? Icons.check_circle_rounded
                                            : isDownloading
                                                ? Icons.downloading_rounded
                                                : Icons.download_rounded,
                                        color: isDownloaded ? AppColors.emerald : AppColors.textPrimary,
                                      ),
                                      label: Text(
                                        isDownloaded
                                            ? 'Downloaded (${ebook.fileSize})'
                                            : isDownloading
                                                ? 'Downloading ${(progress * 100).toInt()}%'
                                                : 'Download File (${ebook.fileSize})',
                                        style: TextStyle(
                                          color: isDownloaded ? AppColors.emerald : AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (isDownloading) ...[
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: AppColors.surfaceLight,
                                        color: AppColors.primary,
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
