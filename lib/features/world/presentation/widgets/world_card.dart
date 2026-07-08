import 'package:flutter/material.dart';
import '../../domain/entities/world.dart';

/// 世界卡片组件
class WorldCard extends StatelessWidget {
  final World world;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onFavoriteToggle;
  final bool isSelected;
  
  const WorldCard({
    super.key,
    required this.world,
    this.onTap,
    this.onLongPress,
    this.onFavoriteToggle,
    this.isSelected = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: isSelected ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图区域
            _buildCoverImage(context),
            
            // 信息区域
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名称和收藏
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          world.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onFavoriteToggle != null)
                        GestureDetector(
                          onTap: onFavoriteToggle,
                          child: Icon(
                            world.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 20,
                            color: world.isFavorite
                                ? Colors.red
                                : theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // 简介
                  Text(
                    world.summary,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // 统计信息
                  Row(
                    children: [
                      _buildStat(
                        context,
                        icon: Icons.location_on_outlined,
                        count: world.scenes.length,
                        label: '场景',
                      ),
                      const SizedBox(width: 12),
                      _buildStat(
                        context,
                        icon: Icons.people_outline,
                        count: world.npcs.length,
                        label: 'NPC',
                      ),
                      const SizedBox(width: 12),
                      _buildStat(
                        context,
                        icon: Icons.auto_stories,
                        count: world.storylines.length,
                        label: '剧情',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // 标签
                  if (world.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: world.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCoverImage(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: world.hasCoverImage
          ? ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                world.coverImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultCover(context);
                },
              ),
            )
          : _buildDefaultCover(context),
    );
  }
  
  Widget _buildDefaultCover(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.tertiary.withOpacity(0.8),
              theme.colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(
            Icons.public,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
  
  Widget _buildStat(
    BuildContext context, {
    required IconData icon,
    required int count,
    required String label,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(width: 4),
        Text(
          '$count $label',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
