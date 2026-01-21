import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  // Controller to manage flash, camera switching, etc.
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool _isProcessing = false; // Prevents double-scanning

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
          // 1. The Camera View
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              _handleScan(capture);
            },
          ),

          // 2. The Dark Overlay & Red Cutout
          CustomPaint(
            painter: ScannerOverlayPainter(borderColor: AppColors.primaryRed),
            child: Container(),
          ),

          // 3. UI Controls (Close & Flash)
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close Button
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),

                      // Flash (Torch) Button - FIXED for MobileScanner 5.x
                      ValueListenableBuilder<MobileScannerState>(
                        valueListenable: _controller,
                        builder: (context, state, child) {
                          // FIX: Removed 'isTorchAvailable' check as it doesn't exist in v5
                          if (!state.isInitialized) {
                            return const SizedBox.shrink();
                          }

                          return IconButton(
                            icon: Icon(
                              state.torchState == TorchState.on
                                  ? Icons.flash_on
                                  : Icons.flash_off,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () => _controller.toggleTorch(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  "Align QR code within the frame",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  height: 100,
                ), // Space to keep text above the bottom
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ⚡️ CORE LOGIC: Handle the scan
  void _handleScan(BarcodeCapture capture) async {
    if (_isProcessing) return; // Stop if we are already working

    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _isProcessing = true;
        });

        final String code = barcode.rawValue!;

        // Simulating a network call or validation
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          _showResultDialog(context, code);
        }
        break; // Only process the first valid code found
      }
    }
  }

  void _showResultDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          "Check-in Successful",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 10),
            Text(
              "Gym ID: $code",
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to Home
            },
            child: const Text(
              "Done",
              style: TextStyle(color: AppColors.primaryRed),
            ),
          ),
        ],
      ),
    );
  }
}

// 🎨 Custom Painter for the "Professional" dark overlay with rounded corners
class ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;

  ScannerOverlayPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.7); // Darkened background
    final width = size.width;
    final height = size.height;
    final scanAreaSize = 280.0;
    final left = (width - scanAreaSize) / 2;
    final top = (height - scanAreaSize) / 2;
    final rect = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // 1. Draw the darkened background (everything EXCEPT the center hole)
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, width, height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(20)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, paint);

    // 2. Draw the Red Corners (The cool bracket look)
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final cornerSize = 30.0;
    final radius = 20.0;

    // Top Left
    var path = Path()
      ..moveTo(left, top + cornerSize)
      ..lineTo(left, top + radius)
      ..quadraticBezierTo(left, top, left + radius, top)
      ..lineTo(left + cornerSize, top);
    canvas.drawPath(path, borderPaint);

    // Top Right
    path = Path()
      ..moveTo(left + scanAreaSize - cornerSize, top)
      ..lineTo(left + scanAreaSize - radius, top)
      ..quadraticBezierTo(
        left + scanAreaSize,
        top,
        left + scanAreaSize,
        top + radius,
      )
      ..lineTo(left + scanAreaSize, top + cornerSize);
    canvas.drawPath(path, borderPaint);

    // Bottom Left
    path = Path()
      ..moveTo(left, top + scanAreaSize - cornerSize)
      ..lineTo(left, top + scanAreaSize - radius)
      ..quadraticBezierTo(
        left,
        top + scanAreaSize,
        left + radius,
        top + scanAreaSize,
      )
      ..lineTo(left + cornerSize, top + scanAreaSize);
    canvas.drawPath(path, borderPaint);

    // Bottom Right
    path = Path()
      ..moveTo(left + scanAreaSize - cornerSize, top + scanAreaSize)
      ..lineTo(left + scanAreaSize - radius, top + scanAreaSize)
      ..quadraticBezierTo(
        left + scanAreaSize,
        top + scanAreaSize,
        left + scanAreaSize,
        top + scanAreaSize - radius,
      )
      ..lineTo(left + scanAreaSize, top + scanAreaSize - cornerSize);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
