import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart' show rootBundle;


// تعريف كل الـ gradients
final Map<String, LinearGradient> gradients = {
  "red": LinearGradient(
    colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  "blue": LinearGradient(
    colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  "green": LinearGradient(
    colors: [Color(0xFF56ab2f), Color(0xFFa8e063)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  "gold": LinearGradient(
    colors: [Color(0xFFF7971E), Color(0xFFFFD200)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
};

class RomanticSlideshowPage extends StatefulWidget {
  const RomanticSlideshowPage({super.key});

  @override
  State<RomanticSlideshowPage> createState() => _RomanticSlideshowPageState();
}

class _RomanticSlideshowPageState extends State<RomanticSlideshowPage> {

Color lighten(Color color, [double amount = 0.2]) {
  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return hslLight.toColor();
}

  int _currentIndex = 0;
  late Timer _timer;
  List<Map<String, String>> slides = [];
  String themeKey = "red"; // اللون الافتراضي

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    // تحميل ملف الإعدادات
    String configString = await rootBundle.loadString('assets/config.json');
    Map<String, dynamic> configData = json.decode(configString);
    themeKey = configData["themeColor"] ?? "red";

    // تحميل السلايدز
    String jsonString = await rootBundle.loadString('assets/Image.json');
    List<dynamic> jsonData = json.decode(jsonString);
    slides = jsonData.map((item) => {
          "image": item["image"] as String,
          "text": item["text"] as String,
        }).toList();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % slides.length;
        });
      }
    });
    setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (slides.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // الخلفية بتدرج اللون
          Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: gradients[themeKey]!.colors
          .map((c) => lighten(c, 0.3)) // أفتح 15%
          .toList(),
      begin: gradients[themeKey]!.begin,
      end: gradients[themeKey]!.end,
    ),
  ),
),
          // القلوب المتحركة
          AnimatedHeartsBackground(themeKey: themeKey),

          SafeArea(
            child: Column(
              children: [
                // AppBar مخصص
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: gradients[themeKey],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          "ذكريات خطوبتنا 💖",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.amiri(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // علشان توازن المساحة
                    ],
                  ),
                ),

                // الصورة
                Expanded(
                  flex: 7,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    child: AspectRatio(
                      key: ValueKey<String>(slides[_currentIndex]["image"]!),
                      aspectRatio: 3 / 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          slides[_currentIndex]["image"]!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // النص
                Expanded(
                  flex: 3,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: LayoutBuilder(
                      key: ValueKey<String>(slides[_currentIndex]["text"]!),
                      builder: (context, constraints) {
                        double fontSize = constraints.maxWidth * 0.05;
                        return Text(
                          slides[_currentIndex]["text"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.amiri(
                            fontSize: fontSize,
                            color: Colors.white,
                            height: 1.6,
                            fontWeight: FontWeight.w600,
                            shadows: const [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black26,
                                offset: Offset(2, 2),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // مؤشرات القلوب
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.favorite,
                        color: _currentIndex == index
                            ? gradients[themeKey]!.colors.first
                            : Colors.white54,
                        size: _currentIndex == index ? 20 : 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// خلفية القلوب مع اللون من الـ JSON
class AnimatedHeartsBackground extends StatefulWidget {
  final String themeKey;
  const AnimatedHeartsBackground({super.key, required this.themeKey});

  @override
  State<AnimatedHeartsBackground> createState() =>
      _AnimatedHeartsBackgroundState();
}

class _AnimatedHeartsBackgroundState extends State<AnimatedHeartsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final List<_Heart> _hearts = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 15; i++) {
      _hearts.add(_Heart(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 20 + _random.nextDouble() * 20,
        speed: 0.2 + _random.nextDouble() * 0.4,
      ));
    }

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..addListener(() {
            for (var heart in _hearts) {
              heart.y -= heart.speed / 100;
              if (heart.y < -0.1) {
                heart.y = 1.1;
                heart.x = _random.nextDouble();
              }
            }
            setState(() {});
          })
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HeartsPainter(_hearts, gradients[widget.themeKey]!.colors.first),
      child: Container(),
    );
  }
}

class _Heart {
  double x;
  double y;
  double size;
  double speed;

  _Heart({required this.x, required this.y, required this.size, required this.speed});
}

class _HeartsPainter extends CustomPainter {
  final List<_Heart> hearts;
  final Color heartColor;
  _HeartsPainter(this.hearts, this.heartColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = heartColor.withOpacity(0.3);
    for (var heart in hearts) {
      final path = Path();
      double x = heart.x * size.width;
      double y = heart.y * size.height;
      path.moveTo(x, y);
      path.cubicTo(x - heart.size / 2, y - heart.size / 2,
          x - heart.size, y + heart.size / 3, x, y + heart.size);
      path.cubicTo(x + heart.size, y + heart.size / 3,
          x + heart.size / 2, y - heart.size / 2, x, y);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
