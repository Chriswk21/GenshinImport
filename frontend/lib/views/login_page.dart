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

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();

  bool _isLoginMode = true;
  bool _obscurePassword = true;
  bool _obscureRegPassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    _animController.reset();
    setState(() => _isLoginMode = !_isLoginMode);
    _animController.forward();
    Provider.of<AuthProvider>(context, listen: false).clearError();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required: Please enter your email address.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Invalid email format (e.g. traveler@teyvat.com)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required: Please enter your password.';
    }
    if (value.length < 4) {
      return 'Password must be at least 4 characters.';
    }
    return null;
  }

  String? _validateRegPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required: Please enter a password.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? GenshinTheme.accentRed : GenshinTheme.accentCyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: GenshinTheme.bgDark,
            ),
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

  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardPage()),
    );
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      _navigateToDashboard();
    } else if (mounted) {
      _showSnackBar(authProvider.errorMessage ?? 'Authentication Failed.');
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    if (_regPasswordController.text != _regConfirmPasswordController.text) {
      _showSnackBar('Passwords do not match. Please re-enter.');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      _regNameController.text.trim(),
      _regEmailController.text.trim(),
      _regPasswordController.text,
    );

    if (success && mounted) {
      _navigateToDashboard();
    } else if (mounted) {
      _showSnackBar(authProvider.errorMessage ?? 'Registration Failed.');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.loginWithGoogle();

    if (success && mounted) {
      _navigateToDashboard();
    } else if (mounted) {
      _showSnackBar(authProvider.errorMessage ?? 'Google Sign-In Failed.');
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: GenshinTheme.bgCard,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 50,
                      color: GenshinTheme.primaryGold,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    'GENSHIN IMPORT',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'Premium Teyvat Armory & Relics Store',
                    style: GoogleFonts.cinzel(
                      fontSize: 12,
                      color: GenshinTheme.secondaryGold,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: !_isLoginMode ? _toggleMode : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isLoginMode ? GenshinTheme.primaryGold : GenshinTheme.bgCard,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                            border: Border.all(
                              color: _isLoginMode ? GenshinTheme.secondaryGold : const Color(0xFF334155),
                            ),
                          ),
                          child: Text(
                            'LOGIN',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cinzel(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 1.2,
                              color: _isLoginMode ? GenshinTheme.bgDark : GenshinTheme.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _isLoginMode ? _toggleMode : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isLoginMode ? GenshinTheme.primaryGold : GenshinTheme.bgCard,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            border: Border.all(
                              color: !_isLoginMode ? GenshinTheme.secondaryGold : const Color(0xFF334155),
                            ),
                          ),
                          child: Text(
                            'REGISTER',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cinzel(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 1.2,
                              color: !_isLoginMode ? GenshinTheme.bgDark : GenshinTheme.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                FadeTransition(
                  opacity: _fadeAnim,
                  child: Card(
                    elevation: 12,
                    shadowColor: Colors.black54,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: _isLoginMode ? _buildLoginForm(authProvider) : _buildRegisterForm(authProvider),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _buildGoogleSignInButton(authProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthProvider authProvider) {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter Store Credentials',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter password',
              prefixIcon: const Icon(Icons.lock, color: GenshinTheme.primaryGold),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: GenshinTheme.textMuted,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            obscureText: _obscurePassword,
            validator: _validatePassword,
          ),
          const SizedBox(height: 22),
          authProvider.isLoading
              ? const Center(child: CircularProgressIndicator(color: GenshinTheme.primaryGold))
              : ElevatedButton(
                  onPressed: _handleLogin,
                  child: const Text('ENTER THE STORE'),
                ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(AuthProvider authProvider) {
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create New Account',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _regNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'e.g. Aether Traveler',
              prefixIcon: Icon(Icons.person, color: GenshinTheme.primaryGold),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Required: Name is required.';
              if (value.trim().length < 2) return 'Name must be at least 2 characters.';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _regEmailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              hintText: 'e.g. traveler@teyvat.com',
              prefixIcon: Icon(Icons.email, color: GenshinTheme.primaryGold),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _regPasswordController,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Min. 6 characters',
              prefixIcon: const Icon(Icons.lock, color: GenshinTheme.primaryGold),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureRegPassword ? Icons.visibility_off : Icons.visibility,
                  color: GenshinTheme.textMuted,
                ),
                onPressed: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
              ),
            ),
            obscureText: _obscureRegPassword,
            validator: _validateRegPassword,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _regConfirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter password',
              prefixIcon: const Icon(Icons.lock_outline, color: GenshinTheme.primaryGold),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: GenshinTheme.textMuted,
                ),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            obscureText: _obscureConfirmPassword,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required: Please confirm your password.';
              if (value != _regPasswordController.text) return 'Passwords do not match.';
              return null;
            },
          ),
          const SizedBox(height: 22),
          authProvider.isLoading
              ? const Center(child: CircularProgressIndicator(color: GenshinTheme.primaryGold))
              : ElevatedButton(
                  onPressed: _handleRegister,
                  child: const Text('CREATE ACCOUNT'),
                ),
        ],
      ),
    );
  }

  Widget _buildGoogleSignInButton(AuthProvider authProvider) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFF334155), thickness: 1.5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'OR CONTINUE WITH',
                style: GoogleFonts.cinzel(
                  color: GenshinTheme.secondaryGold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFF334155), thickness: 1.5)),
          ],
        ),
        const SizedBox(height: 14),
        authProvider.isLoading
            ? const SizedBox.shrink()
            : SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    side: const BorderSide(color: Color(0xFF4285F4), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _handleGoogleSignIn,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GoogleLogo(),
                      const SizedBox(width: 12),
                      Text(
                        'Continue with Google',
                        style: GoogleFonts.inter(
                          color: GenshinTheme.textParchment,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final segments = [
      (0.0, 90.0, const Color(0xFF4285F4)),
      (90.0, 90.0, const Color(0xFF34A853)),
      (180.0, 90.0, const Color(0xFFFBBC05)),
      (270.0, 90.0, const Color(0xFFEA4335)),
    ];

    for (final (startDeg, sweepDeg, color) in segments) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.22
        ..strokeCap = StrokeCap.butt;

      final startRad = startDeg * 3.14159265 / 180.0;
      final sweepRad = sweepDeg * 3.14159265 / 180.0;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.72),
        startRad,
        sweepRad,
        false,
        paint,
      );
    }

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - size.height * 0.13, radius * 0.9, size.height * 0.26),
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter oldDelegate) => false;
}
