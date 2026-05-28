import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/genshin_theme.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required: Please enter your email address.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format Error: Please enter a valid email format (e.g. traveler@teyvat.com)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required: Please enter your password.';
    }
    if (value.length < 4) {
      return 'Validation Failure: Password must be at least 4 characters.';
    }
    return null;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: GenshinTheme.accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: GenshinTheme.bgDark),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: GenshinTheme.bgDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDbLogin() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Client Validation Failure: Please check your input fields.');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else if (mounted) {
      _showErrorSnackBar(authProvider.errorMessage ?? 'Authentication Failed.');
    }
  }

  Future<void> _handleOAuthLogin(String provider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String email = provider == 'Google' ? 'paimon_google@traveler.com' : 'diluc_facebook@dawn.com';
    String name = provider == 'Google' ? 'Traveler Paimon' : 'Diluc Ragnvindr';

    final success = await authProvider.loginOAuth(provider, email, name);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else if (mounted) {
      _showErrorSnackBar(authProvider.errorMessage ?? 'OAuth Authentication Failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: GenshinTheme.mysticBackground,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: GenshinTheme.bgCard,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 55,
                        color: GenshinTheme.primaryGold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'GENSHIN IMPORT',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Premium Teyvat Armory & Relics Store',
                      style: GoogleFonts.cinzel(
                        fontSize: 13,
                        color: GenshinTheme.secondaryGold,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Card(
                    elevation: 12,
                    shadowColor: Colors.black54,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Enter Store Credentials',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'e.g. admin@genshin.com',
                              prefixIcon: Icon(Icons.email, color: GenshinTheme.primaryGold),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter password',
                              prefixIcon: Icon(Icons.lock, color: GenshinTheme.primaryGold),
                            ),
                            obscureText: true,
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 24),
                          authProvider.isLoading
                              ? const Center(child: CircularProgressIndicator(color: GenshinTheme.primaryGold))
                              : ElevatedButton(
                                  onPressed: _handleDbLogin,
                                  child: const Text('ENTER THE STORE'),
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFF334155), thickness: 1.5)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR LOG IN VIA OAUTH',
                          style: GoogleFonts.cinzel(
                            color: GenshinTheme.secondaryGold,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFF334155), thickness: 1.5)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA4335),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 2,
                        ).buildElevatedButton(
                          onPressed: () => _handleOAuthLogin('Google'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.g_mobiledata, size: 28, color: Colors.white),
                              SizedBox(width: 4),
                              Text('GOOGLE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1877F2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 2,
                        ).buildElevatedButton(
                          onPressed: () => _handleOAuthLogin('Facebook'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.facebook, size: 20, color: Colors.white),
                              SizedBox(width: 8),
                              Text('FACEBOOK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension StyledButton on ButtonStyle {
  Widget buildElevatedButton({required VoidCallback onPressed, required Widget child}) {
    return ElevatedButton(
      style: this,
      onPressed: onPressed,
      child: child,
    );
  }
}
