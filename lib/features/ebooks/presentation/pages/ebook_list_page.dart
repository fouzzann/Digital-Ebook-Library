import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/ebook_entity.dart';
import '../bloc/ebook_bloc.dart';
import '../bloc/ebook_event.dart';
import '../bloc/ebook_state.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/download_progress_indicator.dart';
import '../widgets/ebook_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/state_views/empty_view.dart';
import '../widgets/state_views/error_view.dart';
import '../widgets/state_views/loading_view.dart';
import 'ebook_detail_page.dart';
import 'upload_ebook_page.dart';

class EbookListPage extends StatefulWidget {
  const EbookListPage({super.key});

  @override
  State<EbookListPage> createState() => _EbookListPageState();
}

class _EbookListPageState extends State<EbookListPage> {
  @override
  void initState() {
    super.initState();
    // Dispatch FetchEbooks event on load
    context.read<EbookBloc>().add(const FetchEbooks());
  }

  void _onSearchChanged(String query) {
    context.read<EbookBloc>().add(SearchEbooks(query));
  }

  void _onCategorySelected(String category) {
    context.read<EbookBloc>().add(FilterEbooksByCategory(category));
  }

  void _showDeleteConfirmation(BuildContext context, EbookEntity ebook) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          AppStrings.confirmDeleteTitle,
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${ebook.title}" from your library?',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.deleteButton, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_stories_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              AppStrings.appTitle,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: () => context.read<EbookBloc>().add(const FetchEbooks()),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<EbookBloc>(),
                child: const UploadEbookPage(),
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          AppStrings.uploadButton,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<EbookBloc, EbookState>(
        listener: (context, state) {
          if (state is EbookOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
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
        builder: (context, state) {
          String selectedCategory = 'All';
          String searchQuery = '';
          double downloadProgress = 0.0;
          List<EbookEntity> displayedEbooks = [];

          if (state is EbooksLoaded) {
            selectedCategory = state.selectedCategory;
            searchQuery = state.searchQuery;
            displayedEbooks = state.filteredEbooks;
          } else if (state is EbookDownloading) {
            downloadProgress = state.progress;
          }

          return Column(
            children: [
              // Top Search & Header Section
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    SearchBarWidget(
                      initialValue: searchQuery,
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 12),
                    CategoryFilterChips(
                      selectedCategory: selectedCategory,
                      onSelected: _onCategorySelected,
                    ),
                  ],
                ),
              ),

              // Active Download Indicator Banner
              if (state is EbookDownloading)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DownloadProgressIndicator(progress: downloadProgress),
                ),

              // Main State-driven Content Area
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state is EbookLoading || state is EbookInitial) {
                      return const LoadingView(message: AppStrings.loadingEbooks);
                    } else if (state is EbookError) {
                      return ErrorView(
                        message: state.message,
                        onRetry: () => context.read<EbookBloc>().add(const FetchEbooks()),
                      );
                    } else if (state is EbookEmpty) {
                      return EmptyView(
                        message: state.message,
                        onReset: () {
                          context.read<EbookBloc>().add(const FetchEbooks());
                        },
                      );
                    }

                    if (displayedEbooks.isEmpty) {
                      return EmptyView(
                        onReset: () {
                          context.read<EbookBloc>().add(const FetchEbooks());
                        },
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: displayedEbooks.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final ebook = displayedEbooks[index];
                        return EbookCard(
                          ebook: ebook,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<EbookBloc>(),
                                  child: EbookDetailPage(ebook: ebook),
                                ),
                              ),
                            );
                          },
                          onDownload: () {
                            context.read<EbookBloc>().add(DownloadEbook(ebook.id));
                          },
                          onDelete: () {
                            _showDeleteConfirmation(context, ebook);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
