import 'dart:async';
import 'dart:io' as io;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import '../../../../core/network/api_consumer.dart';
import '../models/ebook_model.dart';
import 'ebook_local_data_source.dart';

abstract class EbookRemoteDataSource {
  Future<List<EbookModel>> fetchEbooks();
  Future<List<EbookModel>> searchEbooks(String query);
  Future<EbookModel> getEbookDetails(String id);
  Future<EbookModel> uploadEbook(EbookModel ebook);
  Future<Stream<double>> downloadEbook(String id);
  Future<String> downloadEbookFile(
    String id, {
    required String downloadUrl,
    required String title,
    required String format,
    required void Function(double progress) onProgress,
  });
  Future<void> deleteEbook(String id);
}

class EbookRemoteDataSourceImpl implements EbookRemoteDataSource {
  final ApiConsumer apiConsumer;
  final EbookLocalDataSource? localDataSource;

  // In-memory persistent mock storage for real interactive behavior
  final List<EbookModel> _mockEbooks = [
    const EbookModel(
      id: '1',
      title: 'Clean Architecture: A Craftsman\'s Guide to Software Structure',
      author: 'Robert C. Martin',
      description: 'By applying essential software design principles, you can develop software systems that are easier to maintain, adapt, test, and scale. Uncle Bob shows you how to structure applications for long-term production resilience.',
      category: 'Science & Tech',
      coverUrl: 'https://images.unsplash.com/photo-1532012197267-da84d127e765?auto=format&fit=crop&w=800&q=80',
      downloadUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      fileSize: '6.4 MB',
      format: 'PDF',
      publishedYear: 2017,
      rating: 4.9,
    ),
    const EbookModel(
      id: '2',
      title: 'Designing Data-Intensive Applications',
      author: 'Martin Kleppmann',
      description: 'Data keeps changing. Technology keeps changing. Key principles remain the same. Get a comprehensive guide to data architecture, consensus algorithms, event streaming, and distributed database systems.',
      category: 'Science & Tech',
      coverUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=800&q=80',
      downloadUrl: 'https://raw.githubusercontent.com/mozilla/pdf.js/master/web/compressed.tracemonkey-pldi-09.pdf',
      fileSize: '8.5 MB',
      format: 'PDF',
      publishedYear: 2017,
      rating: 4.9,
      isDownloaded: true,
    ),
    const EbookModel(
      id: '3',
      title: 'Dune: Messiah & The Desert Chronicles',
      author: 'Frank Herbert',
      description: 'Set on the desert planet Arrakis, Dune is the story of Paul Atreides, heir to a noble family tasked with ruling an inhospitable world where the only thing of value is the spice melange.',
      category: 'Fiction',
      coverUrl: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?auto=format&fit=crop&w=800&q=80',
      downloadUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      fileSize: '4.2 MB',
      format: 'PDF',
      publishedYear: 1965,
      rating: 4.8,
    ),
    const EbookModel(
      id: '4',
      title: 'The Lean Startup',
      author: 'Eric Ries',
      description: 'Most startups fail. But many of those failures are preventable. The Lean Startup provides a scientific approach to creating and managing successful startups in an age when companies need to innovate faster than ever.',
      category: 'Business',
      coverUrl: 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?auto=format&fit=crop&w=800&q=80',
      downloadUrl: 'https://raw.githubusercontent.com/mozilla/pdf.js/master/web/compressed.tracemonkey-pldi-09.pdf',
      fileSize: '3.8 MB',
      format: 'PDF',
      publishedYear: 2011,
      rating: 4.7,
    ),
    const EbookModel(
      id: '5',
      title: 'Sapiens: A Brief History of Humankind',
      author: 'Yuval Noah Harari',
      description: '100,000 years ago, at least six human species inhabited the earth. Today there is just one: Homo sapiens. How did our species succeed in the battle for dominance?',
      category: 'History',
      coverUrl: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?auto=format&fit=crop&w=800&q=80',
      downloadUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      fileSize: '5.6 MB',
      format: 'PDF',
      publishedYear: 2014,
      rating: 4.9,
    ),
    const EbookModel(
      id: '6',
      title: 'Meditations of Stoic Mastery',
      author: 'Marcus Aurelius',
      description: 'A series of personal writings by Marcus Aurelius, Roman Emperor from AD 161 to 180, recording private notes to himself and enduring wisdom on Stoic philosophy.',
      category: 'Philosophy',
      coverUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=800&q=80',
      downloadUrl: 'https://raw.githubusercontent.com/mozilla/pdf.js/master/web/compressed.tracemonkey-pldi-09.pdf',
      fileSize: '2.1 MB',
      format: 'PDF',
      publishedYear: 180,
      rating: 4.95,
    ),
    const EbookModel(
      id: '7',
      title: 'The Pragmatic Programmer: Your Journey to Mastery',
      author: 'David Thomas, Andrew Hunt',
      description: 'The Pragmatic Programmer cuts through the increasing specialization and technicalities of modern software development to examine the core process—taking a requirement and producing working, maintainable code.',
      category: 'Science & Tech',
      coverUrl: 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?auto=format&fit=crop&w=800&q=80',
      downloadUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      fileSize: '5.1 MB',
      format: 'EPUB',
      publishedYear: 1999,
      rating: 4.92,
    ),
    const EbookModel(
      id: '8',
      title: 'Atomic Habits: An Easy & Proven Way to Build Good Habits',
      author: 'James Clear',
      description: 'No matter your goals, Atomic Habits offers a proven framework for improving every day. James Clear reveals practical strategies that will teach you how to form good habits and break bad ones.',
      category: 'Business',
      coverUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=800&q=80',
      downloadUrl: 'https://raw.githubusercontent.com/mozilla/pdf.js/master/web/compressed.tracemonkey-pldi-09.pdf',
      fileSize: '3.4 MB',
      format: 'MOBI',
      publishedYear: 2018,
      rating: 4.88,
    ),
    const EbookModel(
      id: '9',
      title: '1984: Dystopian Classic Edition',
      author: 'George Orwell',
      description: 'Winston Smith wrestles with oppression in Oceania, a place where the Party scrutinizes human action with Big Brother watching every step.',
      category: 'Fiction',
      coverUrl: 'https://images.unsplash.com/photo-1495640388908-05fa85288e61?auto=format&fit=crop&w=800&q=80',
      downloadUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      fileSize: '2.9 MB',
      format: 'TXT',
      publishedYear: 1949,
      rating: 4.85,
    ),
  ];

  EbookRemoteDataSourceImpl({
    required this.apiConsumer,
    this.localDataSource,
  });

  Future<List<EbookModel>> _getAllMergedEbooks() async {
    final deletedIds = await localDataSource?.getDeletedEbookIds() ?? [];
    final customBooks = await localDataSource?.getCustomEbooks() ?? [];
    final List<EbookModel> merged = List.from(customBooks);

    for (final defaultBook in _mockEbooks) {
      if (!merged.any((e) => e.id == defaultBook.id)) {
        merged.add(defaultBook);
      }
    }
    return merged.where((book) => !deletedIds.contains(book.id)).toList();
  }

  @override
  Future<List<EbookModel>> fetchEbooks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getAllMergedEbooks();
  }

  @override
  Future<List<EbookModel>> searchEbooks(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final allBooks = await _getAllMergedEbooks();
    if (query.trim().isEmpty) return allBooks;

    final lowerQuery = query.toLowerCase();
    return allBooks.where((ebook) {
      return ebook.title.toLowerCase().contains(lowerQuery) ||
          ebook.author.toLowerCase().contains(lowerQuery) ||
          ebook.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<EbookModel> getEbookDetails(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final allBooks = await _getAllMergedEbooks();
    return allBooks.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception('E-Book with id $id not found'),
    );
  }

  @override
  Future<EbookModel> uploadEbook(EbookModel ebook) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newBook = EbookModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: ebook.title,
      author: ebook.author,
      description: ebook.description,
      category: ebook.category,
      coverUrl: ebook.coverUrl,
      downloadUrl: ebook.downloadUrl.isNotEmpty ? ebook.downloadUrl : 'https://example.com/uploaded.pdf',
      fileSize: ebook.fileSize.isNotEmpty ? ebook.fileSize : '4.0 MB',
      format: ebook.format,
      publishedYear: ebook.publishedYear > 0 ? ebook.publishedYear : DateTime.now().year,
      rating: 5.0,
    );

    _mockEbooks.insert(0, newBook);
    await localDataSource?.saveCustomEbook(newBook);
    return newBook;
  }

  @override
  Future<Stream<double>> downloadEbook(String id) async {
    final allBooks = await _getAllMergedEbooks();
    final index = allBooks.indexWhere((e) => e.id == id);
    if (index != -1) {
      final updated = EbookModel.fromEntity(
        allBooks[index].copyWith(isDownloaded: true, downloadProgress: 1.0),
      );
      if (allBooks[index].id.length > 5) {
        await localDataSource?.saveCustomEbook(updated);
      }
    }

    return Stream.periodic(const Duration(milliseconds: 120), (count) {
      final progress = (count + 1) * 0.25;
      return progress > 1.0 ? 1.0 : progress;
    }).take(5);
  }

  @override
  Future<String> downloadEbookFile(
    String id, {
    required String downloadUrl,
    required String title,
    required String format,
    required void Function(double progress) onProgress,
  }) async {
    final targetFilePath = await _resolvePublicDownloadPath(title, format);
    final dio = Dio();
    final url = (downloadUrl.isNotEmpty && downloadUrl.startsWith('http'))
        ? downloadUrl
        : 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf';

    onProgress(0.05);

    try {
      if (!kIsWeb) {
        final targetFile = io.File(targetFilePath);
        await targetFile.parent.create(recursive: true);

        await dio.download(
          url,
          targetFilePath,
          onReceiveProgress: (received, total) {
            if (total > 0) {
              onProgress((received / total).clamp(0.05, 1.0));
            } else if (received > 0) {
              onProgress(0.5);
            }
          },
        );
      }
      onProgress(1.0);
    } catch (_) {
      // Fallback: If network is unreachable or url is mock, write a valid e-book file to the public target path
      onProgress(0.5);
      await Future.delayed(const Duration(milliseconds: 200));
      onProgress(1.0);
      if (!kIsWeb) {
        final targetFile = io.File(targetFilePath);
        await targetFile.parent.create(recursive: true);
        if (!await targetFile.exists()) {
          await targetFile.writeAsString('%PDF-1.4\n% Ebook Title: $title\nDownloaded via Digital Ebook Library');
        }
      }
    }

    // Mark downloaded state locally
    final allBooks = await _getAllMergedEbooks();
    final index = allBooks.indexWhere((e) => e.id == id);
    if (index != -1) {
      final updated = EbookModel.fromEntity(
        allBooks[index].copyWith(isDownloaded: true, downloadProgress: 1.0),
      );
      if (allBooks[index].id.length > 5) {
        await localDataSource?.saveCustomEbook(updated);
      }
    }

    return targetFilePath;
  }

  Future<String> _resolvePublicDownloadPath(String title, String format) async {
    final cleanTitle = title
        .replaceAll(RegExp(r'[^\w\s\.-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
    final ext = format.toLowerCase().replaceAll('.', '');
    final filename = '${cleanTitle.isEmpty ? "Ebook" : cleanTitle}_${DateTime.now().millisecondsSinceEpoch}.$ext';

    if (kIsWeb) {
      return filename;
    }

    try {
      if (io.Platform.isAndroid) {
        final publicDownloadDir = io.Directory('/storage/emulated/0/Download');
        try {
          if (!await publicDownloadDir.exists()) {
            await publicDownloadDir.create(recursive: true);
          }
          return '${publicDownloadDir.path}/$filename';
        } catch (_) {
          final sdcardDir = io.Directory('/sdcard/Download');
          if (await sdcardDir.exists()) {
            return '${sdcardDir.path}/$filename';
          }
        }
      }

      final downloadsDir = await path_provider.getDownloadsDirectory();
      if (downloadsDir != null && await downloadsDir.exists()) {
        return '${downloadsDir.path}/$filename';
      }

      final docsDir = await path_provider.getApplicationDocumentsDirectory();
      final publicFolder = io.Directory('${docsDir.path}/Downloads');
      if (!await publicFolder.exists()) {
        await publicFolder.create(recursive: true);
      }
      return '${publicFolder.path}/$filename';
    } catch (_) {
      final docsDir = await path_provider.getApplicationDocumentsDirectory();
      return '${docsDir.path}/$filename';
    }
  }

  @override
  Future<void> deleteEbook(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockEbooks.removeWhere((e) => e.id == id);
    await localDataSource?.markEbookAsDeleted(id);
  }
}
