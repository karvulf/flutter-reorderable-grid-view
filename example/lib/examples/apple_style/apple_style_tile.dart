import 'package:flutter/material.dart';

/// Widget of the Apple style example.
class AppleStyleTile {
  static const _items = [
    ('Weather', Icons.wb_sunny_outlined),
    ('Music', Icons.music_note_outlined),
    ('Fitness', Icons.favorite_border_rounded),
    ('Notes', Icons.edit_note_rounded),
    ('Photos', Icons.photo_outlined),
    ('Maps', Icons.navigation_outlined),
    ('Wallet', Icons.account_balance_wallet_outlined),
    ('Mail', Icons.mail_outline_rounded),
  ];

  final int id;
  final String title;
  final IconData icon;

  const AppleStyleTile({
    required this.id,
    required this.title,
    required this.icon,
  });

  /// Creates the tile of [id], repeating the known titles and icons.
  factory AppleStyleTile.fromId(int id) {
    final (title, icon) = _items[id % _items.length];
    return AppleStyleTile(id: id, title: title, icon: icon);
  }
}
