import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_crop_image/flutter_crop_image.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const CropperExampleApp());
}

class CropperExampleApp extends StatelessWidget {
  const CropperExampleApp({super.key, this.initialImageBytes});

  final Uint8List? initialImageBytes;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Cropper Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F14),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF60A5FA),
          surface: Color(0xFF181824),
        ),
        useMaterial3: true,
      ),
      home: ExampleHomeScreen(initialImageBytes: initialImageBytes),
    );
  }
}

class ExampleHomeScreen extends StatefulWidget {
  const ExampleHomeScreen({super.key, this.initialImageBytes});

  final Uint8List? initialImageBytes;

  @override
  State<ExampleHomeScreen> createState() => _ExampleHomeScreenState();
}

class _ExampleHomeScreenState extends State<ExampleHomeScreen> {
  Uint8List? _demoImageBytes;
  Uint8List? _documentImageBytes;
  bool _isGenerating = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialImageBytes != null) {
      _demoImageBytes = widget.initialImageBytes;
      _generateAadharDocumentImage().then((_) {
        if (mounted) setState(() => _isGenerating = false);
      });
    } else {
      _generateAllDemoImages();
    }
  }

  Future<void> _generateAllDemoImages() async {
    await Future.wait([
      _generateDemoImage(),
      _generateAadharDocumentImage(),
    ]);
    if (mounted) {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  /// Generates a crisp high-res 1600x1200 test image in memory with gradients and shapes
  /// so the example app runs offline out-of-the-box on all platforms.
  Future<void> _generateDemoImage() async {
    const int width = 1600;
    const int height = 1200;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 1. Vibrant Gradient Background
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(width.toDouble(), height.toDouble()),
        const [
          Color(0xFF0F2027),
          Color(0xFF203A43),
          Color(0xFF2C5364),
          Color(0xFFE94560),
        ],
        [0.0, 0.4, 0.7, 1.0],
      );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      bgPaint,
    );

    // 2. Decorative geometric accents
    final circlePaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0;
    canvas.drawCircle(const Offset(400, 400), 280, circlePaint);
    canvas.drawCircle(const Offset(1200, 800), 320, circlePaint);

    final fillPaint = Paint()
      ..color = const Color(0x66FFB703)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(1100, 450), 160, fillPaint);

    // 3. Grid lines pattern
    final gridPaint = Paint()
      ..color = const Color(0x1AFFFFFF)
      ..strokeWidth = 2.0;
    for (double x = 0; x < width; x += 100) {
      canvas.drawLine(Offset(x, 0), Offset(x, height.toDouble()), gridPaint);
    }
    for (double y = 0; y < height; y += 100) {
      canvas.drawLine(Offset(0, y), Offset(width.toDouble(), y), gridPaint);
    }

    // 4. Header title text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'ADVANCED CROPPER\n1600 x 1200 High-Res Sample',
        style: TextStyle(
          color: Colors.white,
          fontSize: 64.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          height: 1.3,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: 1400);

    textPainter.paint(
      canvas,
      Offset((width - textPainter.width) / 2, 520),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(width, height);
    picture.dispose();

    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();
    _demoImageBytes = byteData!.buffer.asUint8List();
  }

  /// Generates a photorealistic 1600x1200 image of an Aadhar / ID card placed on a contrasting desk background.
  Future<void> _generateAadharDocumentImage() async {
    const int width = 1600;
    const int height = 1200;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 1. Dark office desk surface background
    final deskPaint = Paint()..color = const Color(0xFF1E212D);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 1600.0, 1200.0),
      deskPaint,
    );

    // Subtle table grain lines
    final grainPaint = Paint()
      ..color = const Color(0x15FFFFFF)
      ..strokeWidth = 3.0;
    for (double y = 0; y < height; y += 80) {
      canvas.drawLine(Offset(0, y), Offset(width.toDouble(), y), grainPaint);
    }

    // 2. ID Card / Aadhar Card bounding box (ISO/IEC 7810 ID-1 ratio = 1.586)
    // Card dimensions: 1000 x 630 px, centered at (300, 285)
    const cardRect = Rect.fromLTWH(300, 285, 1000, 630);
    final cardRRect =
        RRect.fromRectAndRadius(cardRect, const Radius.circular(24.0));

    // Card drop shadow
    final shadowPaint = Paint()
      ..color = const Color(0x88000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28.0);
    canvas.drawRRect(cardRRect.shift(const Offset(0, 16)), shadowPaint);

    // Card base (Crisp white / pearl card surface)
    final cardBgPaint = Paint()..color = const Color(0xFFF9FAFB);
    canvas.drawRRect(cardRRect, cardBgPaint);

    // Clip to card bounds for inner contents
    canvas.save();
    canvas.clipRRect(cardRRect);

    // 3. Official Tricolor Top Header Band
    final headerSaffron = Paint()..color = const Color(0xFFFF9933);
    final headerWhite = Paint()..color = Colors.white;
    final headerGreen = Paint()..color = const Color(0xFF138808);

    canvas.drawRect(const Rect.fromLTWH(300, 285, 1000, 20), headerSaffron);
    canvas.drawRect(const Rect.fromLTWH(300, 305, 1000, 20), headerWhite);
    canvas.drawRect(const Rect.fromLTWH(300, 325, 1000, 20), headerGreen);

    // Emblem / Logo placeholder
    final emblemPaint = Paint()
      ..color = const Color(0xFF000088)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(const Offset(355, 385), 24, emblemPaint);

    // Government / Header Title
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: 'GOVERNMENT OF INDIA\nUNIQUE IDENTIFICATION AUTHORITY',
        style: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
          height: 1.2,
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 700);
    titlePainter.paint(canvas, const Offset(395, 370));

    // 4. Portrait photo box on left
    const photoRect = Rect.fromLTWH(340, 460, 190, 240);
    final photoBorderPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    final photoBgPaint = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawRRect(
        RRect.fromRectAndRadius(photoRect, const Radius.circular(12)),
        photoBgPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(photoRect, const Radius.circular(12)),
        photoBorderPaint);

    // Head / silhouette icon
    final silhouettePaint = Paint()..color = const Color(0xFF94A3B8);
    canvas.drawCircle(const Offset(435, 535), 45, silhouettePaint);
    canvas.drawOval(const Rect.fromLTWH(370, 595, 130, 90), silhouettePaint);

    // 5. Personal Details (Name, DOB, Gender)
    final infoPainter = TextPainter(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'Name: Kishan Dobariya\n',
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A)),
          ),
          TextSpan(
            text: 'DOB: 15/08/1995\nGender: Male\n',
            style: TextStyle(
                fontSize: 22, height: 1.5, color: Color(0xFF334155)),
          ),
          TextSpan(
            text: 'Mobile: +91 90232 56218',
            style: TextStyle(fontSize: 20, color: Color(0xFF64748B)),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 500);
    infoPainter.paint(canvas, const Offset(570, 470));

    // 6. Large 12-Digit Aadhar Card Number
    final aadharNumPainter = TextPainter(
      text: const TextSpan(
        text: '9876   5432   1098',
        style: TextStyle(
          color: Color(0xFFB91C1C),
          fontSize: 38.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 4.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    aadharNumPainter.paint(canvas, const Offset(570, 630));

    // 7. QR Code square box at bottom right
    const qrRect = Rect.fromLTWH(1100, 680, 160, 160);
    final qrPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(qrRect, Paint()..color = const Color(0xFFF1F5F9));
    canvas.drawRect(
        qrRect,
        Paint()
          ..color = const Color(0xFF94A3B8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    for (int qy = 0; qy < 8; qy++) {
      for (int qx = 0; qx < 8; qx++) {
        if ((qx + qy) % 2 == 0 || (qx == 0 || qx == 7 || qy == 0 || qy == 7)) {
          canvas.drawRect(
            Rect.fromLTWH(1100 + qx * 20.0 + 3, 680 + qy * 20.0 + 3, 14, 14),
            qrPaint,
          );
        }
      }
    }

    // Official verification ribbon at bottom
    final bottomBarPaint = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawRect(const Rect.fromLTWH(300, 875, 1000, 40), bottomBarPaint);

    final footerPainter = TextPainter(
      text: const TextSpan(
        text:
            'UNIQUE IDENTIFICATION AUTHORITY OF INDIA  •  MERA AADHAAR, MERI PEHCHAAN',
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
            letterSpacing: 1.0),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    footerPainter.paint(canvas, const Offset(340, 887));

    canvas.restore();

    final picture = recorder.endRecording();
    final img = await picture.toImage(width, height);
    picture.dispose();

    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();

    _documentImageBytes = byteData!.buffer.asUint8List();
  }

  Future<void> _pickAndCropDocument(
    BuildContext context, {
    required ImageSource source,
  }) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: source);
      if (file == null || !context.mounted) return;

      final Uint8List bytes = await file.readAsBytes();
      if (!context.mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AutoDocumentCropScreen(
            initialImageBytes: bytes,
            isFromGallery: true,
            onCropped: (result) => _showResult(context, result),
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _showDocumentSourceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1E2D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Document for Auto-Crop',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Instant edge auto-detection for ID cards, receipts & documents',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white60,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0x263B82F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library_outlined,
                        color: Color(0xFF60A5FA)),
                  ),
                  title: const Text('Pick from Gallery',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: const Text(
                      'Choose your own Aadhar, PAN, or document photo',
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.white38),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickAndCropDocument(context, source: ImageSource.gallery);
                  },
                ),
                const Divider(color: Colors.white12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0x2610B981),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt_outlined,
                        color: Color(0xFF34D399)),
                  ),
                  title: const Text('Capture with Camera',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: const Text(
                      'Take a live photo of your ID card or document',
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.white38),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickAndCropDocument(context, source: ImageSource.camera);
                  },
                ),
                const Divider(color: Colors.white12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0x26F59E0B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.badge_outlined,
                        color: Color(0xFFFBBF24)),
                  ),
                  title: const Text('Simulated Aadhar Card (Sample)',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: const Text(
                      'Built-in offline sample card on contrasting desk surface',
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.white38),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AutoDocumentCropScreen(
                          initialImageBytes:
                              _documentImageBytes ?? _demoImageBytes!,
                          isFromGallery: false,
                          onCropped: (result) => _showResult(context, result),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showResult(BuildContext context, CropResult result) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1E2D),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cropped Result',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(maxHeight: 280),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(result.bytes),
                  ),
                ),
                const SizedBox(height: 16),
                _ResultRow(
                    label: 'Dimensions',
                    value: '${result.width} x ${result.height} px'),
                _ResultRow(
                    label: 'Format', value: result.format.name.toUpperCase()),
                _ResultRow(
                    label: 'File Size',
                    value:
                        '${(result.byteLength / 1024).toStringAsFixed(1)} KB'),
                _ResultRow(
                    label: 'Rotation', value: '${result.rotation.toInt()}°'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Cropper'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF181824),
      ),
      body: _isGenerating
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sample image preview banner
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                      image: DecorationImage(
                        image: MemoryImage(_demoImageBytes!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '1600 × 1200 In-Memory Texture',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'EXAMPLES & MODES',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _DemoTile(
                    title: '1. Basic Turnkey Cropper',
                    subtitle:
                        'Full turnkey UI with all default toolbar controls & aspect ratios.',
                    icon: Icons.crop,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AdvancedCropperView(
                          image: MemoryImage(_demoImageBytes!),
                          onCropped: (result) {
                            Navigator.of(context).pop();
                            _showResult(context, result);
                          },
                        ),
                      ),
                    ),
                  ),

                  _DemoTile(
                    title: '2. Circular Profile Crop',
                    subtitle:
                        'CropShape.circle with 1:1 square constraint for avatars.',
                    icon: Icons.account_circle_outlined,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AdvancedCropperView(
                          image: MemoryImage(_demoImageBytes!),
                          title: 'Crop Avatar',
                          configuration: CropperConfiguration.profilePhoto,
                          onCropped: (result) {
                            Navigator.of(context).pop();
                            _showResult(context, result);
                          },
                        ),
                      ),
                    ),
                  ),

                  _DemoTile(
                    title: '3. 16:9 Landscape / Thumbnail',
                    subtitle:
                        'Fixed 16:9 widescreen ratio with Rule of Thirds grid guides.',
                    icon: Icons.aspect_ratio,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AdvancedCropperView(
                          image: MemoryImage(_demoImageBytes!),
                          title: '16:9 Thumbnail',
                          configuration: CropperConfiguration.landscape16x9,
                          onCropped: (result) {
                            Navigator.of(context).pop();
                            _showResult(context, result);
                          },
                        ),
                      ),
                    ),
                  ),

                  _DemoTile(
                    title: '4. Custom Nord Theme',
                    subtitle:
                        'Complete theming override: background, border, handles, and grid colors.',
                    icon: Icons.palette_outlined,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AdvancedCropperView(
                          image: MemoryImage(_demoImageBytes!),
                          title: 'Nord Themed',
                          theme: CropperTheme.nord,
                          onCropped: (result) {
                            Navigator.of(context).pop();
                            _showResult(context, result);
                          },
                        ),
                      ),
                    ),
                  ),

                  _DemoTile(
                    title: '5. Custom Developer Controls',
                    subtitle:
                        'Replace toolbar with custom floating buttons and actions.',
                    icon: Icons.tune,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CustomControlsScreen(
                          imageBytes: _demoImageBytes!,
                          onCropped: (result) => _showResult(context, result),
                        ),
                      ),
                    ),
                  ),

                  _DemoTile(
                    title: '6. Headless Crop Engine',
                    subtitle:
                        'Bare AdvancedCropper embedded in a custom page with no default UI.',
                    icon: Icons.layers_outlined,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => HeadlessScreen(
                          imageBytes: _demoImageBytes!,
                          onCropped: (result) => _showResult(context, result),
                        ),
                      ),
                    ),
                  ),

                  _DemoTile(
                    title: '7. Auto Document Crop (Aadhar / ID Card)',
                    subtitle:
                        'Auto edge detection for gallery images, camera capture, or simulated Aadhar card.',
                    icon: Icons.document_scanner,
                    onTap: () => _showDocumentSourceSheet(context),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: const Color(0xFF181824),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF60A5FA), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

/// Demonstrates using custom developer-created controls with CropController.
class CustomControlsScreen extends StatefulWidget {
  const CustomControlsScreen({
    super.key,
    required this.imageBytes,
    required this.onCropped,
  });

  final Uint8List imageBytes;
  final ValueChanged<CropResult> onCropped;

  @override
  State<CustomControlsScreen> createState() => _CustomControlsScreenState();
}

class _CustomControlsScreenState extends State<CustomControlsScreen> {
  final CropController _controller = CropController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      appBar: AppBar(
        title: const Text('Custom Controls Demo'),
        backgroundColor: const Color(0xFF181824),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFF3B82F6)),
            onPressed: () async {
              final result = await _controller.crop();
              if (context.mounted) {
                Navigator.of(context).pop();
                widget.onCropped(result);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AdvancedCropper(
              image: MemoryImage(widget.imageBytes),
              controller: _controller,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF181824),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _controller.rotateLeft,
                  icon: const Icon(Icons.rotate_left),
                  label: const Text('Left'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _controller.rotateRight,
                  icon: const Icon(Icons.rotate_right),
                  label: const Text('Right'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _controller.reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Demonstrates pure headless cropping with zero default UI.
class HeadlessScreen extends StatefulWidget {
  const HeadlessScreen({
    super.key,
    required this.imageBytes,
    required this.onCropped,
  });

  final Uint8List imageBytes;
  final ValueChanged<CropResult> onCropped;

  @override
  State<HeadlessScreen> createState() => _HeadlessScreenState();
}

class _HeadlessScreenState extends State<HeadlessScreen> {
  final CropController _controller = CropController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AdvancedCropper(
            image: MemoryImage(widget.imageBytes),
            controller: _controller,
          ),
          Positioned(
            top: 48,
            left: 16,
            child: IconButton.filled(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            bottom: 32,
            right: 24,
            child: FloatingActionButton.extended(
              onPressed: () async {
                final result = await _controller.crop();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  widget.onCropped(result);
                }
              },
              icon: const Icon(Icons.crop),
              label: const Text('Export Crop'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dedicated Auto Document & ID Card Cropping Screen with built-in Gallery & Camera picker.
class AutoDocumentCropScreen extends StatefulWidget {
  const AutoDocumentCropScreen({
    super.key,
    required this.initialImageBytes,
    this.isFromGallery = false,
    required this.onCropped,
  });

  final Uint8List initialImageBytes;
  final bool isFromGallery;
  final ValueChanged<CropResult> onCropped;

  @override
  State<AutoDocumentCropScreen> createState() => _AutoDocumentCropScreenState();
}

class _AutoDocumentCropScreenState extends State<AutoDocumentCropScreen> {
  late Uint8List _imageBytes;
  int _imageKey = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _imageBytes = widget.initialImageBytes;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: source);
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageKey++;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      body: SafeArea(
        child: AdvancedCropperView(
          key: ValueKey(_imageKey),
          image: MemoryImage(_imageBytes),
          title: widget.isFromGallery
              ? 'Gallery Document'
              : 'Auto Crop Document',
          configuration: CropperConfiguration.idCard,
          onCropped: (result) {
            Navigator.of(context).pop();
            widget.onCropped(result);
          },
          topBarBuilder: (context, controller) {
            return Container(
              color: const Color(0xFF181824),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.isFromGallery
                          ? 'Gallery Document'
                          : 'Auto Crop Document',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo_library_outlined,
                        color: Color(0xFF60A5FA)),
                    tooltip: 'Pick from Gallery',
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined,
                        color: Color(0xFF34D399)),
                    tooltip: 'Capture Camera',
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  _isProcessing
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : TextButton(
                          onPressed: () async {
                            if (_isProcessing) return;
                            setState(() => _isProcessing = true);
                            try {
                              final res = await controller.crop();
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                widget.onCropped(res);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Crop failed: $e')),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isProcessing = false);
                              }
                            }
                          },
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              color: Color(0xFF3B82F6),
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

