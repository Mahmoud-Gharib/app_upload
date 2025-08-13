import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

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

Color lighten(Color color, [double amount = 0.3]) 
{
  final hsl = HSLColor.fromColor(color);
  final hslLight =
      hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return hslLight.toColor();
}

class ScrollMessageScreen extends StatefulWidget 
{
  const ScrollMessageScreen({super.key});

  @override
  State<ScrollMessageScreen> createState() => _ScrollMessageScreenState();
}

class _ScrollMessageScreenState extends State<ScrollMessageScreen> 
{
  String _fullMessage = '';
  String _visibleText = '';
  int _wordDelay = 300;
  Color _paperColor = const Color(0xFFFDF3C6);
  Color _textColor = Colors.black87;
  String _soundAsset = 'assets/sounds/message.mp3';

  String themeKey = "red"; // القيمة الافتراضية

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _loadConfigAndMessage();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadConfigAndMessage() async {
    // تحميل ملف config.json لاختيار themeColor
    try {
      final configString = await rootBundle.loadString('assets/config.json');
      final configData = json.decode(configString);
      themeKey = (configData['themeColor'] as String?)?.toLowerCase() ?? "red";
      if (!gradients.containsKey(themeKey)) themeKey = "red";
    } catch (e) {
      themeKey = "red";
    }

    // تحميل ملف message.json لبيانات الرسالة والخصائص الأخرى
    try {
      final jsonString = await rootBundle.loadString('assets/message.json');
      final data = json.decode(jsonString);

      _fullMessage = data['message'] ?? '';
      _paperColor = _parseColor(data['primaryColor']) ?? _paperColor;
      _textColor = _parseColor(data['textColor']) ?? _textColor;
      _soundAsset = data['sound'] ?? _soundAsset;
      _wordDelay = data['wordDelayMs'] ?? _wordDelay;
    } catch (e) {
      debugPrint("Error loading JSON: $e");
    }

    await _startAudio();
    _startWordByWord();
  }

  Color? _parseColor(String? hex) {
    if (hex == null) return null;
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Future<void> _startAudio() async {
    try {
      await _audioPlayer.play(AssetSource(_soundAsset.replaceFirst('assets/', '')));
      _isPlaying = true;
    } catch (e) {
      debugPrint("Audio error: $e");
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  Future<void> _startWordByWord() async {
    final words = _fullMessage.split(RegExp(r'\s+'));
    _visibleText = '';
    setState(() => _isFinished = false);

    for (final word in words) {
      if (!mounted) return;
      _visibleText += (_visibleText.isEmpty ? '' : ' ') + word;
      setState(() {});
      await Future.delayed(Duration(milliseconds: _wordDelay));
    }

    if (mounted) {
      setState(() => _isFinished = true);
      await _stopAudio();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = gradients[themeKey] ?? gradients["red"]!;
    final lightBackgroundColor = lighten(gradient.colors.first, 0.18);

    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'الرسالة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: gradient),
        ),
        elevation: 2,
      ),
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textSpan = TextSpan(
                text: _visibleText,
                style: TextStyle(
                  fontSize: 18,
                  color: _textColor,
                  height: 1.7,
                ),
              );

              final textPainter = TextPainter(
                text: textSpan,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                maxLines: null,
              );

              final availableTextWidth = constraints.maxWidth * 0.85 - 36;
              textPainter.layout(maxWidth: availableTextWidth);

              final textHeight = textPainter.size.height;
              final baseHeight = 150.0;
              final paperHeight = (baseHeight + textHeight + 30).clamp(150.0, constraints.maxHeight * 0.9);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: constraints.maxWidth * 0.85,
                height: paperHeight,
                child: CustomPaint(
                  painter: RealisticScrollPainter(paperColor: _paperColor),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 38),
                    child: Column(
                      children: [
                        Text(
                          'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيم',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              _visibleText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: _textColor,
                                height: 1.7,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isFinished ? 'نهاية الرسالة' : '... جاري العرض',
                              style: TextStyle(color: _textColor.withOpacity(0.7)),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    if (_isPlaying) {
                                      await _audioPlayer.pause();
                                      setState(() => _isPlaying = false);
                                    } else {
                                      await _audioPlayer.resume();
                                      setState(() => _isPlaying = true);
                                    }
                                  },
                                  icon: Icon(
                                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                    color: _textColor,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await _audioPlayer.stop();
                                    setState(() {
                                      _visibleText = '';
                                      _isFinished = false;
                                    });
                                    await _startAudio();
                                    _startWordByWord();
                                  },
                                  icon: Icon(Icons.replay, color: _textColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class RealisticScrollPainter extends CustomPainter {
  final Color paperColor;

  RealisticScrollPainter({required this.paperColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double poleHeight = 38;
    final double knobRadius = 11;

    final texturePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          paperColor,
          paperColor.withOpacity(0.9),
          paperColor.withOpacity(0.95),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, poleHeight + 5);
    path.quadraticBezierTo(size.width * 0.1, poleHeight - 5, size.width * 0.2, poleHeight + 5);
    path.quadraticBezierTo(size.width * 0.5, poleHeight + 15, size.width * 0.8, poleHeight + 5);
    path.quadraticBezierTo(size.width * 0.9, poleHeight - 5, size.width, poleHeight + 5);
    path.lineTo(size.width, size.height - poleHeight - 5);
    path.quadraticBezierTo(size.width * 0.9, size.height - poleHeight + 5, size.width * 0.8, size.height - poleHeight - 5);
    path.quadraticBezierTo(size.width * 0.5, size.height - poleHeight - 15, size.width * 0.2, size.height - poleHeight - 5);
    path.quadraticBezierTo(size.width * 0.1, size.height - poleHeight + 5, 0, size.height - poleHeight - 5);
    path.close();

    canvas.drawPath(path, texturePaint);

    final textureLinePaint = Paint()
      ..color = Colors.brown.withOpacity(0.08)
      ..strokeWidth = 1;
    for (double y = poleHeight + 10; y < size.height - poleHeight; y += 6) {
      canvas.drawLine(Offset(5, y), Offset(size.width - 5, y), textureLinePaint);
    }

    final shadowPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.black.withOpacity(0.15), Colors.transparent],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, poleHeight, size.width, size.height - (poleHeight * 2)));
    canvas.drawPath(path, shadowPaint);

    final borderPaint = Paint()
      ..color = Colors.brown.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);

    final poleGradientTop = LinearGradient(
      colors: [const Color(0xFFE9C57B), const Color(0xFFB68A3A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, size.width, poleHeight));

    final poleGradientBottom = LinearGradient(
      colors: [const Color(0xFFB68A3A), const Color(0xFFE9C57B)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, size.height - poleHeight, size.width, poleHeight));

    final topPaint = Paint()..shader = poleGradientTop;
    canvas.drawRect(Rect.fromLTWH(-8, 0, size.width + 16, poleHeight), topPaint);
    canvas.drawCircle(Offset(0, poleHeight / 2), knobRadius, topPaint);
    canvas.drawCircle(Offset(size.width, poleHeight / 2), knobRadius, topPaint);

    final bottomPaint = Paint()..shader = poleGradientBottom;
    canvas.drawRect(Rect.fromLTWH(-8, size.height - poleHeight, size.width + 16, poleHeight), bottomPaint);
    canvas.drawCircle(Offset(0, size.height - poleHeight / 2), knobRadius, bottomPaint);
    canvas.drawCircle(Offset(size.width, size.height - poleHeight / 2), knobRadius, bottomPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
