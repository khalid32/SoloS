import 'package:flutter/material.dart';

import '../data.dart';
import '../models.dart';
import '../theme.dart';

/// A full-screen detail view for a single [Persona] (identity).
///
/// Opened from the WebID chip in the Dashboard header. Shows the identity's
/// profile (name, type, WebID, derived Pod root) and the list of installed
/// apps that run under this identity.
class PersonaDetailScreen extends StatelessWidget {
  final Persona persona;
  final List<InstalledApp> installedApps;

  const PersonaDetailScreen({
    super.key,
    required this.persona,
    required this.installedApps,
  });

  /// Derive the Pod root from the WebID, mirroring `AppRuntime`.
  String get _podRoot => persona.webId.replaceAll('profile/card#me', '');

  /// The installed apps bound to this identity.
  List<InstalledApp> get _appsForPersona =>
      installedApps.where((i) => i.personaId == persona.id).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileCard(),
                        const SizedBox(height: 32),
                        _buildAppsSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Top chrome bar with a back button, matching `AppRuntime`'s header.
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.slate200)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text(
              'Workspace',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.slate600,
              overlayColor: AppColors.slate100,
            ),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 24, color: AppColors.slate200),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              persona.username.isNotEmpty ? persona.username : persona.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The main profile card: avatar, name, type badge, and identity fields.
  Widget _buildProfileCard() {
    final isMaster = persona.isMaster;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar with initial.
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isMaster
                        ? const [AppColors.amber400, AppColors.amber600]
                        : const [AppColors.slate200, AppColors.slate400],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  persona.name.isNotEmpty
                      ? persona.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      persona.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildTypeBadge(isMaster),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildField('WebID', persona.webId, AppColors.slate800),
          const SizedBox(height: 16),
          _buildField('Pod Root', _podRoot, AppColors.amber700),
          const SizedBox(height: 16),
          _buildField(
            'Email',
            persona.email.isNotEmpty ? persona.email : '—',
            AppColors.slate800,
          ),
          const SizedBox(height: 16),
          _buildField(
            'Isolated',
            isMaster ? 'false' : 'true',
            const Color(0xFF2563EB), // blue-600
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(bool isMaster) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isMaster ? AppColors.amber100 : AppColors.slate100,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: isMaster ? AppColors.amber300 : AppColors.slate200,
        ),
      ),
      child: Text(
        isMaster ? 'MASTER ID' : 'ISOLATED ID',
        style: TextStyle(
          fontSize: 10,
          letterSpacing: 0.5,
          fontWeight: FontWeight.bold,
          color: isMaster ? AppColors.amber700 : AppColors.slate500,
        ),
      ),
    );
  }

  /// A labelled read-only identity field with a monospace value chip.
  Widget _buildField(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: AppColors.slate400,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.slate200),
          ),
          child: SelectableText(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Section listing the apps installed under this identity.
  Widget _buildAppsSection() {
    final apps = _appsForPersona;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Apps using this identity (${apps.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.slate800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        if (apps.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate200),
            ),
            child: const Text(
              'No apps are installed under this identity yet.',
              style: TextStyle(fontSize: 14, color: AppColors.slate500),
            ),
          )
        else
          for (final instance in apps)
            if (findAppById(instance.appId) != null)
              _buildAppRow(findAppById(instance.appId)!),
      ],
    );
  }

  Widget _buildAppRow(SolidApp app) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.slate100),
            ),
            child: Icon(app.icon, size: 22, color: AppColors.slate700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  app.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
