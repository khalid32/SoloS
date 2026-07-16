import 'package:flutter/material.dart';

import '../data.dart';
import '../models.dart';
import '../theme.dart';
import 'app_runtime.dart';
import 'repository.dart';

/// Mirrors `Dashboard.tsx`: the workspace header, the grid of installed apps
/// plus an "Add App" tile, and navigation into the Repository / AppRuntime.
class DashboardScreen extends StatelessWidget {
  final Persona currentUser;
  final List<Persona> personas;
  final void Function(List<Persona>) setPersonas;
  final List<InstalledApp> installedApps;
  final void Function(List<InstalledApp>) setInstalledApps;
  final VoidCallback onLogout;

  const DashboardScreen({
    super.key,
    required this.currentUser,
    required this.personas,
    required this.setPersonas,
    required this.installedApps,
    required this.setInstalledApps,
    required this.onLogout,
  });

  void _openRepository(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: const Color(0x99334155), // slate-900/60 + blur feel
      builder: (_) => RepositoryModal(
        personas: personas,
        setPersonas: setPersonas,
        installedApps: installedApps,
        setInstalledApps: setInstalledApps,
      ),
    );
  }

  void _openApp(BuildContext context, InstalledApp instance) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppRuntimeScreen(
          instance: instance,
          personas: personas,
        ),
      ),
    );
  }

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
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'Welcome to your Solid OS',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your decentralized workspace. Add apps to get started.',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.slate500,
                          ),
                        ),
                        const SizedBox(height: 48),
                        _buildAppGrid(context),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo + name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.slate900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'SoloS Workspace',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          // WebID chip + logout
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_outline,
                        size: 16, color: AppColors.slate600),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Text(
                        currentUser.webId,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                tooltip: 'Log out',
                onPressed: onLogout,
                icon: const Icon(Icons.logout, size: 20),
                color: AppColors.slate500,
                hoverColor: AppColors.slate100,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppGrid(BuildContext context) {
    // Responsive column count mirroring the Tailwind breakpoints
    // (2 / 3 / 4 / 5 columns).
    final width = MediaQuery.of(context).size.width;
    int columns;
    if (width >= 1024) {
      columns = 5;
    } else if (width >= 768) {
      columns = 4;
    } else if (width >= 640) {
      columns = 3;
    } else {
      columns = 2;
    }

    final tiles = <Widget>[
      for (final instance in installedApps)
        if (findAppById(instance.appId) != null)
          _InstalledAppTile(
            app: findAppById(instance.appId)!,
            persona: _findPersona(instance.personaId),
            onTap: () => _openApp(context, instance),
          ),
      _AddAppTile(onTap: () => _openRepository(context)),
    ];

    return GridView.count(
      crossAxisCount: columns,
      mainAxisSpacing: 24,
      crossAxisSpacing: 24,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: tiles,
    );
  }

  Persona? _findPersona(String id) {
    for (final p in personas) {
      if (p.id == id) return p;
    }
    return null;
  }
}

/// A single installed-app tile on the workspace canvas.
class _InstalledAppTile extends StatefulWidget {
  final SolidApp app;
  final Persona? persona;
  final VoidCallback onTap;

  const _InstalledAppTile({
    required this.app,
    required this.persona,
    required this.onTap,
  });

  @override
  State<_InstalledAppTile> createState() => _InstalledAppTileState();
}

class _InstalledAppTileState extends State<_InstalledAppTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isMaster = widget.persona?.isMaster ?? false;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovering ? AppColors.amber300 : AppColors.slate200,
            ),
            boxShadow: _hovering
                ? const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _hovering ? AppColors.amber50 : AppColors.slate50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate100),
                ),
                child: Icon(
                  widget.app.icon,
                  size: 32,
                  color: _hovering ? AppColors.amber600 : AppColors.slate700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.app.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _hovering ? AppColors.amber100 : AppColors.slate100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isMaster ? 'MASTER ID' : 'ISOLATED ID',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.bold,
                    color: _hovering ? AppColors.amber700 : AppColors.slate500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The dashed "Add App" tile that opens the Repository.
class _AddAppTile extends StatefulWidget {
  final VoidCallback onTap;

  const _AddAppTile({required this.onTap});

  @override
  State<_AddAppTile> createState() => _AddAppTileState();
}

class _AddAppTileState extends State<_AddAppTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final accent = _hovering ? AppColors.amber700 : AppColors.slate500;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: DottedBorderBox(
          color: _hovering ? AppColors.amber400 : AppColors.slate300,
          backgroundColor:
              _hovering ? AppColors.amber50.withValues(alpha: 0.5) : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _hovering ? AppColors.amber100 : AppColors.slate50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, size: 32, color: accent),
              ),
              const SizedBox(height: 12),
              Text(
                'Add App',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A rounded rectangle with a dashed border, replicating Tailwind's
/// `border-2 border-dashed rounded-2xl`.
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color? backgroundColor;

  const DottedBorderBox({
    super.key,
    required this.child,
    required this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color, radius: 16),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Center(child: child),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
