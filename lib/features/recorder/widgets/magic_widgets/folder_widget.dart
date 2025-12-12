import 'dart:math' as math;
import 'package:flutter/material.dart';

class FolderButton extends StatefulWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String label;

  const FolderButton({
    super.key,
    this.onTap,
    this.onLongPress,
    this.label = 'Choose a file',
  });

  @override
  State<FolderButton> createState() => _FolderButtonState();
}

class _FolderButtonState extends State<FolderButton>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _hoverController;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    // Floating animation (up and down)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1, milliseconds: 500),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Hover animation (folder opening)
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _hoverAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic sizing similar to AllRecordsPage
    final size = MediaQuery.of(context).size;
    final double refSize = size.shortestSide.clamp(0.0, 500.0);

    // Scaling factors based on original 120x80 design relative to a ~400px screen
    final double folderW = refSize * 0.26; // Approx 120 if refSize is 400
    final double folderH = refSize * 0.14; // Approx 80 if refSize is 400

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedBuilder(
          animation: Listenable.merge([_hoverAnimation, _floatAnimation]),
          builder: (context, child) {
            // Hover scale effect from .folder:hover -> scale(1.05)
            // CSS: .container:hover .back-side::before -> rotateX(-5deg) skewX(5deg)
            // CSS: .container:hover .back-side::after -> rotateX(-15deg) skewX(12deg)
            // CSS: .container:hover .front-side -> rotateX(-40deg) skewX(15deg)

            final hoverValue = _hoverAnimation.value;
            final floatY = _floatAnimation.value;

            return Container(
              width: folderW * 1.5, // Approx container width padding
              height:
                  folderH * 1.5 +
                  (refSize * 0.05), // Reduced height multiplier from 1.7 to 1.5
              padding: EdgeInsets.all(refSize * 0.025),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6dd5ed), Color(0xFF2193b0)],
                ),
                borderRadius: BorderRadius.circular(refSize * 0.0375),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: refSize * 0.075,
                    offset: Offset(0, refSize * 0.0375),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // Floating Folder Area
                  Positioned(
                    top: -refSize * 0.04, // Adjusted top offset dynamically
                    child: Transform.translate(
                      offset: Offset(0, floatY),
                      child: Transform.scale(
                        scale: 1.0 + (0.05 * hoverValue), // Scale 1.05 on hover
                        child: SizedBox(
                          width: folderW,
                          height: folderH,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.bottomCenter,
                            children: [
                              // Back Side (Base)
                              _buildBackSide(folderW, folderH, refSize),

                              // Papers (Pseudo elements in CSS)
                              // Paper 1 (::before)
                              _buildPaper(
                                folderW,
                                folderH,
                                refSize,
                                rotateXDeg: -5 * hoverValue,
                                skewXDeg: 5 * hoverValue,
                              ),
                              // Paper 2 (::after)
                              _buildPaper(
                                folderW,
                                folderH,
                                refSize,
                                rotateXDeg: -15 * hoverValue,
                                skewXDeg: 12 * hoverValue,
                              ),

                              // Front Side (Tip + Cover)
                              _buildFrontSide(
                                folderW,
                                folderH,
                                hoverValue,
                                refSize,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Button Label
                  _buildLabel(hoverValue, refSize),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackSide(double w, double h, double refSize) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFffc663).withValues(alpha: 0.5), // Fallback color
        borderRadius: BorderRadius.circular(refSize * 0.0375),
      ),
    );
  }

  Widget _buildPaper(
    double w,
    double h,
    double refSize, {
    required double rotateXDeg,
    required double skewXDeg,
  }) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // Perspective
        ..rotateX(rotateXDeg * math.pi / 180)
        ..setEntry(0, 1, math.tan(skewXDeg * math.pi / 180)),
      alignment: Alignment.bottomCenter,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(refSize * 0.0375),
        ),
      ),
    );
  }

  Widget _buildFrontSide(
    double w,
    double h,
    double hoverValue,
    double refSize,
  ) {
    // Front side rotation: -40deg skewX 15deg on hover
    final rotateX = -40.0 * hoverValue;
    final skewX = 15.0 * hoverValue;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(rotateX * math.pi / 180)
        ..setEntry(0, 1, math.tan(skewX * math.pi / 180)),
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: w,
        height: h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Tip
            Positioned(
              top: -refSize * 0.025,
              left: 0,
              child: Container(
                width: w * 0.66, // 80/120 approx
                height: refSize * 0.05,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFff9a56), Color(0xFFff6f56)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(refSize * 0.03),
                    topRight: Radius.circular(refSize * 0.03),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26, // 0.2 opacity
                      blurRadius: refSize * 0.0375,
                      offset: Offset(0, refSize * 0.0125),
                    ),
                  ],
                ),
              ),
            ),
            // Cover
            Container(
              width: w,
              height: h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFffe563), Color(0xFFffc663)],
                ),
                borderRadius: BorderRadius.circular(refSize * 0.025),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38, // 0.3 opacity
                    blurRadius: refSize * 0.075,
                    offset: Offset(0, refSize * 0.0375),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(double hoverValue, double refSize) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: refSize * 0.025,
        horizontal: refSize * 0.0875,
      ),
      decoration: BoxDecoration(
        // Background: 0.2 -> 0.4 on hover
        color: Colors.white.withValues(alpha: 0.2 + (0.2 * hoverValue)),
        borderRadius: BorderRadius.circular(refSize * 0.025),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: refSize * 0.05,
            offset: Offset(0, refSize * 0.025),
          ),
        ],
      ),
      child: Text(
        widget.label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: refSize * 0.03, // Reduced from 0.04
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
