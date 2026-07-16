import 'dart:async';

import 'package:flutter/material.dart';

import '../data.dart';
import '../models.dart';
import '../theme.dart';

/// Mirrors `AppRuntime.tsx`: a full-screen simulated iframe container. It shows
/// an authenticating/mounting handshake for 1.5s, then renders the simulated
/// app UI with the injected Solid environment variables.
class AppRuntimeScreen extends StatefulWidget {
  final InstalledApp instance;
  final List<Persona> personas;

  const AppRuntimeScreen({
    super.key,
    required this.instance,
    required this.personas,
  });

  @override
  State<AppRuntimeScreen> createState() => _AppRuntimeScreenState();
}

class _AppRuntimeScreenState extends State<AppRuntimeScreen> {
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Simulate iframe loading and SSO handshake.
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Persona? get _persona {
    for (final p in widget.personas) {
      if (p.id == widget.instance.personaId) return p;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final appDef = findAppById(widget.instance.appId);
    final persona = _persona;
    if (appDef == null || persona == null) {
      // Mirrors `if (!appDef || !persona) return null;`
      return const Scaffold(backgroundColor: AppColors.slate900);
    }

    return Scaffold(
      backgroundColor: AppColors.slate900,
      body: Column(
        children: [
          _buildChrome(appDef, persona),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate700),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 40,
                    offset: Offset(0, 20),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _isLoading
                  ? _buildLoading(appDef)
                  : _buildAppContent(appDef, persona),
            ),
          ),
        ],
      ),
    );
  }

  /// Container header / browser chrome bar.
  Widget _buildChrome(SolidApp appDef, Persona persona) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.slate800,
        border: Border(bottom: BorderSide(color: AppColors.slate700)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text(
                  'Workspace',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.slate300,
                  overlayColor: AppColors.slate700,
                ),
              ),
              const SizedBox(width: 16),
              Container(width: 1, height: 24, color: AppColors.slate700),
              const SizedBox(width: 16),
              Icon(appDef.icon, size: 16, color: AppColors.amber400),
              const SizedBox(width: 8),
              Text(
                appDef.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate100,
                ),
              ),
            ],
          ),
          // SSO badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.green900.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: AppColors.green800),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user,
                    size: 16, color: AppColors.green400),
                const SizedBox(width: 8),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.green300,
                    ),
                    children: [
                      const TextSpan(text: 'SSO Active as '),
                      TextSpan(
                        text: persona.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Loading / authenticating overlay.
  Widget _buildLoading(SolidApp appDef) {
    return Container(
      color: AppColors.slate50,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.amber500,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Authenticating & Mounting...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: const TextStyle(color: AppColors.slate600),
                children: [
                  const TextSpan(text: 'Injecting Solid SSO session for '),
                  TextSpan(
                    text: appDef.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: AppColors.slate200),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.amber500,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Syncing bidirectional pod streams',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Simulated app UI with the injected environment variables panel.
  Widget _buildAppContent(SolidApp appDef, Persona persona) {
    final podRoot = persona.webId.replaceAll('profile/card#me', '');
    return Container(
      color: AppColors.slate50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 672),
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.slate100, AppColors.slate200],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.slate300),
                    ),
                    child: Icon(appDef.icon,
                        size: 40, color: AppColors.slate700),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${appDef.name} Runtime',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                      style: const TextStyle(
                        height: 1.5,
                        color: AppColors.slate500,
                      ),
                      children: [
                        const TextSpan(
                          text:
                              'This is a simulated iframe container. In production, '
                              'this would render ',
                        ),
                        TextSpan(
                          text: appDef.url,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: AppColors.slate800,
                            backgroundColor: AppColors.slate100,
                          ),
                        ),
                        const TextSpan(
                          text: ' and pass the WebID credentials securely.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildEnvPanel(persona, podRoot),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnvPanel(Persona persona, String podRoot) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.slate900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate800),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amber top accent bar
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.amber400, AppColors.amber600],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'INJECTED ENVIRONMENT VARIABLES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AppColors.slate400,
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.green500,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildEnvRow('WEBID:', persona.webId, AppColors.green400,
                    hasDivider: true),
                _buildEnvRow('POD_ROOT:', podRoot, AppColors.amber400,
                    hasDivider: true),
                _buildEnvRow(
                  'IS_ISOLATED:',
                  persona.isMaster ? 'false' : 'true',
                  const Color(0xFF60A5FA), // blue-400
                  bold: true,
                  hasDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvRow(
    String label,
    String value,
    Color valueColor, {
    bool bold = false,
    bool hasDivider = true,
  }) {
    return Container(
      padding: EdgeInsets.only(bottom: hasDivider ? 12 : 0),
      margin: EdgeInsets.only(bottom: hasDivider ? 12 : 0),
      decoration: hasDivider
          ? const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: AppColors.slate800)),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: AppColors.slate500,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: valueColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: valueColor,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
