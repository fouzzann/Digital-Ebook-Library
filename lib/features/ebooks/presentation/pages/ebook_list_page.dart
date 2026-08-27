import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/theme/theme_bloc.dart';
import '../../../../core/widgets/theme_transition_overlay.dart';
import '../../data/datasources/ebook_local_data_source.dart';
import '../../domain/entities/ebook_entity.dart';
import '../bloc/download_bloc.dart';
import '../bloc/download_event.dart';
import '../bloc/download_state.dart';
import '../bloc/ebook_bloc.dart';
import '../bloc/ebook_event.dart';
import '../bloc/ebook_state.dart';
import '../widgets/bookshelf_view_widget.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/download_progress_indicator.dart';
import '../widgets/ebook_card.dart';
import '../widgets/ebook_grid_card.dart';
import '../widgets/featured_carousel_widget.dart';
import '../widgets/glass_container.dart';
import '../widgets/recently_read_widget.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/state_views/empty_view.dart';
import '../widgets/state_views/error_view.dart';
import '../widgets/state_views/loading_view.dart';
import 'ebook_detail_page.dart';
import 'upload_ebook_page.dart';

enum LibraryViewMode { list, grid, bookshelf }

class EbookListPage extends StatefulWidget {
  const EbookListPage({super.key});

  @override
  State<EbookListPage> createState() => _EbookListPageState();
}

class _EbookListPageState extends State<EbookListPage> {
  LibraryViewMode _viewMode = LibraryViewMode.bookshelf;
  String _selectedFormatFilter = 'All';
  SortOption _selectedSortOption = SortOption.recentlyUploaded;

  List<EbookEntity> _cachedDisplayedEbooks = [];
  List<EbookEntity> _cachedAllEbooks = [];
  String _cachedCategory = 'All';
  String _cachedSearchQuery = '';
  List<EbookEntity> _recentlyReadEbooks = [];

  final List<String> _formats = ['All', 'PDF', 'EPUB', 'MOBI', 'TXT'];

  @override
  void initState() {
    super.initState();
    _loadViewPreference();
    context.read<EbookBloc>().add(const FetchEbooks());
    _loadRecentlyRead();
  }

  void _loadViewPreference() {
    try {
      final prefs = sl<SharedPreferences>();
      final savedModeName = prefs.getString('library_view_mode');
      if (savedModeName != null) {
        final savedMode = LibraryViewMode.values.firstWhere(
          (e) => e.name == savedModeName,
          orElse: () => LibraryViewMode.bookshelf,
        );
        setState(() => _viewMode = savedMode);
      }
    } catch (_) {}
  }

  Future<void> _loadRecentlyRead() async {
    try {
      final localDS = sl<EbookLocalDataSource>();
      final ids = await localDS.getRecentlyReadIds();
      if (!mounted) return;
      setState(() {
        _recentlyReadEbooks = _cachedAllEbooks.where((e) => ids.contains(e.id)).toList();
      });
    } catch (_) {}
  }

  void _onSearchChanged(String query) {
    context.read<EbookBloc>().add(SearchEbooks(query));
  }

  void _onCategorySelected(String category) {
    context.read<EbookBloc>().add(FilterEbooksByCategory(category));
  }

  void _onFormatSelected(String format) {
    setState(() => _selectedFormatFilter = format);
    context.read<EbookBloc>().add(FilterEbooksByFormat(format));
  }

  void _onSortSelected(SortOption option) {
    setState(() => _selectedSortOption = option);
    context.read<EbookBloc>().add(SortEbooks(option));
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

  void _openEbookDetail(EbookEntity ebook) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<EbookBloc>(),
          child: EbookDetailPage(ebook: ebook),
        ),
      ),
    ).then((_) => _loadRecentlyRead());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
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
        child: MultiBlocListener(
          listeners: [
            BlocListener<EbookBloc, EbookState>(
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
                  _loadRecentlyRead();
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
            ),
            BlocListener<DownloadBloc, DownloadState>(
              listener: (context, state) {
                if (state is DownloadSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Ebook downloaded successfully.'),
                      backgroundColor: AppColors.emerald,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      action: SnackBarAction(
                        label: 'Open File',
                        textColor: Colors.white,
                        onPressed: () async {
                          try {
                            await OpenFilex.open(state.savedFilePath);
                          } catch (_) {}
                        },
                      ),
                    ),
                  );
                } else if (state is DownloadFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      action: SnackBarAction(
                        label: 'Retry',
                        textColor: Colors.white,
                        onPressed: () {
                          context.read<DownloadBloc>().add(StartDownload(
                                ebookId: state.ebookId,
                                downloadUrl: '',
                                title: 'E-Book',
                              ));
                        },
                      ),
                    ),
                  );
                }
              },
            ),
          ],
          child: BlocBuilder<EbookBloc, EbookState>(
            buildWhen: (previous, current) => current is! EbookOperationSuccess,
          builder: (context, state) {
            double downloadProgress = 0.0;

            if (state is EbooksLoaded) {
              _cachedCategory = state.selectedCategory;
              _cachedSearchQuery = state.searchQuery;
              _cachedDisplayedEbooks = state.filteredEbooks;
              _cachedAllEbooks = state.ebooks;
              _selectedFormatFilter = state.selectedFormat;
              _selectedSortOption = state.sortOption;
            } else if (state is EbookDownloading) {
              downloadProgress = state.progress;
            }

            final selectedCategory = _cachedCategory;
            final searchQuery = _cachedSearchQuery;
            final displayedEbooks = _cachedDisplayedEbooks;
            final allEbooks = _cachedAllEbooks;

            final featuredEbook = allEbooks.isNotEmpty ? allEbooks.first : null;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'asset/App icon.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      padding: const EdgeInsets.all(9),
                                      decoration: BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ),
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
                                        color: AppColors.getTextPrimary(context),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      AppStrings.subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: AppColors.getTextMuted(context), fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Action Buttons: Theme Toggle, View Mode Selector (List, Grid, Bookshelf) & Sort Menu
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BlocBuilder<ThemeBloc, ThemeState>(
                              builder: (context, themeState) {
                                final isDark = themeState.isDarkMode;
                                return IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                  icon: Icon(
                                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                    color: isDark ? AppColors.accent : AppColors.primary,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    final willBeDark = !isDark;
                                    ThemeTransitionOverlay.show(context, isDarkTarget: willBeDark);
                                    context.read<ThemeBloc>().add(const ToggleTheme());
                                  },
                                  tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                                );
                              },
                            ),
                            // View Mode Segmented Controls
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: AppColors.getSurface(context),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.getBorder(context)),
                              ),
                              child: Row(
                                children: [
                                  _buildViewIconButton(
                                    icon: Icons.grid_view_rounded,
                                    mode: LibraryViewMode.grid,
                                    tooltip: 'Grid View',
                                  ),
                                  _buildViewIconButton(
                                    icon: Icons.view_list_rounded,
                                    mode: LibraryViewMode.list,
                                    tooltip: 'List View',
                                  ),
                                  _buildViewIconButton(
                                    icon: Icons.shelves,
                                    mode: LibraryViewMode.bookshelf,
                                    tooltip: 'Classic Bookshelf UI',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),

                            // Sort Options Menu
                            PopupMenuButton<SortOption>(
                              icon: Icon(Icons.sort_rounded, color: AppColors.getTextSecondary(context), size: 22),
                              tooltip: 'Sort E-Books',
                              color: AppColors.getSurface(context),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              onSelected: _onSortSelected,
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: SortOption.recentlyUploaded,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text('Recently Uploaded', style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 13)),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: SortOption.titleAsc,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.sort_by_alpha_rounded, size: 16, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text('Title (A - Z)', style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 13)),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: SortOption.authorAsc,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.person_rounded, size: 16, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text('Author (A - Z)', style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar Section (300ms Debounced)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: SearchBarWidget(
                      initialValue: searchQuery,
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ),

                // Recently Read Carousel Section
                if (_recentlyReadEbooks.isNotEmpty && searchQuery.isEmpty && selectedCategory == 'All')
                  SliverToBoxAdapter(
                    child: RecentlyReadWidget(
                      recentlyReadEbooks: _recentlyReadEbooks,
                      onEbookTap: _openEbookDetail,
                    ),
                  ),

                // Category Filter Chips Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: CategoryFilterChips(
                      selectedCategory: selectedCategory,
                      onSelected: _onCategorySelected,
                    ),
                  ),
                ),

                // Format Filter Chips Section (PDF, EPUB, MOBI, TXT)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                    child: Row(
                      children: [
                        Text(
                          'Format:',
                          style: TextStyle(color: AppColors.getTextMuted(context), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _formats.map((fmt) {
                                final isSelected = _selectedFormatFilter == fmt;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    label: Text(fmt),
                                    selected: isSelected,
                                    onSelected: (_) => _onFormatSelected(fmt),
                                    selectedColor: AppColors.primary,
                                    backgroundColor: AppColors.getSurface(context),
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.getTextSecondary(context),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
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
                if (featuredEbook != null && selectedCategory == 'All' && searchQuery.isEmpty && _selectedFormatFilter == 'All')
                  SliverToBoxAdapter(
                    child: FeaturedCarouselWidget(
                      ebook: featuredEbook,
                      onTap: () => _openEbookDetail(featuredEbook),
                    ),
                  ),

                // Section Header Title & Item Count
                if (displayedEbooks.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Row(
                        children: [
                          Text(
                            selectedCategory == 'All' ? 'Library Index' : selectedCategory,
                            style: TextStyle(
                              color: AppColors.getTextPrimary(context),
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
                          const Spacer(),
                          Text(
                            _getSortLabel(_selectedSortOption),
                            style: TextStyle(color: AppColors.getTextMuted(context), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Main Content List, Grid or Bookshelf View
                if ((state is EbookLoading || state is EbookInitial) && displayedEbooks.isEmpty)
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
                      onReset: () {
                        context.read<EbookBloc>().add(const FetchEbooks());
                      },
                    ),
                  )
                else if (_viewMode == LibraryViewMode.bookshelf)
                  SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: BookshelfViewWidget(
                        key: const ValueKey('bookshelf_view'),
                        ebooks: displayedEbooks,
                        searchQuery: searchQuery,
                        onEbookTap: _openEbookDetail,
                        onDelete: (ebook) => _showDeleteConfirmation(context, ebook),
                      ),
                    ),
                  )
                else if (_viewMode == LibraryViewMode.grid)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 900
                            ? 5
                            : MediaQuery.of(context).size.width > 600
                                ? 3
                                : 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final ebook = displayedEbooks[index];
                          return EbookGridCard(
                            ebook: ebook,
                            searchQuery: searchQuery,
                            onTap: () => _openEbookDetail(ebook),
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
                              searchQuery: searchQuery,
                              onTap: () => _openEbookDetail(ebook),
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
    ),
    );
  }

  Widget _buildViewIconButton({
    required IconData icon,
    required LibraryViewMode mode,
    required String tooltip,
  }) {
    final isSelected = _viewMode == mode;
    return InkWell(
      onTap: () {
        setState(() => _viewMode = mode);
        try {
          sl<SharedPreferences>().setString('library_view_mode', mode.name);
        } catch (_) {}
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.titleAsc:
        return 'Sorted: Title A-Z';
      case SortOption.authorAsc:
        return 'Sorted: Author A-Z';
      case SortOption.recentlyUploaded:
        return 'Sorted: Recent';
    }
  }
}
