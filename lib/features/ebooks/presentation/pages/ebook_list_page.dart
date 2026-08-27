import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/theme_bloc.dart';
import '../../domain/entities/ebook_entity.dart';
import '../bloc/ebook_bloc.dart';
import '../bloc/ebook_event.dart';
import '../bloc/ebook_state.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/download_progress_indicator.dart';
import '../widgets/ebook_card.dart';
import '../widgets/ebook_grid_card.dart';
import '../widgets/featured_carousel_widget.dart';
import '../widgets/glass_container.dart';
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
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          AppStrings.confirmDeleteTitle,
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to remove "${ebook.title}" from your library collection?',
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
        elevation: 12,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          AppStrings.uploadButton,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<EbookBloc, EbookState>(
          listener: (context, state) {
            if (state is EbookOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            } else if (state is EbookError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
          builder: (context, state) {
            String selectedCategory = 'All';
            String searchQuery = '';
            double downloadProgress = 0.0;
            List<EbookEntity> displayedEbooks = [];
            List<EbookEntity> allEbooks = [];

            if (state is EbooksLoaded) {
              selectedCategory = state.selectedCategory;
              searchQuery = state.searchQuery;
              displayedEbooks = state.filteredEbooks;
              allEbooks = state.ebooks;
            } else if (state is EbookDownloading) {
              downloadProgress = state.progress;
            }

            final featuredEbook = allEbooks.isNotEmpty ? allEbooks.first : null;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Header Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppStrings.appTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                                    const Text(
                                      AppStrings.subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Action Buttons: Theme Toggle, View Toggle & Refresh
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BlocBuilder<ThemeBloc, ThemeState>(
                              builder: (context, themeState) {
                                final isDark = themeState.isDarkMode;
                                return IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(6),
                                  icon: Icon(
                                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                    color: isDark ? AppColors.accent : AppColors.primary,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    context.read<ThemeBloc>().add(const ToggleTheme());
                                  },
                                  tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                                );
                              },
                            ),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                              icon: Icon(
                                _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                                color: AppColors.textSecondary,
                                size: 22,
                              ),
                              onPressed: () => setState(() => _isGridView = !_isGridView),
                              tooltip: _isGridView ? 'Switch to List' : 'Switch to Grid',
                            ),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                              icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 22),
                              onPressed: () => context.read<EbookBloc>().add(const FetchEbooks()),
                              tooltip: 'Refresh Library',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: SearchBarWidget(
                      initialValue: searchQuery,
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ),

                // Category Chips Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CategoryFilterChips(
                      selectedCategory: selectedCategory,
                      onSelected: _onCategorySelected,
                    ),
                  ),
                ),

                // Active Download Indicator Banner
                if (state is EbookDownloading)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: DownloadProgressIndicator(progress: downloadProgress),
                    ),
                  ),

                // Featured Pick Showcase (only shown when in 'All' category and empty search)
                if (featuredEbook != null && selectedCategory == 'All' && searchQuery.isEmpty)
                  SliverToBoxAdapter(
                    child: FeaturedCarouselWidget(
                      ebook: featuredEbook,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<EbookBloc>(),
                              child: EbookDetailPage(ebook: featuredEbook),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Section Header Title & Item Count
                if (displayedEbooks.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Row(
                        children: [
                          Text(
                            selectedCategory == 'All' ? 'All E-Books' : selectedCategory,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GlassContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            borderRadius: BorderRadius.circular(10),
                            child: Text(
                              '${displayedEbooks.length}',
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Main Content List or Grid Area
                if (state is EbookLoading || state is EbookInitial)
                  const SliverFillRemaining(
                    child: LoadingView(message: AppStrings.loadingEbooks),
                  )
                else if (state is EbookError)
                  SliverFillRemaining(
                    child: ErrorView(
                      message: state.message,
                      onRetry: () => context.read<EbookBloc>().add(const FetchEbooks()),
                    ),
                  )
                else if (state is EbookEmpty || displayedEbooks.isEmpty)
                  SliverFillRemaining(
                    child: EmptyView(
                      message: state is EbookEmpty ? state.message : AppStrings.noEbooksFound,
                      onReset: () => context.read<EbookBloc>().add(const FetchEbooks()),
                    ),
                  )
                else if (_isGridView)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final ebook = displayedEbooks[index];
                          return EbookGridCard(
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
                        childCount: displayedEbooks.length,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final ebook = displayedEbooks[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EbookCard(
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
                            ),
                          );
                        },
                        childCount: displayedEbooks.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
