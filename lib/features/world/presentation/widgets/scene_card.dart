import 'package:flutter/material.dart';
import '../../domain/entities/world.dart';

/// 场景卡片组件
class SceneCard extends StatelessWidget {
  final Scene scene;
  final bool isCurrentScene;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSetCurrent;
  final VoidCallback? onDelete;
  
  const SceneCard({
    super.key,
    required this.scene,
    this.isCurrentScene = false,
    this.onTap,
    this.onLongPress,
    this.onSetCurrent,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: isCurrentScene ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrentScene
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.2),
          width: isCurrentScene ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 场景图片
            _buildSceneImage(context),
            
            // 场景信息
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名称
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          scene.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentScene)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '当前',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // 描述
                  if (scene.description != null && scene.description!.isNotEmpty)
                    Text(
                      scene.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  
                  // 环境信息
                  Wrap(
                    spacing: 8,
                    children: [
                      if (scene.time != null && scene.time!.isNotEmpty)
                        _buildEnvironmentInfo(
                          context,
                          icon: Icons.access_time,
                          text: scene.time!,
                        ),
                      if (scene.weather != null && scene.weather!.isNotEmpty)
                        _buildEnvironmentInfo(
                          context,
                          icon: Icons.cloud,
                          text: scene.weather!,
                        ),
                      if (scene.atmosphere != null && scene.atmosphere!.isNotEmpty)
                        _buildEnvironmentInfo(
                          context,
                          icon: Icons.mood,
                          text: scene.atmosphere!,
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
  }

  Widget _buildSceneImage(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: scene.hasImage
          ? ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                scene.image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultImage(context);
                },
              ),
            )
          : _buildDefaultImage(context),
    );
  }

  Widget _buildDefaultImage(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Icon(
        Icons.location_on_outlined,
        size: 40,
        color: theme.colorScheme.onSurface.withOpacity(0.3),
      ),
    );
  }

  Widget _buildEnvironmentInfo(
    BuildContext context, {
    required IconData icon,
    required String text,
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
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
