import 'package:flutter/material.dart';
import 'package:flutter_book_cinema/movie_cards/barcode_view.dart';
import 'package:flutter_book_cinema/movie_cards/ridged_card.dart';
import 'package:flutter_book_cinema/movie_cards/shader_card.dart';
import 'package:flutter_book_cinema/movie_cards/swipe_card.dart';

const ticket_blue = Color.fromRGBO(142, 155, 213, 1);

class MovieCards extends StatelessWidget {
  final String date;
  final String time;
  final String seats;
  final String movieTitle;
  final String total;
  final String imageUrl;

  const MovieCards({
    Key? key,
    required this.date,
    required this.time,
    required this.seats,
    required this.movieTitle,
    required this.total,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              MovieTicketCard(
                date: date,
                time: time,
                seats: seats,
                movieTitle: movieTitle,
                total: total,
                imageUrl: imageUrl,
              ),
              Transform.translate(
                  offset: const Offset(
                      0, -16), // Adjust this value for desired overlap
                  child: Stack(children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(top: 40.0, bottom: 16.0),
                      child: Column(
                        children: [
                          BarcodeView(),
                        ],
                      ),
                    ),
                    ProjectCard(
                      onDelete: () {
                        print("onSwipeToTear");
                      },
                      child: const ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(10)),
                        child: SizedBox(
                          height: 144,
                          child: SwipeToConfirmCard(),
                        ),
                      ),
                    )
                  ]))
            ],
          ),
        ),
      ),
    );
  }
}

class MovieTicketCard extends StatelessWidget {
  final String date;
  final String time;
  final String seats;
  final String movieTitle;
  final String total;
  final String imageUrl;

  const MovieTicketCard({
    Key? key,
    required this.date,
    required this.time,
    required this.seats,
    required this.movieTitle,
    required this.total,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4, // Maintain a 3:4 aspect ratio
      child: RoundedRidgedCard(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        topRidge: false,
        bottomRidge: true,
        ridgeDepth: 1,
        ridgeWidth: 20,
        ridgeCount: 6,
        borderRadius: 16,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Faded movie poster image
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                      color: Colors.white.withOpacity(0.3),
                      colorBlendMode: BlendMode.modulate,
                    ),
                  ),
                ),

                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoText('DATE: $date'),
                      _buildInfoText('TIME: $time'),
                      _buildInfoText('SEATS: $seats'),
                      const SizedBox(height: 8),
                      Text(
                        movieTitle,
                        style: const TextStyle(
                          decoration: TextDecoration.none,
                          fontFamily: 'Roboto',
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: ticket_blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TOTAL: $total',
                        style: const TextStyle(
                          decoration: TextDecoration.none,
                          fontFamily: 'Roboto',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          decoration: TextDecoration.none,
          fontSize: 12,
          color: Colors.black87,
        ),
      ),
    );
  }
}
