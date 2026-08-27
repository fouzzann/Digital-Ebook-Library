import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/image_utils.dart';
import '../../domain/entities/ebook_entity.dart';
import 'glass_container.dart';

class RecentlyReadWidget extends StatelessWidget {
  final List<EbookEntity> recentlyReadEbooks;
  final ValueChanged<EbookEntity> onEbookTap;

  const RecentlyReadWidget({
    super.key,
    required this.recentlyReadEbooks,
    required this.onEbookTap,
  });

  @override
  Widget build(BuildContext context) {
    if (recentlyReadEbooks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: Row(
            children: [
              const Icon(Icons.history_rounded, color: AppColors.accent, size: 18),
              const SizedBox(width: 6),
              Text(
                'Recently Read',
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recentlyReadEbooks.length,
            itemBuilder: (context, index) {
              final ebook = recentlyReadEbooks[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GlassContainer(
                  onTap: () => onEbookTap(ebook),
                  padding: const EdgeInsets.all(8),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 70,
                          height: 120,
                          child: buildEbookCoverImage(
                            coverUrl: ebook.coverUrl,
                            fit: BoxFit.cover,
                            title: ebook.title,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 130,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'CONTINUE',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ebook.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.getTextPrimary(context),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ebook.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.getTextSecondary(context),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              children: [
                                Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Resume',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
