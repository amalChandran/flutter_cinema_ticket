import 'package:flutter/material.dart';
import 'package:flutter_book_cinema/helpers/custom_clipper.dart';
import 'package:flutter_book_cinema/movie_cards/movie_card.dart';
import 'package:flutter_book_cinema/seat_selection_widget.dart';
import 'package:flutter_book_cinema/shadow_gradient_rectangle.dart';
import 'package:video_player/video_player.dart';

enum CinemaWidgetState {
  normal,
  seating,
  ticketing,
}

CinemaWidgetState getNextCinemaState(CinemaWidgetState currentState) {
  const values = CinemaWidgetState.values;
  final nextIndex = (values.indexOf(currentState) + 1) % values.length;
  return values[nextIndex];
}

class SwipeableCardsContainer extends StatefulWidget {
  SwipeableCardsContainer({super.key});
  @override
  _SwipeableCardsContainerState createState() =>
      _SwipeableCardsContainerState();
}

class _SwipeableCardsContainerState extends State<SwipeableCardsContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideInTicketFromTopAnimationController;
  late Animation<Offset> _slideInFromTopAnimation;

  CinemaWidgetState _widgetState = CinemaWidgetState.normal;

  void _updateWidgetState(CinemaWidgetState newState) {
    setState(() {
      print("SipeableCardsContainerState: $newState");
      _widgetState = newState;
      _triggerStateChanges();
    });
  }

  void _triggerStateChanges() {
    // if (_widgetState == CinemaWidgetState.seating) {
    //   _toggleExpand();
    // } else
    if (_widgetState == CinemaWidgetState.ticketing) {
      // _controller.reverse();
      _slideInTicketFromTopAnimationController.forward();
    }
  }

  @override
  void initState() {
    super.initState();
    _slideInTicketFromTopAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _slideInFromTopAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // Start from above the screen
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideInTicketFromTopAnimationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
    ));
  }

  @override
  Widget build(BuildContext context) {
    //get total screen height
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      // color: AppColors
      //     .background_day_7, //rgb(250 252 253) // Set the background color to white
      child: Stack(
        children: [
          Column(
            children: [
              Flexible(
                flex: 1,
                child: Container(
                    // color: Colors.red,
                    ), // Placeholder for the bottom half
              ),
              Flexible(
                flex: 3,
                child: Container(
                  // color: Colors.amber,
                  child: SwipeableCards(
                      state: _widgetState, onStateChange: _updateWidgetState),
                ),
              ),
              Flexible(
                flex: 6,
                child: Container(
                  // color: Colors.blue.shade100,
                  child: SeatSelectionWidget(
                      state: _widgetState,
                      onStateChange:
                          _updateWidgetState), // Placeholder for the bottom half
                ),
              ),
            ],
          ),

          // The top half
          if (_widgetState == CinemaWidgetState.ticketing)
            Positioned(
              left: 0,
              right: 0,
              top: screenHeight * .128,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: ClipRect(
                  clipper: CustomClipper1(screenHeight * .125),
                  child: SlideTransition(
                    position: _slideInFromTopAnimation,
                    child: const MovieCards(
                      date: '10.12.2017',
                      time: '3:30PM',
                      seats: 'ROW D, SEAT 3,4',
                      movieTitle: 'Blade Runner 2049',
                      total: '\$40',
                      imageUrl:
                          'assets/images/blade_runner_poster_standing.png',
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DelayedCurve extends Curve {
  @override
  double transform(double t) {
    if (t < 0.8) {
      return 0.0; // Remains constant for the first 80% of the time
    } else {
      // In the last 20%, interpolate from 0 to 1
      return (t - 0.8) / 0.2;
    }
  }
}

class SwipeableCards extends StatefulWidget {
  final CinemaWidgetState state;
  final Function(CinemaWidgetState) onStateChange;

  const SwipeableCards(
      {super.key, required this.state, required this.onStateChange});
  @override
  _SwipeableCardsState createState() => _SwipeableCardsState();
}

class _SwipeableCardsState extends State<SwipeableCards>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late VideoPlayerController _videoController;
  late AnimationController _animationController;
  late Animation<double> _viewportFractionAnimation;
  static const double _cardAspectRatio = 0.8;
  double _currentPage = 0.0;
  bool _isExpanded = false;

  late AnimationController _screenAnimationController;
  late Animation<double> _screenAnimation;
  late Animation<double> _screenShadowAnimation;

  late AnimationController _s2lAnimationController;
  late Animation<double> _s2lShadowDisappearAnimation;
  late Animation<double> _s2lAnimation;

  late Animation<double> _lineOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the video player controller
    _videoController =
        VideoPlayerController.asset('assets/videos/blade_runner.mp4')
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized
            setState(() {});
          });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _viewportFractionAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pageController =
        PageController(viewportFraction: _viewportFractionAnimation.value);
    _pageController.addListener(_onScroll);
    _viewportFractionAnimation.addListener(() {
      setState(() {
        _pageController =
            PageController(viewportFraction: _viewportFractionAnimation.value);
        _pageController.addListener(_onScroll);
      });
    });

    _screenAnimationController = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );

    _screenAnimation = Tween<double>(begin: 0, end: 0.9).animate(
      CurvedAnimation(
          parent: _screenAnimationController, curve: Curves.easeInOut),
    );
    _screenShadowAnimation = Tween<double>(begin: 0, end: 1.0).animate(
        CurvedAnimation(
            parent: _screenAnimationController, curve: DelayedCurve()));

    //----------------------------
    _s2lAnimationController = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );
    _s2lShadowDisappearAnimation = Tween<double>(begin: 0, end: 1.0).animate(
        CurvedAnimation(
            parent: _s2lAnimationController,
            curve: const Interval(0.0, 0.2, curve: Curves.easeInOut)));
    _s2lAnimation = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(parent: _s2lAnimationController, curve: Curves.easeInOut),
    );

    //state 2 = (0 to 0.9) | state 3 = (0.9 to 1.57)

    _lineOpacityAnimation = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(
        parent: _s2lAnimationController,
        curve: const Interval(0.9, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  void _onScroll() {
    setState(() {
      _currentPage = _pageController.page!;
      if (_currentPage >= 0.8 && _currentPage <= 1.2) {
        _videoController.play();
      } else {
        _videoController.pause();
      }
    });
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
        _screenAnimationController.forward();
      } else {
        _animationController.reverse();
        _screenAnimationController.reverse();
      }
    });
  }

  double interpolateRotation(double value, double startAngle, double endAngle) {
    if (value > 1.0) {
      value = value - 1;
      print("interpolateRotation value: $value");
    }

    if (value <= 0.2) {
      // Phase 1: From startAngle to endAngle (0 to 0.2)
      return startAngle + (endAngle - startAngle) * (value / 0.2);
    } else if (value <= 0.8) {
      // Phase 2: Stay at endAngle (0.2 to 0.8)
      return endAngle;
    } else {
      // Phase 3: From endAngle back to startAngle (0.8 to 1.0)
      return endAngle + (startAngle - endAngle) * ((value - 0.8) / 0.2);
    }
  }

  @override
  void didUpdateWidget(SwipeableCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _triggerStateChanges();
    }
  }

  void _triggerStateChanges() {
    if (widget.state == CinemaWidgetState.seating) {
      _toggleExpand();
    } else if (widget.state == CinemaWidgetState.ticketing) {
      // _controller.reverse();
      // print("Implementation pending _triggerStateChanges: ${widget.state}");
      _s2lAnimationController.forward();
      _videoController.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = constraints.maxWidth * 0.8;
        double cardHeight = cardWidth / _cardAspectRatio;

        return Column(
          children: [
            Expanded(
              child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _animationController,
                    _screenAnimationController,
                    _s2lAnimationController
                  ]),
                  builder: (context, child) {
                    return Stack(
                      children: [
                        Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Opacity(
                                opacity: _screenShadowAnimation.value -
                                    _s2lShadowDisappearAnimation.value,
                                child: Container(
                                  child: const ShadowGradientRectangle(),
                                  // Text("Container for shadow"),
                                ))),
                        PageView.builder(
                          physics: _isExpanded
                              ? const NeverScrollableScrollPhysics()
                              : const AlwaysScrollableScrollPhysics(),
                          controller: _pageController,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            double page = _currentPage - index;
                            double angle =
                                interpolateRotation(page.abs(), 0, -0.3);

                            return Container(
                              width: cardWidth,
                              height: cardHeight,
                              child: Stack(
                                children: [
                                  Transform(
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.002)
                                      ..rotateY(angle)
                                      ..rotateX(_screenAnimation.value +
                                          (_s2lAnimation.value * 0.67)),
                                    // ..rotateX(_isExpanded ? angle * _animation.value : 0),
                                    alignment: FractionalOffset.center,
                                    child: _buildCard(
                                        index, cardWidth, cardHeight),
                                  ),
                                  Opacity(
                                    opacity: _lineOpacityAnimation.value,
                                    child: Center(
                                      child: Container(
                                        width: cardWidth,
                                        height:
                                            2, // Adjust this value for desired thickness
                                        color: Colors
                                            .black, // Or any color you prefer
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        )
                      ],
                    );
                  }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard(int index, double cardWidth, double cardHeight) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Center(
          child: SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.blue[100 * (index % 9 + 1)],
                  child: index != 1
                      ? Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Colors.blue[100 * (index % 9 + 1)],
                          child: Center(
                            child: Text(
                              'Page ${index + 1}',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : _videoController.value.isInitialized
                          ? _buildCroppedVideo(constraints)
                          : const Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCroppedVideo(BoxConstraints constraints) {
    final Size videoSize = _videoController.value.size;
    final double videoAspectRatio = videoSize.width / videoSize.height;
    final double cardAspectRatio = constraints.maxWidth / constraints.maxHeight;

    double width, height;
    double scaleFactor = 1.2; // Increase this value to zoom in more

    if (cardAspectRatio > videoAspectRatio) {
      // Card is wider than video, crop top and bottom
      width = constraints.maxWidth;
      height = width / videoAspectRatio;
    } else {
      // Card is taller than video, crop sides
      height = constraints.maxHeight;
      width = height * videoAspectRatio;
    }

    // Apply the scale factor
    width *= scaleFactor;
    height *= scaleFactor;

    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: OverflowBox(
            maxWidth: width,
            maxHeight: height,
            child: Container(
              child: Center(
                child: Transform.scale(
                  scale: scaleFactor,
                  child: AspectRatio(
                    aspectRatio: videoAspectRatio,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              ),
            )));
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    _videoController.dispose();
    _animationController.dispose();
    _screenAnimationController.dispose();
    super.dispose();
  }
}
