import 'package:flutter/material.dart';

class AvatarPicker extends StatelessWidget {
  final int selectedAvatar;
  final ValueChanged<int> onSelected;

  const AvatarPicker({
    super.key,
    required this.selectedAvatar,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const icons = [Icons.person, Icons.face, Icons.school];

    const colors = [Color(0xFFB98688), Color(0xFF8D9D8A), Color(0xFFA49AB8)];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        final dipilih = selectedAvatar == index;

        return GestureDetector(
          onTap: () => onSelected(index),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: dipilih
                        ? const Color(0xFF694A47)
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: colors[index],
                  child: Icon(icons[index], color: Colors.white, size: 33),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Avatar ${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: dipilih ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
