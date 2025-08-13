import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'LoginPage.dart';

void main() async 
{
  WidgetsFlutterBinding.ensureInitialized();
  await loadGiftData();
  runApp
  (
	MaterialApp
	(
		debugShowCheckedModeBanner: false,
		home: LoginPage(),
	)
  );
}

