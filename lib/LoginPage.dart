import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'HomePage.dart';
Future<void> loadGiftData() async 
{
  String jsonString = await rootBundle.loadString('assets/config.json');
  Map<String, dynamic> data = jsonDecode(jsonString);

  glalyName = data['name'];
  password = data['password'];
  occasionIcon = getIconFromString(data['occasion']);

  String gradientName = data['themeColor'] ?? "blue";
  if (gradients.containsKey(gradientName)) 
  {
    mainGradient = gradients[gradientName]!;
    primaryColor = mainGradient.colors.first;
    secondaryColor = mainGradient.colors.last;
  }
}

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

String glalyName = "";
String password = "";
IconData occasionIcon = Icons.cake;

Color primaryColor = const Color(0xFF1E88E5);
Color secondaryColor = const Color(0xFF64B5F6);
LinearGradient mainGradient = gradients["blue"]!;

IconData getIconFromString(String iconName) 
{
  switch (iconName) 
  {
    case 'birthday':
      return Icons.cake;
    case 'graduation':
      return Icons.school;
    case 'love':
      return Icons.favorite;
    case 'mothers_day':
      return Icons.woman;
    case 'eid_al_adha':
      return Icons.pets;
    case 'eid_al_fitr':
    case 'ramadan':
      return Icons.brightness_2;
    case 'wedding':
      return Icons.favorite_border;
    case 'engagement':
      return Icons.ring_volume;
    case 'new_year':
      return Icons.celebration;
    case 'support':
      return Icons.self_improvement;
    case 'motivation':
      return Icons.rocket_launch;
    default:
      return Icons.card_giftcard;
  }
}

class LoginPage extends StatefulWidget 
{
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _fadeAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void validateAndLogin() {
    setState(() {
      if (nameController.text.isEmpty || passwordController.text.isEmpty) {
        errorMessage = 'من فضلك ادخل كل البيانات ✨';
      } else if (nameController.text != glalyName ||
          passwordController.text != password) {
        errorMessage = 'الاسم أو كلمة السر غير صحيحة 💔';
      } else {
        errorMessage = '';
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MainPage()),
        );
      }
    });
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      hintStyle: TextStyle(color: Colors.grey.shade600),
      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: mainGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 24),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(occasionIcon, size: 70, color: primaryColor),
                    SizedBox(height: 16),
                    Text(
                      'تسجيل هدية الغالي 💝',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      textAlign: TextAlign.center,
                      decoration: _inputStyle('اسم الغالي'),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      textAlign: TextAlign.center,
                      decoration: _inputStyle('كلمة السر'),
                    ),
                    SizedBox(height: 20),
                    if (errorMessage.isNotEmpty)
                      Text(
                        errorMessage,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: validateAndLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'تسجيل',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ صفحة ترحيب بسيطة
class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: Center(
        child: Text(
          '🎉 أهلاً بك يا $glalyName 🎉',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
