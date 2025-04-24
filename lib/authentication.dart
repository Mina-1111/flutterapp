import 'package:flutter/material.dart';
import 'dart:math';
import 'package:graduation/login_page.dart';
import 'package:graduation/main.dart';
import 'package:graduation/sign_up.dart';

class Authentication extends StatefulWidget {
  const Authentication({Key? key}) : super(key: key);

  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _gradientController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _gradientAnimation = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(
        parent: _gradientController,
        curve: Curves.easeInOut,
      ),
    );

    // Fade animation for welcome text
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Scale animation for form container
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Slide animation for skip button
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(bool isLogin) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Button press animation
      await _controller.animateTo(0.1,
          duration: const Duration(milliseconds: 100));
      await _controller.animateTo(0,
          duration: const Duration(milliseconds: 200));

      await Future.delayed(const Duration(seconds: 1));

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              isLogin ? login_page() : sign_upWithPhoneAgePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _skipAuth() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MainApp(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(_gradientAnimation.value, -1),
                end: Alignment(-_gradientAnimation.value, 1),
                colors: [Colors.white, Color(0xFFE3F2FD)],
              ),
            ),
            child: child,
          );
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),

                // Welcome section with logo and text
                Column(
                  children: [
                    RotationTransition(
                      turns: Tween(begin: -0.05, end: 0.05).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Icon(
                          Icons.account_circle,
                          size: 80,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          const Text(
                            'Welcome to Azir',
                            style: TextStyle(
                              fontSize: 37,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please login or sign up to continue',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 70),

                // Particles background
                Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return CustomPaint(
                              painter:
                                  ParticlePainter(progress: _controller.value),
                            );
                          },
                        ),
                      ),
                    ),

                    // Auth Form with scale animation
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: _buildLoginForm(),
                      ),
                    ),
                  ],
                ),

                // Skip Button with slide animation
                const SizedBox(height: 30),
                SlideTransition(
                  position: _slideAnimation,
                  child: TextButton(
                    onPressed: _skipAuth,
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.blueGrey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: _buildLoginBtn(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _buildSignUpBtn(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginBtn() {
    return AnimatedButton(
      onPressed: _isLoading ? null : () => _submitForm(true),
      child: _isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            )
          : const Text(
              'Login',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildSignUpBtn() {
    return AnimatedButton(
      onPressed: _isLoading ? null : () => _submitForm(false),
      isSecondary: true,
      child: const Text(
        'Sign Up',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double progress;

  ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final particleCount = 15;
    for (int i = 0; i < particleCount; i++) {
      final xPos = size.width * ((i + 1) / (particleCount + 1));
      final yPos = size.height * 0.3 + sin(progress * 2 * pi + i) * 20;

      canvas.drawCircle(
        Offset(xPos, yPos),
        3 + 2 * sin(progress * pi + i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isSecondary;

  const AnimatedButton({
    required this.child,
    this.onPressed,
    this.isSecondary = false,
  });

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _opacityAnimation = Tween(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(from: 0),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color:
                      widget.isSecondary ? Colors.white : Colors.blue.shade800,
                  border: widget.isSecondary
                      ? Border.all(color: Colors.blue.shade800)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue
                          .withOpacity(widget.isSecondary ? 0.1 : 0.4),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: widget.isSecondary
                          ? Colors.blue.shade800
                          : Colors.white,
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
