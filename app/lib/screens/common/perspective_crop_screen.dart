import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_document_scanner_platform_interface/flutter_document_scanner_platform_interface.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme.dart';

/// 4개 꼭지점과 4개 엣지를 자유롭게 조정할 수 있는 Perspective Crop 화면
class PerspectiveCropScreen extends StatefulWidget {
  final String imagePath;

  const PerspectiveCropScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<PerspectiveCropScreen> createState() => _PerspectiveCropScreenState();
}

class _PerspectiveCropScreenState extends State<PerspectiveCropScreen> {
  // 이미지 관련
  Uint8List? _imageBytes;
  Size? _imageSize;
  Size? _displaySize;
  Offset _imageOffset = Offset.zero;

  // 4개 꼭지점 (화면 좌표)
  Offset _topLeft = Offset.zero;
  Offset _topRight = Offset.zero;
  Offset _bottomLeft = Offset.zero;
  Offset _bottomRight = Offset.zero;

  // 드래그 상태
  bool _isProcessing = false;

  // 상수
  static const double _dotSize = 24.0;
  static const double _edgeHitArea = 32.0;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final file = File(widget.imagePath);
    final bytes = await file.readAsBytes();
    final decodedImage = await decodeImageFromList(bytes);

    setState(() {
      _imageBytes = bytes;
      _imageSize = Size(
        decodedImage.width.toDouble(),
        decodedImage.height.toDouble(),
      );
    });
  }

  void _initializeCorners(Size displaySize, Offset imageOffset) {
    if (_displaySize != null) return; // 이미 초기화됨

    _displaySize = displaySize;
    _imageOffset = imageOffset;

    // 이미지 영역의 10% 마진으로 초기 영역 설정
    final margin = min(displaySize.width, displaySize.height) * 0.1;

    _topLeft = imageOffset + Offset(margin, margin);
    _topRight = imageOffset + Offset(displaySize.width - margin, margin);
    _bottomLeft = imageOffset + Offset(margin, displaySize.height - margin);
    _bottomRight = imageOffset +
        Offset(displaySize.width - margin, displaySize.height - margin);
  }

  /// 화면 좌표를 이미지 좌표로 변환
  List<Point<double>> _getImagePoints() {
    if (_imageSize == null || _displaySize == null) return [];

    final scaleX = _imageSize!.width / _displaySize!.width;
    final scaleY = _imageSize!.height / _displaySize!.height;

    Point<double> toImagePoint(Offset screenPoint) {
      final relative = screenPoint - _imageOffset;
      return Point(relative.dx * scaleX, relative.dy * scaleY);
    }

    // 순서: topLeft, topRight, bottomRight, bottomLeft
    return [
      toImagePoint(_topLeft),
      toImagePoint(_topRight),
      toImagePoint(_bottomRight),
      toImagePoint(_bottomLeft),
    ];
  }

  Future<void> _cropImage() async {
    if (_imageBytes == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    // async gap 전에 navigator 캡처
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final points = _getImagePoints();
      final contour = Contour(points: points);

      final result =
          await FlutterDocumentScannerPlatform.instance.adjustingPerspective(
        byteData: _imageBytes!,
        contour: contour,
      );

      if (result != null && mounted) {
        // 임시 파일로 저장
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
            '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(result);

        navigator.pop(tempFile);
      } else {
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('이미지 처리에 실패했습니다')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// 꼭지점이 유효한 범위 내에 있는지 확인하고 조정
  Offset _clampPoint(Offset point) {
    final minX = _imageOffset.dx;
    final minY = _imageOffset.dy;
    final maxX = _imageOffset.dx + (_displaySize?.width ?? 0);
    final maxY = _imageOffset.dy + (_displaySize?.height ?? 0);

    return Offset(
      point.dx.clamp(minX, maxX),
      point.dy.clamp(minY, maxY),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(context.l10n.ocr_selectArea),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isProcessing ? null : _cropImage,
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    context.l10n.common_done,
                    style: TextStyle(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: _imageBytes == null
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                // 이미지 표시 영역 계산
                final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
                final imageAspect = _imageSize!.width / _imageSize!.height;
                final screenAspect = screenSize.width / screenSize.height;

                Size displaySize;
                Offset imageOffset;

                if (imageAspect > screenAspect) {
                  // 이미지가 더 넓음 - 너비에 맞춤
                  displaySize = Size(
                    screenSize.width,
                    screenSize.width / imageAspect,
                  );
                  imageOffset = Offset(
                    0,
                    (screenSize.height - displaySize.height) / 2,
                  );
                } else {
                  // 이미지가 더 높음 - 높이에 맞춤
                  displaySize = Size(
                    screenSize.height * imageAspect,
                    screenSize.height,
                  );
                  imageOffset = Offset(
                    (screenSize.width - displaySize.width) / 2,
                    0,
                  );
                }

                _initializeCorners(displaySize, imageOffset);

                return Stack(
                  children: [
                    // 이미지
                    Positioned(
                      left: imageOffset.dx,
                      top: imageOffset.dy,
                      width: displaySize.width,
                      height: displaySize.height,
                      child: Image.memory(
                        _imageBytes!,
                        fit: BoxFit.fill,
                      ),
                    ),

                    // 반투명 마스크
                    CustomPaint(
                      size: screenSize,
                      painter: _MaskPainter(
                        topLeft: _topLeft,
                        topRight: _topRight,
                        bottomLeft: _bottomLeft,
                        bottomRight: _bottomRight,
                        imageRect: Rect.fromLTWH(
                          imageOffset.dx,
                          imageOffset.dy,
                          displaySize.width,
                          displaySize.height,
                        ),
                      ),
                    ),

                    // 선택 영역 테두리
                    CustomPaint(
                      size: screenSize,
                      painter: _BorderPainter(
                        topLeft: _topLeft,
                        topRight: _topRight,
                        bottomLeft: _bottomLeft,
                        bottomRight: _bottomRight,
                        primaryColor: context.colors.primary,
                      ),
                    ),

                    // 엣지 드래그 영역 (상단)
                    _buildEdgeHandle(
                      start: _topLeft,
                      end: _topRight,
                      onDrag: (delta) {
                        setState(() {
                          _topLeft = _clampPoint(_topLeft + Offset(0, delta.dy));
                          _topRight = _clampPoint(_topRight + Offset(0, delta.dy));
                        });
                      },
                    ),

                    // 엣지 드래그 영역 (하단)
                    _buildEdgeHandle(
                      start: _bottomLeft,
                      end: _bottomRight,
                      onDrag: (delta) {
                        setState(() {
                          _bottomLeft = _clampPoint(_bottomLeft + Offset(0, delta.dy));
                          _bottomRight = _clampPoint(_bottomRight + Offset(0, delta.dy));
                        });
                      },
                    ),

                    // 엣지 드래그 영역 (왼쪽)
                    _buildEdgeHandle(
                      start: _topLeft,
                      end: _bottomLeft,
                      onDrag: (delta) {
                        setState(() {
                          _topLeft = _clampPoint(_topLeft + Offset(delta.dx, 0));
                          _bottomLeft = _clampPoint(_bottomLeft + Offset(delta.dx, 0));
                        });
                      },
                    ),

                    // 엣지 드래그 영역 (오른쪽)
                    _buildEdgeHandle(
                      start: _topRight,
                      end: _bottomRight,
                      onDrag: (delta) {
                        setState(() {
                          _topRight = _clampPoint(_topRight + Offset(delta.dx, 0));
                          _bottomRight = _clampPoint(_bottomRight + Offset(delta.dx, 0));
                        });
                      },
                    ),

                    // 꼭지점 핸들 (4개)
                    _buildCornerHandle(
                      position: _topLeft,
                      onDrag: (delta) {
                        setState(() {
                          _topLeft = _clampPoint(_topLeft + delta);
                        });
                      },
                    ),
                    _buildCornerHandle(
                      position: _topRight,
                      onDrag: (delta) {
                        setState(() {
                          _topRight = _clampPoint(_topRight + delta);
                        });
                      },
                    ),
                    _buildCornerHandle(
                      position: _bottomLeft,
                      onDrag: (delta) {
                        setState(() {
                          _bottomLeft = _clampPoint(_bottomLeft + delta);
                        });
                      },
                    ),
                    _buildCornerHandle(
                      position: _bottomRight,
                      onDrag: (delta) {
                        setState(() {
                          _bottomRight = _clampPoint(_bottomRight + delta);
                        });
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildCornerHandle({
    required Offset position,
    required Function(Offset) onDrag,
  }) {
    return Positioned(
      left: position.dx - _dotSize / 2,
      top: position.dy - _dotSize / 2,
      child: GestureDetector(
        onPanUpdate: (details) => onDrag(details.delta),
        child: Container(
          width: _dotSize,
          height: _dotSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: context.colors.primary,
              width: 3,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4D000000), // black with 0.3 opacity
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEdgeHandle({
    required Offset start,
    required Offset end,
    required Function(Offset) onDrag,
  }) {
    final center = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );

    final isHorizontal = (end.dx - start.dx).abs() > (end.dy - start.dy).abs();
    final length = (end - start).distance;

    return Positioned(
      left: isHorizontal ? start.dx : center.dx - _edgeHitArea / 2,
      top: isHorizontal ? center.dy - _edgeHitArea / 2 : start.dy,
      child: GestureDetector(
        onPanUpdate: (details) => onDrag(details.delta),
        child: Container(
          width: isHorizontal ? length : _edgeHitArea,
          height: isHorizontal ? _edgeHitArea : length,
          color: Colors.transparent,
        ),
      ),
    );
  }
}

/// 선택 영역 외부를 어둡게 처리하는 마스크
class _MaskPainter extends CustomPainter {
  final Offset topLeft;
  final Offset topRight;
  final Offset bottomLeft;
  final Offset bottomRight;
  final Rect imageRect;

  _MaskPainter({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.imageRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x80000000) // black with 0.5 opacity
      ..style = PaintingStyle.fill;

    // 전체 영역
    final fullPath = Path()..addRect(imageRect);

    // 선택 영역
    final selectionPath = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..close();

    // 전체에서 선택 영역을 제외
    final maskPath = Path.combine(
      PathOperation.difference,
      fullPath,
      selectionPath,
    );

    canvas.drawPath(maskPath, paint);
  }

  @override
  bool shouldRepaint(covariant _MaskPainter oldDelegate) {
    return topLeft != oldDelegate.topLeft ||
        topRight != oldDelegate.topRight ||
        bottomLeft != oldDelegate.bottomLeft ||
        bottomRight != oldDelegate.bottomRight;
  }
}

/// 선택 영역 테두리
class _BorderPainter extends CustomPainter {
  final Offset topLeft;
  final Offset topRight;
  final Offset bottomLeft;
  final Offset bottomRight;
  final Color primaryColor;

  _BorderPainter({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BorderPainter oldDelegate) {
    return topLeft != oldDelegate.topLeft ||
        topRight != oldDelegate.topRight ||
        bottomLeft != oldDelegate.bottomLeft ||
        bottomRight != oldDelegate.bottomRight;
  }
}
