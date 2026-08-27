import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/image_utils.dart';
import '../../domain/entities/ebook_entity.dart';
import 'glass_container.dart';

class FeaturedCarouselWidget extends StatelessWidget {
  final EbookEntity ebook;
  final VoidCallback onTap;

  const FeaturedCarouselWidget({
    super.key,
    required this.ebook,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 180,
      child: GlassContainer(
        onTap: onTap,
        padding: EdgeInsets.zero,
        borderColor: AppColors.primary.withValues(alpha: 0.3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        child: Stack(
          children: [
            // Background Image Blur Overlay
            Positioned.fill(
              child: buildEbookCoverImage(coverUrl: ebook.coverUrl, fit: BoxFit.cover, title: ebook.title),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.getBackground(context).withValues(alpha: 0.95),
                      AppColors.getBackground(context).withValues(alpha: 0.65),
                      AppColors.getBackground(context).withValues(alpha: 0.95),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),

            // Content Layout
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Book Cover Preview Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 95,
                      height: 140,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: buildEbookCoverImage(coverUrl: ebook.coverUrl, fit: BoxFit.cover, width: 95, height: 140, title: ebook.title),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Book Info & Call To Action
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt_rounded, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'FEATURED PICK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ebook.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.getTextPrimary(context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by ${ebook.author}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.getTextSecondary(context),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.accent, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${ebook.rating} Rating',
                              style: TextStyle(
                                color: AppColors.getTextPrimary(context),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Read Now →',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontSize: 12,
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
          ],
        ),
      ),
    );
  }
}
