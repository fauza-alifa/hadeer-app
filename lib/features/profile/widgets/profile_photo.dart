import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../attendance/data/camera_service.dart';
import '../profile_repository.dart';

class ProfilePhoto extends ConsumerStatefulWidget {
  const ProfilePhoto({super.key});

  @override
  ConsumerState<ProfilePhoto> createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends ConsumerState<ProfilePhoto> {
  bool busy = false;

  Future<void> change() async {
    setState(() => busy = true);

    try {
      final photo = await CameraService.capture(context);

      if (photo == null || !mounted) return;

      final save = await showDialog<bool>(
        context: context,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return AlertDialog(
            backgroundColor: isDark
                ? Color(0xFF1B332B)
                : Color(0xFFFAFBF9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              'Pakai foto ini?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            content: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.memory(photo, fit: BoxFit.cover),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Simpan'),
              ),
            ],
          );
        },
      );

      if (save != true || !mounted) return;

      await ref.read(profileRepositoryProvider).save(photo);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Foto profil belum tersimpan. Cek koneksi, lalu coba lagi.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = ref.watch(avatarProvider);
    final bytes = avatar.asData?.value;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final borderColor = isDark
        ? Color(0xFF53675B)
        : Color(0xFFD5DED2);

    final avatarBackground = isDark
        ? Color(0xFF263F33)
        : Color(0xFFE8EEE5);

    final accentColor = isDark
        ? Color(0xFFA8C5A9)
        : Color(0xFF183D32);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2),
          ),
          child: CircleAvatar(
            radius: 46,
            backgroundColor: avatarBackground,
            backgroundImage: bytes == null ? null : MemoryImage(bytes),
            child: bytes == null
                ? Icon(
                    Icons.person_outline_rounded,
                    size: 42,
                    color: accentColor,
                  )
                : null,
          ),
        ),

        SizedBox(height: 10),

        TextButton.icon(
          onPressed: busy || avatar.isLoading ? null : change,
          style: TextButton.styleFrom(
            foregroundColor: accentColor,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: busy
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.camera_alt_outlined, size: 17),
          label: Text(
            busy ? 'Menyimpan…' : 'Ganti foto',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),

        if (avatar.hasError)
          TextButton(
            onPressed: () => ref.invalidate(avatarProvider),
            child: Text(
              'Foto gagal dimuat · Coba lagi',
              style: TextStyle(fontSize: 11, color: scheme.error),
            ),
          ),
      ],
    );
  }
}
