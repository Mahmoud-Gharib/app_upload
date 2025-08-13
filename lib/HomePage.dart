import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'DuaaPage.dart';
import 'MessagePage.dart';
import 'SurprizePage.dart';
import 'ImagePage.dart';


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

IconData getIconFromString(String iconName) 
{
  switch (iconName) {
    case 'birthday': return Icons.cake;
    case 'graduation': return Icons.school;
    case 'love': return Icons.favorite;
    case 'mothers_day': return Icons.woman;
    case 'eid_al_adha': return Icons.pets;
    case 'eid_al_fitr': return Icons.brightness_2;
    case 'ramadan': return Icons.brightness_2;
    case 'wedding': return Icons.favorite_border;
    case 'engagement': return Icons.ring_volume;
    case 'new_year': return Icons.celebration;
    case 'support': return Icons.self_improvement;
    case 'motivation': return Icons.rocket_launch;
    case 'other': return Icons.card_giftcard;
    default: return Icons.card_giftcard;
  }
}

String getOccasionDisplayName(String key) 
{
  switch (key) 
  {
    case 'birthday': return "عيد ميلاد";
    case 'graduation': return "حفل تخرج";
    case 'love': return "عيد الحب";
    case 'mothers_day': return "عيد الأم";
    case 'eid_al_adha': return "عيد الأضحى";
    case 'eid_al_fitr': return "عيد الفطر";
    case 'ramadan': return "رمضان كريم";
    case 'wedding': return "زواج";
    case 'engagement': return "خطوبة";
    case 'new_year': return "رأس السنة";
    case 'support': return "دعم نفسي";
    case 'motivation': return "تحفيز";
    case 'other': return "مناسبة خاصة";
    default: return "مناسبة خاصة";
  }
}

class MainPage extends StatefulWidget 
{
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> 
{
  String themeKey = "red";
  String occasionName = "other";

  @override
  void initState() 
  {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async 
  {
    try {
      final conf = await rootBundle.loadString('assets/config.json');
      final Map<String, dynamic> confData = json.decode(conf);
      setState(() {
        themeKey = (confData["themeColor"] as String?) ?? "red";
        occasionName = (confData["occasion"] as String?) ?? "other";
      });
    } catch (e) 
	{
      themeKey = "red";
      occasionName = "other";
    }
  }

  void _navigateTo(Widget page) 
  {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween(begin: Offset(1, 0), end: Offset.zero)
                .animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = gradients[themeKey] ?? gradients["red"]!;
    final occasionIcon = getIconFromString(occasionName);

    final menuItems = [
      {"title": "الرئيسية", "icon": Icons.home, "page": MainPage()},
      {"title": "الأدعية", "icon": Icons.menu_book, "page": DuaaPage()},
	  {"title": "الرساله", "icon": Icons.menu_book, "page": ScrollMessageScreen()},
	  {"title": "المفاجأه", "icon": Icons.menu_book, "page": SurprizePage()},
      {"title": "الصور", "icon": Icons.settings, "page": RomanticSlideshowPage()},
      //{"title": "عن التطبيق", "icon": Icons.info, "page": AboutPage(themeKey)},
    ];

    return Scaffold(
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(gradient: gradient),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(occasionIcon, color: Colors.white, size: 48),
                    SizedBox(height: 8),
                    Text(
                      getOccasionDisplayName(occasionName),
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ...menuItems.map((item) {
                return ListTile(
                  leading: Icon(item["icon"] as IconData, color: Colors.white),
                  title: Text(item["title"] as String,
                      style: GoogleFonts.cairo(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateTo(item["page"] as Widget);
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          "الرئيسية",
          style: GoogleFonts.cairo(),
        ),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: gradient)),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: menuItems.map((item) {
              return GestureDetector(
                onTap: () => _navigateTo(item["page"] as Widget),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item["icon"] as IconData, color: Colors.white, size: 36),
                      SizedBox(height: 8),
                      Text(
                        item["title"] as String,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
