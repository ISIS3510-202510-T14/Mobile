import 'package:flutter/material.dart';
import 'theme/spacing.dart'; // Where we defined AppSpacing
// If your design system files are in different paths, adjust imports accordingly.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  // For a subtle fade when toggling the icon, we can use AnimatedSwitcher or AnimatedCrossFade.
  // We'll use AnimatedSwitcher below.

  // For subtle screen transition/animation, we rely on Material route transitions by default
  // or you can implement your own. We'll do a small fade-in in build() using an AnimationController
  // if desired. (Optional step, but let's keep it simple for this example.)

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Start the fade animation when the screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the theme for styles
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      // Because we're using a dark theme, scaffold background is dark by default
      body: FadeTransition(
        opacity: _fadeAnimation,
        // The entire screen body subtly fades in
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1) LOGO or DUMMY IMAGE
                // Replace with your actual asset or network image.
                // E.g., if you have an assets/logo.png, you can use Image.asset('assets/logo.png').
                // We'll just use a placeholder container here.
                Container(
                  height: 100,
                  width: 100,
                  margin: const EdgeInsets.only(bottom: AppSpacing.l),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'Logo',
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),

                // 2) EMAIL TEXT FIELD
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                  ),
                ),

                SizedBox(height: AppSpacing.m),

                // 3) PASSWORD TEXT FIELD with Toggle Icon
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    suffixIcon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: IconButton(
                        key: ValueKey<bool>(_obscurePassword),
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.l),

                // 4) SIGN IN BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleSignIn,
                    child: const Text('Sign In'),
                  ),
                ),

                SizedBox(height: AppSpacing.m),

                // 5) "Not registered? Sign up."
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not registered?",
                      style: textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _handleSignUp,
                      child: const Text('Sign up.'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignIn() {
    // Implement your sign-in logic here
    // e.g. call an auth service, then navigate to home, etc.
    debugPrint('Signing in with email: ${_emailController.text}, password: ${_passwordController.text}');
  }

  void _handleSignUp() {
    // Implement sign-up navigation or open a sign-up screen
    debugPrint('Navigate to Sign Up screen');
  }
}
