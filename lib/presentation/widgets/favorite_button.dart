import 'package:flutter/material.dart';

class FavoriteButton extends StatefulWidget {
  final bool initialFavorite;
  final ValueChanged<bool>? onFavoriteChanged;
  
  const FavoriteButton({
    Key? key,
    this.initialFavorite = false,
    this.onFavoriteChanged,
  }) : super(key: key);
  
  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool isFavorite;
  
  @override
  void initState() {
    super.initState();
    isFavorite = widget.initialFavorite;
  }
  
  @override
  void didUpdateWidget(covariant FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFavorite != widget.initialFavorite) {
      setState(() {
        isFavorite = widget.initialFavorite;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: isFavorite 
          ? const Icon(Icons.star, color: Colors.yellow) 
          : const Icon(Icons.star_border, color: Colors.grey),
      onPressed: () {
        setState(() {
          isFavorite = !isFavorite;
        });
        if (widget.onFavoriteChanged != null) {
          widget.onFavoriteChanged!(isFavorite);
        }
      },
    );
  }
}

