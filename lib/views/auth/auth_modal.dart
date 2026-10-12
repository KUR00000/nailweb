import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../orders/order_history_modal.dart';

/// Modal dialog providing Supabase Email Authentication (Sign In, Sign Up, and VIP Demo Mode).
class AuthModal extends StatefulWidget {
  const AuthModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => const AuthModal(),
    );
  }

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _signInEmailController = TextEditingController(text: 'cutie@ivorynails.com');
  final _signInPasswordController = TextEditingController(text: 'secret123');

  final _signUpNameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();

  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn(AuthProvider auth) async {
    if (!_signInFormKey.currentState!.validate()) return;
    final success = await auth.signIn(
      _signInEmailController.text.trim(),
      _signInPasswordController.text.trim(),
    );
    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${auth.userName}.'),
          backgroundColor: AppTheme.charcoalNoir,
        ),
      );
    }
  }

  Future<void> _handleSignUp(AuthProvider auth) async {
    if (!_signUpFormKey.currentState!.validate()) return;
    final success = await auth.signUp(
      _signUpEmailController.text.trim(),
      _signUpPasswordController.text.trim(),
      fullName: _signUpNameController.text.trim(),
    );
    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome to the Atelier, ${auth.userName}.'),
          backgroundColor: AppTheme.charcoalNoir,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Dialog(
      backgroundColor: AppTheme.pureWhite,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: auth.isAuthenticated ? _buildLoggedInView(context, auth) : _buildAuthFormView(context, auth),
      ),
    );
  }

  Widget _buildLoggedInView(BuildContext context, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Atelier Account',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // User Avatar Monogram
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.blush200, AppTheme.blush100],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.blush300),
            ),
            child: Center(
              child: Text(
                auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Playfair Display',
                  color: AppTheme.charcoalNoir,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            auth.userName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.charcoalNoir),
          ),
          const SizedBox(height: 4),
          Text(
            auth.userEmail,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 10),

          // VIP Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.goldAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium, size: 14, color: AppTheme.goldAccent),
                SizedBox(width: 4),
                Text(
                  'PRINCESS VIP MEMBER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppTheme.goldAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // View Orders Action
          ListTile(
            onTap: () {
              Navigator.of(context).pop();
              OrderHistoryModal.show(context);
            },
            leading: const Icon(Icons.receipt_long_outlined, color: AppTheme.dustyRose),
            title: const Text('My Orders & Receipts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            trailing: const Icon(Icons.chevron_right, size: 18),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),

          // Sign Out Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await auth.signOut();
                if (context.mounted) Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorCrimson,
                side: BorderSide(color: AppTheme.errorCrimson.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthFormView(BuildContext context, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ivory Nails Atelier',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Text(
                    'Supabase Email Authentication',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tab Bar
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.ivoryGround,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.delicateBorder),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              labelColor: AppTheme.charcoalNoir,
              unselectedLabelColor: AppTheme.textMuted,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: 'Sign In'),
                Tab(text: 'Create Account'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Error Message Display
          if (auth.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.errorCrimson.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.errorCrimson.withValues(alpha: 0.2)),
              ),
              child: Text(
                auth.errorMessage!,
                style: const TextStyle(color: AppTheme.errorCrimson, fontSize: 11),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Tab Views
          SizedBox(
            height: 250,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Sign In Tab
                Form(
                  key: _signInFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _signInEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined, size: 18),
                        ),
                        validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _signInPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline, size: 18),
                        ),
                        validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : () => _handleSignIn(auth),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.charcoalNoir,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Sign In with Supabase'),
                        ),
                      ),
                    ],
                  ),
                ),

                // Sign Up Tab
                Form(
                  key: _signUpFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _signUpNameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline, size: 18),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Name required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _signUpEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined, size: 18),
                        ),
                        validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _signUpPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline, size: 18),
                        ),
                        validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : () => _handleSignUp(auth),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.charcoalNoir,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Create Supabase Account'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // Google OAuth Sign-In Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: auth.isLoading
                  ? null
                  : () async {
                      final success = await auth.signInWithGoogle();
                      if (success && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
              icon: const Icon(Icons.g_mobiledata, size: 22, color: AppTheme.charcoalNoir),
              label: const Text('Continue with Google'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.delicateBorder),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Instant Demo VIP Toggle Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await auth.signInAsDemoVip();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('👑 Switched to Logged-in Mode (Princess VIP)!'),
                      backgroundColor: AppTheme.charcoalNoir,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.auto_awesome, size: 16, color: AppTheme.dustyRose),
              label: const Text('1-Click Demo Login (Princess VIP)'),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppTheme.blush50,
                side: const BorderSide(color: AppTheme.blush300),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
