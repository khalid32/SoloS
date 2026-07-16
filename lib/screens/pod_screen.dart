import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:solidpod/solidpod.dart'
    show
        AccessForbiddenException,
        NotLoggedInException,
        ResourceNotExistException;

import '../solid/solid_service.dart';
import '../theme.dart';

/// Real Solid Protocol integration screen.
///
/// Connects to a Community Solid Server (CSS) via Solid-OIDC, then writes a
/// note to the user's Pod and reads it back — demonstrating genuine read AND
/// write access to a Solid Pod.
class PodScreen extends StatefulWidget {
  const PodScreen({super.key});

  @override
  State<PodScreen> createState() => _PodScreenState();
}

class _PodScreenState extends State<PodScreen> {
  final _serverController =
      TextEditingController(text: SolidConfig.defaultServer);
  final _noteController = TextEditingController();

  bool _checking = true;
  bool _busy = false;
  bool _loggedIn = false;
  String? _webId;
  String? _readContent;
  String? _status;
  bool _statusIsError = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _serverController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await SolidService.init();
    await _refreshSession();
    if (mounted) setState(() => _checking = false);
  }

  Future<void> _refreshSession() async {
    final loggedIn = await SolidService.isLoggedIn();
    final webId = loggedIn ? await SolidService.currentWebId() : null;
    if (!mounted) return;
    setState(() {
      _loggedIn = loggedIn;
      _webId = webId;
    });
  }

  void _setStatus(String message, {bool error = false}) {
    if (!mounted) return;
    setState(() {
      _status = message;
      _statusIsError = error;
    });
  }

  Future<void> _connect() async {
    final server = _serverController.text.trim();
    if (server.isEmpty) {
      _setStatus('Enter your Solid server or WebID first.', error: true);
      return;
    }
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final webId = await SolidService.connect(context, server);
      await _refreshSession();
      if (webId != null) {
        _setStatus('Connected to your Pod.');
      } else {
        _setStatus('Login was cancelled or failed.', error: true);
      }
    } on Object catch (e) {
      _setStatus('Login error: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveNote() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final payload = jsonEncode({
        'text': _noteController.text,
        'savedAt': DateTime.now().toIso8601String(),
        'app': 'SoloS',
      });
      await SolidService.saveNote(payload);
      _setStatus('Saved to your Pod (${SolidConfig.noteFile}).');
    } on NotLoggedInException {
      _setStatus('You must connect to your Pod first.', error: true);
      await _refreshSession();
    } on AccessForbiddenException {
      _setStatus('Write access to your Pod was forbidden.', error: true);
    } on Object catch (e) {
      _setStatus('Save failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _readNote() async {
    setState(() {
      _busy = true;
      _status = null;
      _readContent = null;
    });
    try {
      final raw = await SolidService.readNote();
      String display = raw;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map && decoded['text'] is String) {
          final savedAt = decoded['savedAt'];
          display = '${decoded['text']}'
              '${savedAt != null ? '\n\n(saved $savedAt)' : ''}';
        }
      } on Object {
        // Not our JSON shape; show the raw content as-is.
      }
      if (!mounted) return;
      setState(() => _readContent = display);
      _setStatus('Read from your Pod.');
    } on NotLoggedInException {
      _setStatus('You must connect to your Pod first.', error: true);
      await _refreshSession();
    } on ResourceNotExistException {
      _setStatus('No note saved on your Pod yet — save one first.',
          error: true);
    } on Object catch (e) {
      _setStatus('Read failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disconnect() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      await SolidService.disconnect();
      await _refreshSession();
      if (mounted) setState(() => _readContent = null);
      _setStatus('Disconnected from your Pod.');
    } on Object catch (e) {
      _setStatus('Logout error: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _checking
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.amber500),
                  )
                : SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildConnectionCard(),
                              const SizedBox(height: 24),
                              _buildReadWriteCard(),
                              if (_status != null) ...[
                                const SizedBox(height: 20),
                                _buildStatusBanner(),
                              ],
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

  Widget _buildHeader() {
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
          const Icon(Icons.cloud_outlined, size: 20, color: AppColors.amber600),
          const SizedBox(width: 8),
          const Text(
            'My Solid Pod',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _loggedIn ? AppColors.green500 : AppColors.slate300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _loggedIn ? 'Connected' : 'Not connected',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _loggedIn ? AppColors.green800 : AppColors.slate600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loggedIn) ...[
            _fieldLabel('WEBID'),
            const SizedBox(height: 6),
            _valueBox(_webId ?? '—'),
            const SizedBox(height: 20),
            _SolidButton(
              label: 'Disconnect',
              icon: Icons.logout,
              onPressed: _busy ? null : _disconnect,
              filled: false,
            ),
          ] else ...[
            _fieldLabel('SOLID SERVER OR WEBID'),
            const SizedBox(height: 6),
            _textField(_serverController, hint: SolidConfig.defaultServer),
            const SizedBox(height: 20),
            _SolidButton(
              label: 'Connect to your Pod',
              icon: Icons.login,
              onPressed: _busy ? null : _connect,
            ),
            const SizedBox(height: 8),
            const Text(
              'Opens the Community Solid Server login in your browser.',
              style: TextStyle(fontSize: 13, color: AppColors.slate500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReadWriteCard() {
    final enabled = _loggedIn && !_busy;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pod data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.slate800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Write a note to your Pod, then read it back.',
            style: TextStyle(fontSize: 13, color: AppColors.slate500),
          ),
          const SizedBox(height: 16),
          _fieldLabel('NOTE'),
          const SizedBox(height: 6),
          _textField(
            _noteController,
            hint: 'Type something to store on your Pod…',
            enabled: enabled,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SolidButton(
                label: 'Save to Pod',
                icon: Icons.cloud_upload_outlined,
                onPressed: enabled ? _saveNote : null,
              ),
              const SizedBox(width: 12),
              _SolidButton(
                label: 'Read from Pod',
                icon: Icons.cloud_download_outlined,
                onPressed: enabled ? _readNote : null,
                filled: false,
              ),
            ],
          ),
          if (_readContent != null) ...[
            const SizedBox(height: 20),
            _fieldLabel('CONTENT ON POD'),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.slate900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                _readContent!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.green400,
                ),
              ),
            ),
          ],
          if (!_loggedIn) ...[
            const SizedBox(height: 12),
            const Text(
              'Connect to your Pod above to enable read/write.',
              style: TextStyle(fontSize: 13, color: AppColors.slate400),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    final color = _statusIsError ? Colors.redAccent : AppColors.green500;
    final bg = _statusIsError
        ? const Color(0x14FF5252)
        : AppColors.green500.withValues(alpha: 0.08);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _statusIsError ? Icons.error_outline : Icons.check_circle_outline,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _status!,
              style: TextStyle(
                fontSize: 13,
                color: _statusIsError
                    ? const Color(0xFFB91C1C)
                    : AppColors.green800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- small UI helpers ----

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.slate200),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: child,
      );

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: AppColors.slate400,
        ),
      );

  Widget _valueBox(String value) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.slate50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.slate200),
        ),
        child: SelectableText(
          value,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: AppColors.slate800,
          ),
        ),
      );

  Widget _textField(
    TextEditingController controller, {
    String? hint,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.slate900, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.slate400),
        filled: true,
        fillColor: enabled ? Colors.white : AppColors.slate50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.slate300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.amber500, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
      ),
    );
  }
}

/// A small filled/outlined action button matching the SoloS palette.
class _SolidButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;

  const _SolidButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    if (filled) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amber600,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.slate200,
          disabledForegroundColor: AppColors.slate400,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: disabled ? AppColors.slate400 : AppColors.slate700,
        side: BorderSide(
          color: disabled ? AppColors.slate200 : AppColors.slate300,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
