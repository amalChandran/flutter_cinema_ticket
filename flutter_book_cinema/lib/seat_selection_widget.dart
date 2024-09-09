import 'package:flutter/material.dart';
import 'package:flutter_book_cinema/swipeable_cards_container.dart';

class SeatSelectionWidget extends StatefulWidget {
  final CinemaWidgetState state;
  final Function(CinemaWidgetState) onStateChange;

  const SeatSelectionWidget(
      {Key? key, required this.state, required this.onStateChange})
      : super(key: key);

  @override
  _SeatSelectionWidgetState createState() => _SeatSelectionWidgetState();
}

class _SeatSelectionWidgetState extends State<SeatSelectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _scaleEnterAnimation;

  late AnimationController _exitAnimationController;
  late Animation<double> _exitAnimation;
  late Animation<double> _exitScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _scaleEnterAnimation = Tween<double>(begin: 1.2, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _exitAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _exitAnimation =
        Tween<double>(begin: 1, end: 0).animate(_exitAnimationController);
    // Define a Tween that maps the animation value from [1, 0] to [1, 0.75]
    _exitScaleAnimation =
        Tween<double>(begin: 1.0, end: 0.75).animate(_exitAnimationController);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void didUpdateWidget(SeatSelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _triggerStateChanges();
    }
  }

  void _triggerStateChanges() {
    if (widget.state == CinemaWidgetState.seating) {
      _controller.forward();
    } else if (widget.state == CinemaWidgetState.ticketing) {
      // _controller.reverse();
      _exitAnimationController.forward();
      print(
          "Implementation pending SeatSelectionWidget _triggerStateChanges: ${widget.state}");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double widthPercentage = 0.7;
    double heightPercentage = 0.4;
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _exitAnimationController]),
      builder: (context, child) {
        return Opacity(
          opacity: _exitAnimation.value,
          child: Transform.scale(
            scale: _exitScaleAnimation.value,
            child: Stack(
              children: [
                // Hidden widget (visible when card is removed)
                if (_animation.value != 0)
                  Opacity(
                    opacity: _animation.value,
                    child: Transform.scale(
                      scale: _scaleEnterAnimation.value,
                      child: MovieSeatBooking(
                        onPressed: () {
                          print("onPressed: ${widget.state}");
                          widget
                              .onStateChange(getNextCinemaState(widget.state));
                        },
                      ),
                    ),
                  ),

                // Card widget on top
                if (_animation.value != 1)
                  Opacity(
                    opacity: 1 - _animation.value,
                    child: Center(
                      child: Card(
                        elevation: 4,
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              height: screenHeight * heightPercentage,
                              width: screenWidth * widthPercentage,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Time Picker',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () {
                                      // setState(() {
                                      widget.onStateChange(
                                          getNextCinemaState(widget.state));
                                      // });
                                    },
                                    child: Text('Choose Seat'),
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MovieSeatBooking extends StatefulWidget {
  final VoidCallback onPressed;
  const MovieSeatBooking({Key? key, required this.onPressed}) : super(key: key);

  @override
  _MovieSeatBookingState createState() => _MovieSeatBookingState();
}

class _MovieSeatBookingState extends State<MovieSeatBooking>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;
  late final Animation<double> _introAnimation;
  final int rows = 7;
  final int cols = 6;
  List<List<int>> seatStatus = [];

  @override
  void initState() {
    super.initState();
    // Initialize seat status: 0 = available, 1 = selected, 2 = booked
    seatStatus = List.generate(rows, (_) => List.filled(cols, 0));
    // Set some seats as booked for demonstration
    seatStatus[2][2] = 1;
    seatStatus[2][3] = 2;
    seatStatus[5][5] = 2;
    seatStatus[5][4] = 2;

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _introAnimation = Tween<double>(begin: 0, end: 1).animate(_introController);

    _introController.forward();
  }

  void toggleSeatSelection(int row, int col) {
    setState(() {
      if (seatStatus[row][col] == 0) {
        seatStatus[row][col] = 1;
      } else if (seatStatus[row][col] == 1) {
        seatStatus[row][col] = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _introController,
      builder: (context, child) {
        return Column(
          children: [
            Spacer(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 1; i <= cols; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: getNumText(i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (int i = 0; i < rows; i++)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        getAlphabetText(i),
                        const SizedBox(
                          width: 20,
                        ),
                        for (int j = 0; j < cols; j++)
                          Padding(
                            padding:
                                EdgeInsets.all(3.0 * _introAnimation.value),
                            child: GestureDetector(
                              onTap: () {
                                if (seatStatus[i][j] != 2) {
                                  toggleSeatSelection(i, j);
                                }
                              },
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: const Offset(
                                          0, 1), // Slightly below the widget
                                    ),
                                  ],
                                  color: seatStatus[i][j] == 0
                                      ? Colors.white
                                      : seatStatus[i][j] == 1
                                          ? Colors.blue
                                          : Color.fromARGB(255, 234, 232, 232),
                                  borderRadius: BorderRadius.circular(
                                      12 * _introAnimation.value),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(
                          width: 20,
                        ),
                        getAlphabetText(i)
                      ],
                    ),
                ],
              ),
            ),
            //A button that takes full width
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                  left: 16,
                  right: 16),
              child: SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  child: const Text('CHECK OUT'),
                  onPressed: () {
                    widget.onPressed();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Text getNumText(int i) {
    return Text(
      '$i',
      style: const TextStyle(
          decoration: TextDecoration.none,
          fontSize: 12,
          color: Color.fromARGB(255, 180, 179, 179),
          fontWeight: FontWeight.bold),
    );
  }

  Text getAlphabetText(int i) {
    return Text(
      '${String.fromCharCode(65 + i)} ',
      style: const TextStyle(
          decoration: TextDecoration.none,
          fontSize: 12,
          color: Color.fromARGB(255, 180, 179, 179),
          fontWeight: FontWeight.bold),
    );
  }
}
