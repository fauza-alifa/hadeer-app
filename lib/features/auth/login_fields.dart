import 'package:flutter/material.dart';

class LoginFields extends StatefulWidget {
  const LoginFields({super.key, required this.email, required this.password});

  final TextEditingController email;
  final TextEditingController password;

  @override
  State<LoginFields> createState() => _LoginFieldsState();
}

class _LoginFieldsState extends State<LoginFields> {
  bool hidden = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: scheme.outlineVariant.withValues(alpha: 0.55),
      ),
    );

    return Column(
      children: [
        // Email field
        TextField(
          controller: widget.email,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.next,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: 'Email sekolah',
            labelStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            prefixIcon: Icon(
              Icons.email_outlined,
              size: 19,
              color: scheme.secondary,
            ),
            filled: true,
            fillColor: scheme.surface.withValues(alpha: 0.65),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: scheme.primary, width: 1.4),
            ),
          ),
        ),

        const SizedBox(height: 13),

        // Password field
        TextField(
          controller: widget.password,
          obscureText: hidden,
          autocorrect: false,
          enableSuggestions: false,
          autofillHints: const [AutofillHints.password],
          textInputAction: TextInputAction.done,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: 'Kata sandi',
            labelStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              size: 19,
              color: scheme.secondary,
            ),
            suffixIcon: IconButton(
              tooltip: hidden ? 'Lihat kata sandi' : 'Sembunyikan kata sandi',
              onPressed: () {
                setState(() => hidden = !hidden);
              },
              icon: Icon(
                hidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 19,
                color: scheme.onSurfaceVariant,
              ),
            ),
            filled: true,
            fillColor: scheme.surface.withValues(alpha: 0.65),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: scheme.primary, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
