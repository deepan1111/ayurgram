import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  String? result;
  bool isStarted = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                return Icon(
                  state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                );
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.cameraFacingState,
              builder: (context, state, child) {
                return Icon(
                  state == CameraFacing.front
                      ? Icons.camera_front
                      : Icons.camera_rear,
                  color: Colors.white,
                );
              },
            ),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty && result == null) {
                      setState(() {
                        result = barcodes.first.rawValue;
                      });
                    }
                  },
                ),
                CustomPaint(
                  painter: ScannerOverlay(),
                  child: const SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                if (result == null)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Scanning...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (result != null)
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(16),
                color: Colors.grey[200],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Batch Information:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(result!),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              result = null;
                              controller.start();
                            });
                          },
                          child: Text('Scan Again'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, result);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[800],
                          ),
                          child: Text('Confirm'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final cutoutSize = size.width * 0.7;
    final cutoutPosition = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutoutSize,
      height: cutoutSize,
    );

    // Draw semi-transparent overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRect(cutoutPosition),
      ),
      Paint()..color = Colors.black54,
    );

    // Draw scanning area border
    canvas.drawRect(cutoutPosition, paint);

    // Draw corner markers
    final markerLength = cutoutSize * 0.1;
    final corners = [
      Offset(cutoutPosition.left, cutoutPosition.top), // Top-left
      Offset(cutoutPosition.right, cutoutPosition.top), // Top-right
      Offset(cutoutPosition.left, cutoutPosition.bottom), // Bottom-left
      Offset(cutoutPosition.right, cutoutPosition.bottom), // Bottom-right
    ];

    for (final corner in corners) {
      // Horizontal line
      canvas.drawLine(
        corner,
        Offset(
          corner.dx +
              (corner.dx == cutoutPosition.left ? markerLength : -markerLength),
          corner.dy,
        ),
        paint,
      );
      // Vertical line
      canvas.drawLine(
        corner,
        Offset(
          corner.dx,
          corner.dy +
              (corner.dy == cutoutPosition.top ? markerLength : -markerLength),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
