import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart' show rootBundle;

final Map<String, LinearGradient> gradients = 
{
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

Color lighten(Color color, [double amount = 0.15]) 
{
  final hsl = HSLColor.fromColor(color);
  final hslLight =
      hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return hslLight.toColor();
}

class DuaaPage extends StatefulWidget 
{
  const DuaaPage({Key? key}) : super(key: key);

  @override
  State<DuaaPage> createState() => _DuaaPageState();
}

class _DuaaPageState extends State<DuaaPage> 
{
  String themeKey = "red";
  List<String> duas = [];
  int _current = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadConfigAndDuas();
  }

  Future<void> _loadConfigAndDuas() async {
    // config.json يحتوي على المفتاح themeColor: "red" / "blue" / "green" / "gold"
    try {
      final conf = await rootBundle.loadString('assets/config.json');
      final Map<String, dynamic> confData = json.decode(conf);
      themeKey = (confData["themeColor"] as String?) ?? "red";
    } catch (e) {
      themeKey = "red";
    }

    // load duas
    try {
      final s = await rootBundle.loadString('assets/Duaa.json');
      final List<dynamic> data = json.decode(s);
      duas = data.map((e) => e.toString()).toList();
    } catch (e) {
      duas = [
        "اللَّهُمَّ إِنِّي أَسْأَلُكَ الهُدَى وَالتُّقَى وَالعَفَافَ وَالغِنَى",
        "رَبِّ زِدْنِي عِلْمًا",
        "اللهم اجعل هذا اليوم مباركًا" // fallback examples
      ];
    }

    // Start cycling duas every 6 seconds
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      setState(() {
        _current = (_current + 1) % duas.length;
      });
    });

    setState(() {});
  }

  @override
  void dispose() {
    if (_timer.isActive) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = gradients[themeKey] ?? gradients["red"]!;
    final lightGradient = LinearGradient(
      colors: gradient.colors.map<Color>((c) => lighten(c, 0.18)).toList(),
      begin: gradient.begin,
      end: gradient.end,
    );

    return Scaffold(
      body: Stack(
        children: [
          // Background (lighter)
          Container(decoration: BoxDecoration(gradient: lightGradient)),

          // subtle decorative hearts (reuse small painter with theme color)
          Positioned.fill(
            child: CustomPaint(
              painter:
                  _HeartsPainterSimple(gradient.colors.first.withOpacity(0.14)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar (custom) with main gradient
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(gradient: gradient),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Text(
                          "بوكس الأدعية",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.amiri(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // المحتوى: large animated dua card
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // small hint
                        

                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _current = (_current + 1) % duas.length;
                            });
                          },
                          onLongPress: () {
                            setState(() {
                              _current =
                                  (_current - 1 + duas.length) % duas.length;
                            });
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 600),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              final inAnim = Tween<Offset>(
                                      begin: const Offset(0, 0.15),
                                      end: Offset.zero)
                                  .animate(
                                      CurvedAnimation(parent: animation, curve: Curves.easeOut));
                              return SlideTransition(
                                position: inAnim,
                                child: FadeTransition(opacity: animation, child: child),
                              );
                            },
                            child: Container(
                              key: ValueKey<int>(_current),
                              width: MediaQuery.of(context).size.width * 0.86,
                              constraints: const BoxConstraints(maxWidth: 720),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 28),
                              decoration: BoxDecoration(
                                gradient: gradient,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 18,
                                      offset: Offset(0, 10)),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // title
                                  

                                  // the dua text (responsive)
                                  LayoutBuilder(builder: (context, constraints) {
                                    double base = constraints.maxWidth;
                                    double fontSize = base * 0.06;
                                    fontSize = fontSize.clamp(18.0, 28.0);
                                    return Text(
                                      duas[_current],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.amiri(
                                        color: Colors.white,
                                        fontSize: fontSize,
                                        height: 1.6,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  }),

                         
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple hearts painter (subtle background decor)
class _HeartsPainterSimple extends CustomPainter {
  final Color color;
  final Random _rnd = Random();
  _HeartsPainterSimple(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final count = 12;
    for (var i = 0; i < count; i++) {
      final dx = _rnd.nextDouble() * size.width;
      final dy = _rnd.nextDouble() * size.height;
      final s = 14 + _rnd.nextDouble() * 36;
      final path = Path();
      double x = dx;
      double y = dy;
      path.moveTo(x, y);
      path.cubicTo(x - s / 2, y - s / 2, x - s, y + s / 3, x, y + s);
      path.cubicTo(x + s, y + s / 3, x + s / 2, y - s / 2, x, y);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
