import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:twitter_clone/services/auth/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthGate()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set full black background
      body: Center(
        child: Lottie.asset(
          'assets/animations/twitter_logo_animation.json', // Path to Lottie animation
          width: 250,
          height: 350,
          fit: BoxFit.contain,
          repeat: false, // Plays once
        ),
      ),
    );
  }
}


//Splash screen with logo animation

// import 'package:flutter/material.dart';
// import 'package:twitter_clone/services/auth/auth_gate.dart';

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _opacityAnimation;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );

//     _opacityAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

//     _scaleAnimation = Tween<double>(
//       begin: 0.3,
//       end: 1.1,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));

//     _controller.forward();

//     Future.delayed(const Duration(seconds: 3), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => AuthGate()),
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         color: Colors.black,
//         child: Center(
//           child: AnimatedBuilder(
//             animation: _controller,
//             builder: (context, child) {
//               return Opacity(
//                 opacity: _opacityAnimation.value,
//                 child: Transform.scale(
//                   scale: _scaleAnimation.value,
//                   child: child,
//                 ),
//               );
//             },
//             child: Image.asset(
//               'assets/images/twitter_logo.jpg', // Ensure the logo is in assets
//               width: 150,
//               height: 150,
//               filterQuality: FilterQuality.high,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

