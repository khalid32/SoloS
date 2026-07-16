import 'package:flutter/material.dart';
import '../theme.dart';

/// Mirrors `Login.tsx`: the "Community Solid Server" styled login form.
/// On submit it derives a WebID from the email local-part and calls [onLogin].
class LoginScreen extends StatefulWidget {
  final void Function(String webId) onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _stayLoggedIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text;
    final username = email.split('@').first.isNotEmpty
        ? email.split('@').first
        : 'user';
    widget.onLogin('https://$username.solidcommunity.net/profile/card#me');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.loginBg,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448), // max-w-md
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo + title row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.amber600,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F000000),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.hexagon,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'SoloS',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: AppColors.slate800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      _isSignUp ? 'Create Account' : 'Log in',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate800,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email field
                    _buildLabel('Email'),
                    const SizedBox(height: 4),
                    _buildTextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Email is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    _buildLabel('Password'),
                    const SizedBox(height: 4),
                    _buildTextField(
                      controller: _passwordController,
                      obscureText: true,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Password is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Stay logged in (only on login)
                    if (!_isSignUp)
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _stayLoggedIn,
                              onChanged: (v) =>
                                  setState(() => _stayLoggedIn = v ?? false),
                              activeColor: AppColors.amber600,
                              side: const BorderSide(color: AppColors.slate300),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Stay logged in',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.slate700,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),

                    // Buttons
                    Row(
                      children: [
                        _SubmitButton(
                          label: _isSignUp ? 'Submit' : 'Log in',
                          onPressed: _handleSubmit,
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.slate600,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Footer links
                    _buildFooterLink(
                      '• ${_isSignUp ? 'Back to log in' : 'Sign up'}',
                      () => setState(() => _isSignUp = !_isSignUp),
                    ),
                    const SizedBox(height: 8),
                    _buildFooterLink('• Forgot password', () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.slate700,
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.slate900),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.slate300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.amber500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.amber700,
        ),
      ),
    );
  }
}

/// The primary submit button with hover feedback matching the React design
/// (`#D4A373` → `#c29262` on hover).
class _SubmitButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _SubmitButton({required this.label, required this.onPressed});

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: _hovering
                ? AppColors.loginButtonHover
                : AppColors.loginButton,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
