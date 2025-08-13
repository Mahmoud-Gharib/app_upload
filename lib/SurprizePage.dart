import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';


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

class SurprizePage extends StatefulWidget 
{
  const SurprizePage({Key? key}) : super(key: key);

  @override
  State<SurprizePage> createState() => _SurprizePageState();
}

class _SurprizePageState extends State<SurprizePage> 
{
  String themeKey = "blue"; // قيمة افتراضية
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThemeKey();
  }

  Future<void> _loadThemeKey() async 
  {
    try {
      String jsonString = await rootBundle.loadString('assets/config.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final key = jsonData['themeColor'] as String?;
      if (key != null && gradients.containsKey(key)) {
        themeKey = key;
      }
    } catch (e) {
      // لو فشل التحميل نخلي القيمة الافتراضية
      print('Failed to load themeKey: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  // لتفتيح اللون - نفس دالتك
  Color lighten(Color color, [double amount = 0.15]) {
    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final gradient = gradients[themeKey]!;
    final lightGradient = LinearGradient(
      colors: gradient.colors.map((c) => lighten(c, 0.18)).toList(),
      begin: gradient.begin,
      end: gradient.end,
    );

    return Scaffold(
      backgroundColor: gradient.colors.first,
      appBar: AppBar(
        backgroundColor: gradient.colors.first,
        title: Text(
          'عيدية غالية 💸',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 6,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: lightGradient)),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/SurprizeImage/1.JPG',
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 40),
                  Text(
                    'عيدية غالية لكيِ في هذا العيد المبارك 🎁',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 28,
                      color: gradient.colors.last.darken(0.3),
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(1.5, 1.5),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'تمنياتي لكِي بعيد مليء بالفرح والهدايا والسعادة.💖',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      color: gradient.colors.last,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 50),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gradient.colors.first,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 8,
                      shadowColor: gradient.colors.first.withOpacity(0.5),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: Text('🎉 مفاجأة العيدية 🎉',
                              style:
                                  GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                          content: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/SurprizeImage/1.JPG',
                              fit: BoxFit.cover,
                              width: 250,
                              height: 250,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('شكرًا 💖', style: GoogleFonts.cairo()),
                            )
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.card_giftcard),
                    label: Text(
                      'افتحي العيدية',
                      style: GoogleFonts.cairo(
                          fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension لتغميق اللون
extension ColorBrightness on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark =
        hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
