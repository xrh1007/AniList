import 'package:flutter/material.dart';

/// 可拖动的悬浮按钮
/// 短按触发 onTap；长按或移动超过阈值后进入拖动，松手吸附到最近的左右边缘
class DraggableFab extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const DraggableFab({super.key, required this.child, this.onTap});

  @override
  State<DraggableFab> createState() => _DraggableFabState();
}

class _DraggableFabState extends State<DraggableFab> {
  static const _fabSize = 56.0;
  static const _dragThreshold = 10.0; // 位移超过该值立即视为拖动

  Offset? _position; // FAB 中心点，null 表示尚未初始化
  bool _isDragging = false;
  Offset _accumulatedDelta = Offset.zero;

  void _onPanStart(DragStartDetails details) {
    _accumulatedDelta = Offset.zero;
    _isDragging = false;
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    _accumulatedDelta += details.delta;
    if (!_isDragging &&
        _accumulatedDelta.distance > _dragThreshold) {
      _isDragging = true;
    }
    if (_isDragging && _position != null) {
      setState(() {
        _position = Offset(
          (_position!.dx + details.delta.dx)
              .clamp(_fabSize / 2, size.width - _fabSize / 2),
          (_position!.dy + details.delta.dy)
              .clamp(_fabSize / 2, size.height - _fabSize / 2),
        );
      });
    }
  }

  void _onPanEnd(DragEndDetails details, Size size) {
    if (!_isDragging) {
      widget.onTap?.call();
      return;
    }
    // 吸附到最近的左右边缘
    setState(() {
      _position = Offset(
        _position!.dx < size.width / 2
            ? _fabSize / 2 + 8
            : size.width - _fabSize / 2 - 8,
        _position!.dy,
      );
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        // 初始位置：右下角
        _position ??= Offset(
          size.width - _fabSize / 2 - 16,
          size.height - _fabSize / 2 - 16,
        );
        return Stack(
          children: [
            Positioned(
              left: _position!.dx - _fabSize / 2,
              top: _position!.dy - _fabSize / 2,
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: (d) => _onPanUpdate(d, size),
                onPanEnd: (d) => _onPanEnd(d, size),
                onPanCancel: () => _isDragging = false,
                child: ScaleShadow(
                  dragging: _isDragging,
                  child: widget.child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 拖动时轻微放大并加深阴影，提供视觉反馈
class ScaleShadow extends StatelessWidget {
  final bool dragging;
  final Widget child;

  const ScaleShadow({super.key, required this.dragging, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: dragging ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dragging ? 0.35 : 0.2),
              blurRadius: dragging ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
