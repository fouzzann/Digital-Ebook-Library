import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/image_utils.dart';
import '../../domain/entities/ebook_entity.dart';
import 'glass_container.dart';
import 'highlighted_text_widget.dart';

class BookshelfViewWidget extends StatelessWidget {
  final List<EbookEntity> ebooks;
  final String searchQuery;
  final ValueChanged<EbookEntity> onEbookTap;
  final ValueChanged<EbookEntity> onDelete;

  const BookshelfViewWidget({
    super.key,
    required this.ebooks,
    required this.searchQuery,
    required this.onEbookTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (ebooks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C1B18).withValues(alpha: 0.6) : const Color(0xFFFEF3C7),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black45 : const Color(0x33D4AF37),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.shelves, color: Color(0xFFD4AF37), size: 54),
            ),
            const SizedBox(height: 18),
            Text(
              'Empty Bookshelf',
              style: TextStyle(
                color: AppColors.getTextPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No e-books resting on this shelf level.',
              style: TextStyle(color: AppColors.getTextMuted(context), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        int crossAxisCount = 3;
        if (width > 900) {
          crossAxisCount = 6;
        } else if (width > 600) {
          crossAxisCount = 4;
        }

        // Group books into shelf rows
        final List<List<EbookEntity>> rows = [];
        for (int i = 0; i < ebooks.length; i += crossAxisCount) {
          final end = (i + crossAxisCount < ebooks.length) ? i + crossAxisCount : ebooks.length;
          rows.add(ebooks.sublist(i, end));
        }

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: rows.length,
          itemBuilder: (context, rowIndex) {
            final rowBooks = rows[rowIndex];
            return _buildShelfRow(context, rowBooks, crossAxisCount);
          },
        );
      },
    );
  }

  Widget _buildShelfRow(BuildContext context, List<EbookEntity> rowBooks, int crossAxisCount) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Books on shelf
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          height: 165,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(crossAxisCount, (colIndex) {
              if (colIndex < rowBooks.length) {
                final ebook = rowBooks[colIndex];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _buildBookshelfItem(context, ebook),
                  ),
                );
              } else {
                return const Expanded(child: SizedBox.shrink());
              }
            }),
          ),
        ),

        // 3D Wood Shelf Bar
        Container(
          height: 18,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF5D4037),
                Color(0xFF3E2723),
                Color(0xFF4E342E),
                Color(0xFF2C1D11),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
              BoxShadow(
                color: Color(0xFFD4AF37),
                blurRadius: 1,
                offset: Offset(0, -1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookshelfItem(BuildContext context, EbookEntity ebook) {
    return Tooltip(
      message: '${ebook.title} by ${ebook.author}',
      child: GestureDetector(
        onTap: () => onEbookTap(ebook),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // Book 3D Cover Spine & Shadow
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                        topLeft: Radius.circular(3),
                        bottomLeft: Radius.circular(3),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black87,
                          blurRadius: 12,
                          offset: Offset(4, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                        topLeft: Radius.circular(3),
                        bottomLeft: Radius.circular(3),
                      ),
                      child: AspectRatio(
                        aspectRatio: 0.68,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Hero(
                              tag: 'shelf_cover_${ebook.id}',
                              child: buildEbookCoverImage(
                                coverUrl: ebook.coverUrl,
                                fit: BoxFit.cover,
                                title: ebook.title,
                              ),
                            ),
                            // Book Spine Effect Overlay
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              width: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.5),
                                      Colors.white.withValues(alpha: 0.2),
                                      Colors.black.withValues(alpha: 0.3),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Delete Pill Icon
                  Positioned(
                    top: -4,
                    right: -4,
                    child: GestureDetector(
                      onTap: () => onDelete(ebook),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black45, blurRadius: 6),
                          ],
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Book Title Text Under Shelf Item
            HighlightedText(
              text: ebook.title,
              query: searchQuery,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.getTextPrimary(context),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
