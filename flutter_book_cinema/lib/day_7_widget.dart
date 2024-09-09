import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter_book_cinema/swipeable_cards_container.dart';

class Day7Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/blade_runner_poster_standing.png',
            fit: BoxFit.cover,
          ),
          // Blurred overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.black.withOpacity(0.01),
            ),
          ),
          SwipeableCardsContainer()
        ],
      ),
    );
  }
}
