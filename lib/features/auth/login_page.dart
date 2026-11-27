import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_header.dart';
import 'login_fields.dart';
import 'auth_repository.dart';
import '../../core/surface_card.dart';
import '../../core/enter_motion.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool busy = false;
  String? error;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    setState(() {
      busy = true;
      error = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(email.text.trim(), password.text);
    } on FirebaseAuthException {
      if (mounted) {
        setState(() {
          error = 'Login gagal. Periksa akun dan koneksi kamu.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          error = 'Belum bisa masuk. Coba lagi.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: EnterMotion(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 56,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Login Header
                          const LoginHeader(),

                          const SizedBox(height: 8),

                          // Login Form
                          SurfaceCard(
                            padding: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                LoginFields(email: email, password: password),

                                // Error Message
                                if (error != null) ...[
                                  const SizedBox(height: 16),
                                  _buildErrorMessage(scheme),
                                ],

                                const SizedBox(height: 20),

                                // Login Button
                                SizedBox(
                                  height: 52,
                                  child: OutlinedButton(
                                    onPressed: busy ? null : login,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: scheme.primary,
                                      disabledForegroundColor:
                                          scheme.onSurfaceVariant,
                                      side: BorderSide(
                                        color: busy
                                            ? scheme.outlineVariant
                                            : scheme.primary,
                                        width: 1.2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                    ),
                                    child: busy
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: scheme.primary,
                                            ),
                                          )
                                        : const Text(
                                            'Masuk',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Registration Information
                          Text(
                            'Belum punya akun? Minta ke admin sekolah, ya.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.6,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.error.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.error.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: scheme.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error!,
              style: TextStyle(fontSize: 12, height: 1.5, color: scheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
