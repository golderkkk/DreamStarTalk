import 'package:flutter/material.dart';
import '../../../../core/theme/aurora_theme.dart';
import '../../domain/entities/character.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback? onTap;
  final bool isSelected;
  const CharacterCard({super.key, required this.character, this.onTap, this.isSelected = false});

  @override Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AuroraColors.primary.withOpacity(0.1) : AuroraColors.bg2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AuroraColors.primary.withOpacity(0.4) : Colors.white.withOpacity(0.04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: Container(
              decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), gradient: LinearGradient(colors: [AuroraColors.primary.withOpacity(0.7), AuroraColors.primaryGlow.withOpacity(0.5)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: character.hasAvatar
                ? ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Image.network(character.avatar!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 40, color: Colors.white54)))
                : const Center(child: Icon(Icons.person, size: 40, color: Colors.white54)),
            )),
            Expanded(flex: 2, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(character.displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AuroraColors.text1), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Expanded(child: Text(character.summary, style: const TextStyle(fontSize: 11, color: AuroraColors.text3), maxLines: 2, overflow: TextOverflow.ellipsis)),
            ]))),
          ],
        ),
      ),
    );
  }
}
