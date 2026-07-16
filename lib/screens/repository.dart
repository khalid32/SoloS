import 'dart:math';

import 'package:flutter/material.dart';

import '../data.dart';
import '../models.dart';
import '../theme.dart';

/// Mirrors `Repository.tsx`: a modal listing the verified Solid apps. Selecting
/// one lets the user install it with their Master WebID or a freshly generated
/// isolated persona.
class RepositoryModal extends StatefulWidget {
  final List<Persona> personas;
  final void Function(List<Persona>) setPersonas;
  final List<InstalledApp> installedApps;
  final void Function(List<InstalledApp>) setInstalledApps;

  const RepositoryModal({
    super.key,
    required this.personas,
    required this.setPersonas,
    required this.installedApps,
    required this.setInstalledApps,
  });

  @override
  State<RepositoryModal> createState() => _RepositoryModalState();
}

class _RepositoryModalState extends State<RepositoryModal> {
  SolidApp? _selectedApp;

  void _handleInstall(String personaId) {
    final app = _selectedApp;
    if (app == null) return;

    final newApp = InstalledApp(
      instanceId: 'inst-${DateTime.now().millisecondsSinceEpoch}',
      appId: app.id,
      personaId: personaId,
    );
    widget.setInstalledApps([...widget.installedApps, newApp]);
    Navigator.of(context).pop();
  }

  void _handleGeneratePersonaAndInstall() {
    final app = _selectedApp;
    if (app == null) return;

    final newPersonaId = 'persona-${DateTime.now().millisecondsSinceEpoch}';
    final newPersona = Persona(
      id: newPersonaId,
      name: '${app.name} Profile',
      webId: 'https://solos.io/p/${_randomSlug()}#me',
      isMaster: false,
    );
    widget.setPersonas([...widget.personas, newPersona]);
    _handleInstall(newPersonaId);
  }

  String _randomSlug() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 768, maxHeight: 720),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 40,
                offset: Offset(0, 20),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(
                child: Container(
                  color: AppColors.slate50,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _selectedApp == null
                        ? _buildAppList()
                        : _buildAppDetail(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Repository',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Verified decentralized Solid applications',
                  style: TextStyle(fontSize: 14, color: AppColors.slate500),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 24),
            color: AppColors.slate400,
            hoverColor: AppColors.slate100,
          ),
        ],
      ),
    );
  }

  Widget _buildAppList() {
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 640 ? 2 : 1;

    return GridView.count(
      crossAxisCount: columns,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3.2,
      children: [
        for (final app in repositoryApps)
          _RepoAppCard(
            app: app,
            onTap: () => setState(() => _selectedApp = app),
          ),
      ],
    );
  }

  Widget _buildAppDetail() {
    final app = _selectedApp!;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 576),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            // App header card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.amber50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(app.icon, size: 40, color: AppColors.amber600),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          app.description,
                          style: const TextStyle(color: AppColors.slate500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Identity & privacy callout
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.blue50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.blue200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      size: 24, color: AppColors.blue600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Identity & Privacy',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.blue900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'How would you like to sign in to this application? '
                          'You can use your master identity for full data '
                          'access, or create an isolated persona to protect '
                          'your root pod.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.blue800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Master WebID option
            _IdentityOption(
              icon: Icons.shield_outlined,
              iconBg: AppColors.slate100,
              iconColor: AppColors.slate600,
              title: 'Use Master WebID',
              subtitle: 'Share your primary identity and root data pod.',
              borderColor: AppColors.slate200,
              onTap: () => _handleInstall('master'),
            ),
            const SizedBox(height: 16),

            // Isolated persona option
            _IdentityOption(
              icon: Icons.person_add_outlined,
              iconBg: AppColors.amber200,
              iconColor: AppColors.amber800,
              title: 'Generate Isolated Persona',
              subtitle:
                  'Create a fresh, context-specific WebID. Best for privacy.',
              titleColor: AppColors.amber900,
              subtitleColor: AppColors.amber700,
              borderColor: AppColors.amber300,
              backgroundColor: AppColors.amber50.withValues(alpha: 0.5),
              emphasized: true,
              onTap: _handleGeneratePersonaAndInstall,
            ),
            const SizedBox(height: 32),

            // Back button
            TextButton(
              onPressed: () => setState(() => _selectedApp = null),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.slate500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: const Text(
                '← Back to Repository',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// A card in the repository grid.
class _RepoAppCard extends StatefulWidget {
  final SolidApp app;
  final VoidCallback onTap;

  const _RepoAppCard({required this.app, required this.onTap});

  @override
  State<_RepoAppCard> createState() => _RepoAppCardState();
}

class _RepoAppCardState extends State<_RepoAppCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovering ? AppColors.amber400 : AppColors.slate200,
            ),
            boxShadow: _hovering
                ? const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _hovering ? AppColors.amber100 : AppColors.slate50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.app.icon,
                  size: 28,
                  color: _hovering ? AppColors.amber700 : AppColors.slate700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.app.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _hovering
                            ? AppColors.amber700
                            : AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.app.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A selectable identity option (Master / Isolated) in the app detail view.
class _IdentityOption extends StatefulWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color titleColor;
  final Color subtitleColor;
  final Color borderColor;
  final Color? backgroundColor;
  final bool emphasized;
  final VoidCallback onTap;

  const _IdentityOption({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.titleColor = AppColors.slate900,
    this.subtitleColor = AppColors.slate500,
    required this.borderColor,
    this.backgroundColor,
    this.emphasized = false,
    required this.onTap,
  });

  @override
  State<_IdentityOption> createState() => _IdentityOptionState();
}

class _IdentityOptionState extends State<_IdentityOption> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    Color bg = widget.backgroundColor ?? Colors.white;
    if (_hovering) {
      bg = widget.emphasized ? AppColors.amber100 : Colors.white;
    }
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.emphasized
                  ? widget.borderColor
                  : (_hovering ? AppColors.slate400 : widget.borderColor),
              width: widget.emphasized ? 2 : 1,
            ),
            boxShadow: _hovering
                ? const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 24, color: widget.iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
