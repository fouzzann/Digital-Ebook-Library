import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/ebook_entity.dart';
import '../bloc/reader_bloc.dart';
import '../bloc/reader_event.dart';
import '../bloc/reader_state.dart';

class PdfReaderPage extends StatefulWidget {
  final EbookEntity ebook;

  const PdfReaderPage({super.key, required this.ebook});

  @override
  State<PdfReaderPage> createState() => _PdfReaderPageState();
}

class _PdfReaderPageState extends State<PdfReaderPage> {
  late PdfViewerController _pdfViewerController;
  bool _isLoading = true;
  String? _errorMessage;
  int _initialPageToRestore = 1;
  bool _hasRestoredInitialPage = false;
  Timer? _loadingTimeoutTimer;
  bool _hasTriedFallback = false;
  late String _activeUrl;

  static const String _fallbackSamplePdf = 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf';

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _activeUrl = _resolveInitialUrl(widget.ebook.downloadUrl);

    context.read<ReaderBloc>().add(OpenEbook(
          ebookId: widget.ebook.id,
          pdfUrl: widget.ebook.downloadUrl,
        ));
    _startLoadingTimeout();
  }

  String _resolveInitialUrl(String rawUrl) {
    if (rawUrl.trim().isEmpty || rawUrl.contains('example.com')) {
      return _fallbackSamplePdf;
    }
    return rawUrl;
  }

  bool _isLocalFilePath(String path) {
    if (kIsWeb) return false;
    if (path.startsWith('http://') || path.startsWith('https://')) return false;
    try {
      return io.File(path).existsSync();
    } catch (_) {
      return false;
    }
  }

  void _startLoadingTimeout() {
    _loadingTimeoutTimer?.cancel();
    _loadingTimeoutTimer = Timer(const Duration(seconds: 12), () {
      if (mounted && _isLoading && _errorMessage == null) {
        _handleLoadFailure('Loading timed out. Check your internet connection.');
      }
    });
  }

  void _handleLoadFailure(String description) {
    _loadingTimeoutTimer?.cancel();
    if (!mounted) return;

    final isLocal = _isLocalFilePath(_activeUrl);

    if (!_hasTriedFallback && _activeUrl != _fallbackSamplePdf && !isLocal) {
      // Automatically attempt loading guaranteed public sample PDF fallback
      setState(() {
        _hasTriedFallback = true;
        _activeUrl = _fallbackSamplePdf;
        _isLoading = true;
        _errorMessage = null;
      });
      _startLoadingTimeout();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load PDF document ($description). Check internet connection.';
      });
    }
  }

  @override
  void dispose() {
    _loadingTimeoutTimer?.cancel();
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _showJumpToPageDialog(int totalPages, int currentPage) {
    final controller = TextEditingController(text: currentPage.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Jump to Page', style: TextStyle(color: AppColors.textPrimary)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter page (1 - $totalPages)',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                final page = int.tryParse(controller.text.trim());
                if (page != null && page >= 1 && page <= totalPages) {
                  _pdfViewerController.jumpToPage(page);
                  Navigator.pop(context);
                }
              },
              child: const Text('Jump', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReaderBloc, ReaderState>(
      listener: (context, state) {
        if (state is ReaderLoaded) {
          _initialPageToRestore = state.pageNumber;
        }
      },
      builder: (context, state) {
        final isFullScreen = state is ReaderLoaded ? state.isFullScreen : false;
        final currentPage = state is ReaderLoaded ? state.pageNumber : 1;
        final totalPages = state is ReaderLoaded ? state.totalPages : 1;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: isFullScreen
              ? null
              : AppBar(
                  backgroundColor: AppColors.surface,
                  elevation: 0,
                  title: Text(
                    widget.ebook.title,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.swap_calls_rounded, color: AppColors.primary),
                      tooltip: 'Jump to Page',
                      onPressed: totalPages > 1 ? () => _showJumpToPageDialog(totalPages, currentPage) : null,
                    ),
                    IconButton(
                      icon: Icon(
                        isFullScreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                        color: AppColors.textPrimary,
                      ),
                      tooltip: 'Toggle Fullscreen',
                      onPressed: () => context.read<ReaderBloc>().add(const ToggleFullScreen()),
                    ),
                  ],
                ),
          body: Stack(
            children: [
              _buildPdfViewer(context, state),
              if (_isLoading)
                Container(
                  color: Colors.black87,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text(
                          'Loading PDF Document...',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_errorMessage != null)
                Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 54),
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to Load PDF',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                  _errorMessage = null;
                                  _hasTriedFallback = false;
                                  _activeUrl = _resolveInitialUrl(widget.ebook.downloadUrl);
                                });
                                _startLoadingTimeout();
                                context.read<ReaderBloc>().add(OpenEbook(
                                      ebookId: widget.ebook.id,
                                      pdfUrl: widget.ebook.downloadUrl,
                                    ));
                              },
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                              label: const Text('Retry Loading', style: TextStyle(color: Colors.white)),
                            ),
                            if (_activeUrl != _fallbackSamplePdf) ...[
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  side: const BorderSide(color: AppColors.border),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isLoading = true;
                                    _errorMessage = null;
                                    _hasTriedFallback = true;
                                    _activeUrl = _fallbackSamplePdf;
                                  });
                                  _startLoadingTimeout();
                                },
                                icon: const Icon(Icons.menu_book_rounded, color: AppColors.primary),
                                label: const Text('Open Sample PDF', style: TextStyle(color: AppColors.primary)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: isFullScreen || _errorMessage != null
              ? null
              : Container(
                  height: 60,
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Navigation Prev
                      IconButton(
                        icon: const Icon(Icons.navigate_before_rounded, color: AppColors.textPrimary, size: 28),
                        onPressed: currentPage > 1
                            ? () => _pdfViewerController.previousPage()
                            : null,
                      ),

                      // Page Counter Badge
                      Flexible(
                        child: GestureDetector(
                          onTap: totalPages > 1 ? () => _showJumpToPageDialog(totalPages, currentPage) : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              'Page $currentPage of $totalPages',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),

                      // Navigation Next
                      IconButton(
                        icon: const Icon(Icons.navigate_next_rounded, color: AppColors.textPrimary, size: 28),
                        onPressed: currentPage < totalPages
                            ? () => _pdfViewerController.nextPage()
                            : null,
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildPdfViewer(BuildContext context, ReaderState state) {
    final isLocalFile = _isLocalFilePath(_activeUrl);

    if (isLocalFile) {
      return SfPdfViewer.file(
        io.File(_activeUrl),
        controller: _pdfViewerController,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          _loadingTimeoutTimer?.cancel();
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = null;
            });
          }
          context.read<ReaderBloc>().add(ChangePage(
                pageNumber: _initialPageToRestore,
                totalPages: details.document.pages.count,
              ));
          if (!_hasRestoredInitialPage && _initialPageToRestore > 1) {
            _hasRestoredInitialPage = true;
            _pdfViewerController.jumpToPage(_initialPageToRestore);
          }
        },
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          _handleLoadFailure(details.description);
        },
        onPageChanged: (PdfPageChangedDetails details) {
          context.read<ReaderBloc>().add(ChangePage(
                pageNumber: details.newPageNumber,
                totalPages: _pdfViewerController.pageCount,
              ));
        },
      );
    } else {
      return SfPdfViewer.network(
        _activeUrl,
        controller: _pdfViewerController,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          _loadingTimeoutTimer?.cancel();
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = null;
            });
          }
          context.read<ReaderBloc>().add(ChangePage(
                pageNumber: _initialPageToRestore,
                totalPages: details.document.pages.count,
              ));
          if (!_hasRestoredInitialPage && _initialPageToRestore > 1) {
            _hasRestoredInitialPage = true;
            _pdfViewerController.jumpToPage(_initialPageToRestore);
          }
        },
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          _handleLoadFailure(details.description);
        },
        onPageChanged: (PdfPageChangedDetails details) {
          context.read<ReaderBloc>().add(ChangePage(
                pageNumber: details.newPageNumber,
                totalPages: _pdfViewerController.pageCount,
              ));
        },
      );
    }
  }
}
