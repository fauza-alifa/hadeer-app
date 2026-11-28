import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/surface_card.dart';
import '../data/camera_service.dart';
import 'providers.dart';
import 'widgets/photo_preview.dart';
import 'widgets/capture_intro.dart';

class CapturePage extends ConsumerStatefulWidget {
  const CapturePage({super.key});

  @override
  ConsumerState<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends ConsumerState<CapturePage> {
  Uint8List? photo;
  bool busy = false;
  String? error;

  Future<void> capture() async {
    setState(() {
      busy = true;
      error = null;
    });

    try {
      final bytes = await CameraService.capture(context);

      if (bytes == null) return;

      if (mounted) {
        setState(() => photo = bytes);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          error =
              'Kamera gagal atau foto melebihi 100 KB. '
              'Periksa izin kamera dan coba lagi.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  Future<void> submit() async {
    setState(() {
      busy = true;
      error = null;
    });

    try {
      await ref.read(repositoryProvider).submit(photo!);

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sudah masuk! Absensimu tersimpan.')),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          error =
              'Gagal menyimpan. Periksa koneksi; '
              'pastikan kamu belum absen hari ini.';
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
    final dark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !busy,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Check-in',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(24, 12, 24, 20),
                  children: [
                    CaptureIntro(),

                    SizedBox(height: 24),

                    Row(
                      children: [
                        Text(
                          'BUKTI KEHADIRAN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.3,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        Spacer(),
                        if (photo != null)
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: Color(0xFF78947B),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Foto siap',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF78947B),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                    SizedBox(height: 12),

                    SurfaceCard(
                      padding: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: PhotoPreview(photo: photo),
                      ),
                    ),

                    SizedBox(height: 14),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 17,
                          color: scheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'Pastikan wajah terlihat jelas dan '
                            'foto memiliki pencahayaan yang cukup.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (error != null) ...[
                      SizedBox(height: 18),
                      Container(
                        padding: EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: scheme.errorContainer.withValues(
                            alpha: dark ? 0.25 : 0.65,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: scheme.error,
                              size: 19,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                error!,
                                style: TextStyle(
                                  color: scheme.onErrorContainer,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 18),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: 0.45),
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: busy ? null : capture,
                        icon: Icon(
                          photo == null
                              ? Icons.camera_alt_outlined
                              : Icons.refresh_rounded,
                          size: 19,
                        ),
                        label: Text(
                          photo == null ? 'Buka kamera' : 'Ambil ulang',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: scheme.primary,
                          side: BorderSide(
                            color: scheme.primary.withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: busy || photo == null ? null : submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: dark
                              ? Color(0xFFA8C5A9)
                              : Color(0xFF183D32),
                          foregroundColor: dark
                              ? Color(0xFF102A23)
                              : Colors.white,
                          disabledBackgroundColor: scheme.onSurface.withValues(
                            alpha: 0.08,
                          ),
                          disabledForegroundColor: scheme.onSurface.withValues(
                            alpha: 0.35,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: busy
                            ? SizedBox(
                                width: 19,
                                height: 19,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Kirim kehadiran',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
