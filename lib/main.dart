import 'package:flutter/material.dart';

import 'models.dart';
import 'theme.dart';
import 'screens/login.dart';
import 'screens/dashboard.dart';

void main() {
  runApp(const SolosApp());
}

/// Root widget. Mirrors `App.tsx`: holds the top-level state (current user,
/// personas, installed apps) and switches between Login and Dashboard.
class SolosApp extends StatefulWidget {
  const SolosApp({super.key});

  @override
  State<SolosApp> createState() => _SolosAppState();
}

class _SolosAppState extends State<SolosApp> {
  Persona? _currentUser;
  List<Persona> _personas = [];
  List<InstalledApp> _installedApps = [];

  void _handleLogin(String username, String email) {
    final slug = username.isNotEmpty ? username : 'user';
    final master = Persona(
      id: 'master',
      name: username.isNotEmpty ? username : 'Master Profile',
      username: username,
      email: email,
      webId: 'https://$slug.solidcommunity.net/profile/card#me',
      isMaster: true,
    );
    setState(() {
      _currentUser = master;
      _personas = [master];
    });
  }

  void _handleLogout() {
    setState(() {
      _currentUser = null;
      _personas = [];
      _installedApps = [];
    });
  }

  void _setPersonas(List<Persona> personas) {
    setState(() => _personas = personas);
  }

  void _setInstalledApps(List<InstalledApp> apps) {
    setState(() => _installedApps = apps);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoloS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.slate50,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.amber600,
          primary: AppColors.amber600,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: AppColors.amber200,
        ),
      ),
      home: _currentUser == null
          ? LoginScreen(onLogin: _handleLogin)
          : DashboardScreen(
              currentUser: _currentUser!,
              personas: _personas,
              setPersonas: _setPersonas,
              installedApps: _installedApps,
              setInstalledApps: _setInstalledApps,
              onLogout: _handleLogout,
            ),
    );
  }
}
