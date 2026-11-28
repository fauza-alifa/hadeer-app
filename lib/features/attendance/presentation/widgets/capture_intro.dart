import 'package:flutter/material.dart';

class CaptureIntro extends StatelessWidget {
  const CaptureIntro({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Foto dulu, yuk.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
      SizedBox(height: 10),
      Text(
        'Pastikan wajahmu terlihat jelas. Cek fotonya sebelum dikirim. '
        'Jam absen dihitung saat server menerima kirimanmu, bukan saat foto diambil.',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.6),
      ),
      SizedBox(height: 24),
    ],
  );
}
