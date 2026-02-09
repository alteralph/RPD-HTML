import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'themes/season_data.dart';

class CloudBackground extends StatefulWidget {
  final bool isDarkMode;
  final double stormIntensity;
  final SeasonTheme currentTheme;
  final bool isHighPerformance; 

  const CloudBackground({
    super.key,
    required this.isDarkMode,
    this.stormIntensity = 0.0,
    required this.currentTheme,
    this.isHighPerformance = true,
  });

  @override
  State<CloudBackground> createState() => _CloudBackgroundState();
}

class _CloudBackgroundState extends State<CloudBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Cloud> _clouds = [];
  final List<Particle> _ambientParticles = [];
  final List<Particle> _stormParticles = [];
  final Random _random = Random();
  double _screenWidth = 0;
  double _screenHeight = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _controller.addListener(_updatePhysics);
    _generateClouds();
    _generateParticles();
  }

  @override
  void didUpdateWidget(CloudBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentTheme.particleType !=
        widget.currentTheme.particleType) {
      _generateClouds();
      _generateParticles();
    }
  }

  void _generateClouds() {
    _clouds.clear();
    bool isHalloween = widget.currentTheme.particleType == ParticleType.halloween;
    
    double multiplier = widget.isHighPerformance ? 1.0 : 0.5;
    
    int baseCount = widget.currentTheme.particleType == ParticleType.summer ? 6 : (isHalloween ? 25 : 20);
    int count = (baseCount * multiplier).ceil();
    
    for (int i = 0; i < count; i++) {
      List<CloudPuffData> puffs = [];
      int puffMax = widget.isHighPerformance ? 20 : 10;
      int numPuffs = 10 + _random.nextInt(puffMax); 
      
      for (int j = 0; j < numPuffs; j++) {
        double angle = _random.nextDouble() * 2 * pi;
        double distance = sqrt(_random.nextDouble()) * 80;
        puffs.add(CloudPuffData(
            offset: Offset(cos(angle) * distance, sin(angle) * distance * 0.7),
            baseRadius: 25 + _random.nextDouble() * 35,
            brightnessVariation: 0.95 + _random.nextDouble() * 0.1));
      }
      _clouds.add(Cloud(
          x: _random.nextDouble() * 1500 - 400,
          y: _random.nextDouble() * 600 - 150,
          speed: 0.15 + _random.nextDouble() * 0.25,
          puffs: puffs));
    }
  }

  void _generateParticles() {
    _ambientParticles.clear();
    _stormParticles.clear();
    ParticleType type = widget.currentTheme.particleType;
    
    double multiplier = widget.isHighPerformance ? 1.0 : 0.4;

    if (type == ParticleType.summer) {
      int count = (40 * multiplier).ceil();
      for (int i = 0; i < count; i++) {
        bool isFlora = i % 2 != 0;
        Color? petalColor;
        bool isFullFlower = isFlora && _random.nextBool();

        if (isFlora) {
          List<Color> colors = [
            Colors.pinkAccent.shade100,
            Colors.yellowAccent.shade100,
            Colors.lightBlueAccent.shade100,
            Colors.white,
            Colors.purpleAccent.shade100
          ];
          petalColor = colors[_random.nextInt(colors.length)];
        }
        _ambientParticles.add(Particle(
          x: _random.nextDouble() * 1000,
          y: _random.nextDouble() * 1000,
          speed: 0.2 + _random.nextDouble() * 0.8,
          size: isFlora
              ? (isFullFlower ? 12 : 8) + _random.nextDouble() * 6
              : 2 + _random.nextDouble() * 2,
          wobbleOffset: _random.nextDouble() * 100,
          color: petalColor,
          isFlower: isFullFlower,
        ));
      }
    } else if (type == ParticleType.leaves) {
      int count = (120 * multiplier).ceil();
      for (int i = 0; i < count; i++) {
        _ambientParticles.add(Particle(
            x: _random.nextDouble() * 1000,
            y: _random.nextDouble() * 1000,
            speed: 1.0 + _random.nextDouble() * 2.0,
            size: 8 + _random.nextDouble() * 8,
            wobbleOffset: _random.nextDouble() * 2 * pi));
      }
    } else if (type == ParticleType.snow) {
      int count = (150 * multiplier).ceil();
      for (int i = 0; i < count; i++) {
        _ambientParticles.add(Particle(
            x: _random.nextDouble() * 1000,
            y: _random.nextDouble() * 1000,
            speed: 2 + _random.nextDouble() * 3,
            size: 2 + _random.nextDouble() * 3,
            wobbleOffset: _random.nextDouble() * 2 * pi));
      }
    } else if (type == ParticleType.rain) {
      int count = (400 * multiplier).ceil();
      for (int i = 0; i < count; i++) {
        _ambientParticles.add(Particle(
            x: _random.nextDouble() * 1000,
            y: _random.nextDouble() * 1000,
            speed: 15 + _random.nextDouble() * 15,
            length: 10 + _random.nextDouble() * 20));
      }
    } else if (type == ParticleType.halloween) {
      int count = (80 * multiplier).ceil();
      for (int i = 0; i < count; i++) {
        int variant = _random.nextInt(10); 
        _ambientParticles.add(Particle(
            x: _random.nextDouble() * 1000,
            y: _random.nextDouble() * 1000,
            speed: 0.5 + _random.nextDouble() * 1.5,
            size: 10 + _random.nextDouble() * 10,
            wobbleOffset: _random.nextDouble() * 2 * pi,
            variant: variant)); 
      }
    } else if (type == ParticleType.christmas) {
      int count = (100 * multiplier).ceil();
      for (int i = 0; i < count; i++) {
        int variant = _random.nextInt(10);
        _ambientParticles.add(Particle(
            x: _random.nextDouble() * 1000,
            y: _random.nextDouble() * 1000,
            speed: 1.5 + _random.nextDouble() * 2.5,
            size: 5 + _random.nextDouble() * 10,
            wobbleOffset: _random.nextDouble() * 2 * pi,
            variant: variant));
      }
    }

    if (type == ParticleType.leaves || type == ParticleType.none || type == ParticleType.halloween || type == ParticleType.christmas) {
      int baseStorm = (type == ParticleType.halloween || type == ParticleType.christmas) ? 150 : 300;
      int stormCount = (baseStorm * multiplier).ceil();
      for (int i = 0; i < stormCount; i++) {
        _stormParticles.add(Particle(
            x: _random.nextDouble() * 1000,
            y: _random.nextDouble() * 1000,
            speed: 20 + _random.nextDouble() * 10,
            length: 15 + _random.nextDouble() * 15));
      }
    }
  }

  void _updatePhysics() {
    if (_screenWidth == 0) return;
    for (var cloud in _clouds) {
      cloud.x += cloud.speed;
      if (cloud.x > _screenWidth + 400) {
        cloud.x = -500;
        cloud.y = _random.nextDouble() * (_screenHeight * 0.6) - 100;
      }
    }

    ParticleType type = widget.currentTheme.particleType;
    
    for (var p in _ambientParticles) {
      bool shouldMove = (type == ParticleType.summer || type == ParticleType.leaves || type == ParticleType.halloween || type == ParticleType.christmas) || (type != ParticleType.none && widget.stormIntensity > 0.05);
      
      if (shouldMove) {
        double speedMult = 1.0;
        if (type == ParticleType.rain) {
          speedMult = 1.0 + widget.stormIntensity * 2.5;
        }
        if (type == ParticleType.leaves || type == ParticleType.halloween || type == ParticleType.christmas) { 
          speedMult = 1.0 + widget.stormIntensity;
        }
          
        p.y += p.speed * speedMult;
        
        if (type != ParticleType.rain && type != ParticleType.none) {
          p.wobbleOffset += (type == ParticleType.summer ? 0.02 : 0.04);
          p.x += sin(p.wobbleOffset) * (type == ParticleType.summer ? 0.5 : 1.0);
        }
        
        if (p.y > _screenHeight + 50) {
          p.y = -50;
          p.x = _random.nextDouble() * _screenWidth;
        }
      }
    }
    
    bool stormActive = false;
    if (type == ParticleType.leaves && widget.stormIntensity > 0.2) stormActive = true;
    if (type == ParticleType.none && widget.stormIntensity > 0.6) stormActive = true;
    if ((type == ParticleType.halloween || type == ParticleType.christmas) && widget.stormIntensity > 0.7) stormActive = true;

    if (stormActive) {
      for (var p in _stormParticles) {
        p.y += p.speed * (1.0 + widget.stormIntensity);
        if (p.y > _screenHeight) {
          p.y = -p.length;
          p.x = _random.nextDouble() * _screenWidth;
        }
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    
    Color lightTop = widget.currentTheme.lightTop;
    Color lightBottom = widget.currentTheme.lightBottom;
    Color darkTop = widget.currentTheme.darkTop;
    Color darkBottom = widget.currentTheme.darkBottom;
    
    Color topColor, bottomColor;
    if (widget.isDarkMode) {
      topColor = Color.lerp(darkTop, const Color(0xFF08080A), widget.stormIntensity)!;
      bottomColor = Color.lerp(darkBottom, const Color(0xFF1C1C24), widget.stormIntensity)!;
    } else {
      topColor = Color.lerp(lightTop, const Color(0xFF5D6D7E), widget.stormIntensity)!;
      bottomColor = Color.lerp(lightBottom, const Color(0xFFBFC9CA), widget.stormIntensity)!;
    }
    
    // OTIMIZAÇÃO: 
    // Desktop: 2.0 (Sutil)
    // Mobile: 10.0 (Aumentado para ser visível, mas ainda performático)
    double bgBlur = widget.isHighPerformance ? 2.0 : 10.0;

    return Stack(children: [
      AnimatedContainer(
          duration: const Duration(milliseconds: 1500),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [topColor, bottomColor]))),
      CustomPaint(
          painter: StormPainter(
              clouds: _clouds,
              ambientParticles: _ambientParticles,
              stormParticles: _stormParticles,
              isDarkMode: widget.isDarkMode,
              stormIntensity: widget.stormIntensity,
              particleType: widget.currentTheme.particleType,
              screenWidth: _screenWidth,
              screenHeight: _screenHeight,
              isHighPerformance: widget.isHighPerformance, 
          ),
          size: Size.infinite),
      
      // BackdropFilter sempre presente, mas leve
      BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: bgBlur, sigmaY: bgBlur),
          child: const SizedBox.expand())
    ]);
  }
}

// ... CloudPuffData e Cloud permanecem iguais ...
class CloudPuffData {
  Offset offset;
  double baseRadius;
  double brightnessVariation;
  CloudPuffData(
      {required this.offset,
      required this.baseRadius,
      required this.brightnessVariation});
}

class Cloud {
  double x, y, speed;
  List<CloudPuffData> puffs;
  Cloud(
      {required this.x,
      required this.y,
      required this.speed,
      required this.puffs});
}

class Particle {
  double x, y, speed, length, size, wobbleOffset;
  Color? color;
  bool isFlower;
  int variant;
  Particle(
      {required this.x,
      required this.y,
      required this.speed,
      this.length = 0,
      this.size = 0,
      this.wobbleOffset = 0,
      this.color,
      this.isFlower = false,
      this.variant = 0});
}

class StormPainter extends CustomPainter {
  final List<Cloud> clouds;
  final List<Particle> ambientParticles;
  final List<Particle> stormParticles;
  final bool isDarkMode;
  final double stormIntensity;
  final ParticleType particleType;
  final double screenWidth;
  final double screenHeight;
  final bool isHighPerformance; 

  StormPainter(
      {required this.clouds,
      required this.ambientParticles,
      required this.stormParticles,
      required this.isDarkMode,
      required this.stormIntensity,
      required this.particleType,
      required this.screenWidth,
      required this.screenHeight,
      required this.isHighPerformance});

  @override
  void paint(Canvas canvas, Size size) {
    if (particleType == ParticleType.halloween) {
      _paintMoon(canvas);
    }
    
    if (particleType == ParticleType.christmas) {
      _paintAurora(canvas, size);
    }
    
    _paintClouds3D(canvas);
    
    if (particleType != ParticleType.none && particleType != ParticleType.rain) {
      _paintAmbient(canvas);
    } else if (particleType != ParticleType.none && stormIntensity > 0.05) {
      _paintAmbient(canvas);
    }
    
    bool showExtraRain = false;
    if (particleType == ParticleType.leaves && stormIntensity > 0.2) showExtraRain = true;
    if (particleType == ParticleType.none && stormIntensity > 0.6) showExtraRain = true;
    if ((particleType == ParticleType.halloween || particleType == ParticleType.christmas) && stormIntensity > 0.7) showExtraRain = true;

    if (showExtraRain) {
      _paintExtraRain(canvas);
    }
  }

  void _paintMoon(Canvas canvas) {
    final center = Offset(screenWidth * 0.8, screenHeight * 0.15);
    final radius = 60.0;
    
    double glowOpacity = isDarkMode ? 0.6 : 0.3;
    Color glowColor = const Color(0xFFFFB300);

    if (isHighPerformance) {
      final paintGlow = Paint()
        ..color = glowColor.withValues(alpha: glowOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50.0);
      canvas.drawCircle(center, radius * 1.8, paintGlow);
    } else {
      // Glow simplificado
      final paintGlowSimple = Paint()
        ..color = glowColor.withValues(alpha: glowOpacity * 0.5);
      canvas.drawCircle(center, radius * 1.5, paintGlowSimple);
    }
    
    final paintMoon = Paint()
      ..color = const Color(0xFFFFD54F);
    
    canvas.drawCircle(center, radius, paintMoon);

    final paintCrater = Paint()
      ..color = const Color(0xFFFFCA28).withValues(alpha: 0.5);
    canvas.drawCircle(center + const Offset(-15, 10), 10, paintCrater);
    canvas.drawCircle(center + const Offset(20, -15), 8, paintCrater);
  }

  void _paintAurora(Canvas canvas, Size size) {
    double opacity = isDarkMode ? 0.6 : 0.3;
    double blurVal = isHighPerformance ? 30.0 : 2.0; 

    final auroraGradient = ui.Gradient.linear(
      Offset(0, 0),
      Offset(0, size.height * 0.5),
      [
        const Color(0xFF00E676).withValues(alpha: 0.0),
        const Color(0xFF00E676).withValues(alpha: opacity),
        const Color(0xFF651FFF).withValues(alpha: opacity * 0.8),
        const Color(0xFF651FFF).withValues(alpha: 0.0),
      ],
      [0.0, 0.4, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = auroraGradient
      ..style = PaintingStyle.fill;
      
    if (isHighPerformance) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blurVal);
    }

    Path path = Path();
    path.moveTo(0, size.height * 0.2);
    path.cubicTo(
      size.width * 0.3, size.height * 0.1, 
      size.width * 0.6, size.height * 0.4, 
      size.width, size.height * 0.2
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);

    if (isHighPerformance) {
      final auroraGradient2 = ui.Gradient.linear(
         Offset(0, 0),
         Offset(0, size.height * 0.4),
         [
           const Color(0xFF18FFFF).withValues(alpha: 0.0),
           const Color(0xFF18FFFF).withValues(alpha: opacity * 0.7),
           const Color(0xFF00B0FF).withValues(alpha: 0.0),
         ],
         [0.0, 0.5, 1.0]
      );

      final paint2 = Paint()
        ..shader = auroraGradient2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

      Path path2 = Path();
      path2.moveTo(0, size.height * 0.15);
      path2.cubicTo(
        size.width * 0.4, size.height * 0.35, 
        size.width * 0.7, size.height * 0.05, 
        size.width, size.height * 0.25
      );
      path2.lineTo(size.width, 0);
      path2.lineTo(0, 0);
      path2.close();

      canvas.drawPath(path2, paint2);
    }
  }

  void _paintClouds3D(Canvas canvas) {
    Color highlightClean, shadowClean, highlightStorm, shadowStorm;
    if (isDarkMode) {
      highlightClean = Colors.white.withValues(alpha: 0.15);
      shadowClean = Colors.white.withValues(alpha: 0.02);
      highlightStorm = const Color(0xFF90A4AE).withValues(alpha: 0.3);
      shadowStorm = const Color(0xFF37474F).withValues(alpha: 0.5);
    } else {
      highlightClean = Colors.white;
      shadowClean = const Color(0xFFEEEEEE);
      highlightStorm = const Color(0xFFCFD8DC);
      shadowStorm = const Color(0xFF78909C);
    }
    
    if (particleType == ParticleType.halloween) {
       highlightClean = highlightClean.withValues(alpha: 0.08);
       shadowClean = shadowClean.withValues(alpha: 0.01);
    }

    final Color currentHighlight =
        Color.lerp(highlightClean, highlightStorm, stormIntensity)!;
    final Color currentShadow =
        Color.lerp(shadowClean, shadowStorm, stormIntensity)!;
    double scaleFactor = 1.0 + (stormIntensity * 1.3);
    
    double blurAmount = isHighPerformance ? (particleType == ParticleType.halloween ? 8.0 : 3.0) : 0.0;

    final Paint puffPaint = Paint()
      ..style = PaintingStyle.fill;
      
    if (blurAmount > 0) {
      puffPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, blurAmount);
    }
      
    for (var cloud in clouds) {
      cloud.puffs.sort((a, b) => a.baseRadius.compareTo(b.baseRadius));
      for (var puff in cloud.puffs) {
        double currentRadius = puff.baseRadius * scaleFactor;
        Offset puffCenter = Offset(cloud.x + puff.offset.dx * scaleFactor,
            cloud.y + puff.offset.dy * scaleFactor);
        
        puffPaint.shader = ui.Gradient.radial(
            puffCenter + Offset(-currentRadius * 0.3, -currentRadius * 0.3),
            currentRadius * 1.3,
            [
              _adjustBrightness(currentHighlight, puff.brightnessVariation),
              _adjustBrightness(currentShadow, puff.brightnessVariation)
            ],
            [0.0, 1.0],
            TileMode.clamp);
        canvas.drawCircle(puffCenter, currentRadius, puffPaint);
      }
    }
  }

  Color _adjustBrightness(Color color, double factor) {
    return Color.fromARGB(
        (color.a * 255).round(),
        (color.r * 255 * factor).clamp(0, 255).toInt(),
        (color.g * 255 * factor).clamp(0, 255).toInt(),
        (color.b * 255 * factor).clamp(0, 255).toInt());
  }

  void _paintAmbient(Canvas canvas) {
    int count = ambientParticles.length;
    if (particleType == ParticleType.rain || particleType == ParticleType.snow) {
      count = (ambientParticles.length * stormIntensity).toInt();
    }
    if (particleType == ParticleType.halloween || particleType == ParticleType.christmas) {
      count = ambientParticles.length; 
    }

    final Paint paint = Paint()..style = PaintingStyle.fill;

    if (particleType == ParticleType.rain) {
      Color rainColor = isDarkMode ? Colors.white : Colors.blueGrey.shade800;
      paint.color = rainColor.withValues(alpha: 0.1 + 0.4 * stormIntensity);
      paint.strokeWidth = 2.5;
      paint.strokeCap = StrokeCap.round;
    } else if (particleType == ParticleType.snow) {
      paint.color = Colors.white.withValues(alpha: 0.4 + 0.4 * stormIntensity);
    } else if (particleType == ParticleType.leaves) {
      paint.color = const Color(0xFFE65100).withValues(alpha: 0.85);
    }

    for (int i = 0; i < count; i++) {
      var p = ambientParticles[i];
      if (particleType == ParticleType.rain) {
        canvas.drawLine(
            Offset(p.x, p.y), Offset(p.x - 3, p.y + p.length), paint);
      } else if (particleType == ParticleType.snow) {
        canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
      } else if (particleType == ParticleType.leaves) {
        _drawLeaf(canvas, p, paint);
      } else if (particleType == ParticleType.summer) {
        _drawSummer(canvas, p, paint); 
      } else if (particleType == ParticleType.halloween) {
        _drawHalloween(canvas, p);
      } else if (particleType == ParticleType.christmas) {
        _drawChristmas(canvas, p);
      }
    }
  }
  
  void _drawLeaf(Canvas canvas, Particle p, Paint paint) {
    canvas.save();
    canvas.translate(p.x, p.y);
    canvas.rotate(sin(p.wobbleOffset));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset.zero, width: p.size, height: p.size * 0.6),
        paint);
    canvas.restore();
  }

  void _drawSummer(Canvas canvas, Particle p, Paint paint) {
     if (p.color == null) {
          paint.color = const Color(0xFFFFEB3B)
              .withValues(alpha: 0.6 + 0.3 * sin(p.wobbleOffset));
          if (isHighPerformance) {
             paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
          }
          canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
          paint.maskFilter = null;
        } else {
          paint.color = p.color!.withValues(alpha: 0.8);
          canvas.save();
          canvas.translate(p.x, p.y);
          canvas.rotate(p.wobbleOffset * 0.5);
          if (p.isFlower) {
            for (int k = 0; k < 5; k++) {
              double angle = (k * 2 * pi / 5);
              Offset petalOffset =
                  Offset(cos(angle), sin(angle)) * (p.size * 0.4);
              canvas.drawOval(
                  Rect.fromCenter(
                      center: petalOffset,
                      width: p.size * 0.5,
                      height: p.size * 0.7),
                  paint);
            }
            paint.color = Colors.yellow.withValues(alpha: 0.9);
            canvas.drawCircle(Offset.zero, p.size * 0.25, paint);
          } else {
            canvas.drawOval(
                Rect.fromCenter(
                    center: Offset.zero, width: p.size, height: p.size * 0.8),
                paint);
          }
          canvas.restore();
        }
  }

  void _drawHalloween(Canvas canvas, Particle p) {
    canvas.save();
    canvas.translate(p.x, p.y);
    canvas.rotate(sin(p.wobbleOffset) * 0.5);

    if (p.variant <= 5) {
      Color leafColor = p.variant % 2 == 0 ? const Color(0xFFD35400) : const Color(0xFFE67E22);
      final paint = Paint()..color = leafColor.withValues(alpha: 0.8);
      canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6), 
          paint);
    } else if (p.variant <= 7) {
      final paintBody = Paint()..color = const Color(0xFFE65100);
      canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.8), 
          paintBody);
      final paintStem = Paint()..color = Colors.green[800]!;
      canvas.drawRect(Rect.fromLTWH(-p.size * 0.1, -p.size * 0.5, p.size * 0.2, p.size * 0.2), paintStem);
    } else {
      final paintBone = Paint()..color = Colors.white.withValues(alpha: 0.85);
      canvas.drawCircle(Offset(0, -p.size * 0.2), p.size * 0.4, paintBone);
      Path path = Path();
      path.moveTo(-p.size * 0.4, -p.size * 0.1);
      path.lineTo(p.size * 0.4, -p.size * 0.1);
      path.lineTo(0, p.size * 0.6);
      path.close();
      canvas.drawPath(path, paintBone);
      final paintEyes = Paint()..color = Colors.black;
      canvas.drawCircle(Offset(-p.size * 0.15, -p.size * 0.2), p.size * 0.08, paintEyes);
      canvas.drawCircle(Offset(p.size * 0.15, -p.size * 0.2), p.size * 0.08, paintEyes);
    }
    canvas.restore();
  }

  void _drawChristmas(Canvas canvas, Particle p) {
    canvas.save();
    canvas.translate(p.x, p.y);
    canvas.rotate(p.wobbleOffset);

    if (p.variant <= 4) {
      final paintSnow = Paint()..color = Colors.white.withValues(alpha: 0.6 + 0.3 * sin(p.wobbleOffset));
      canvas.drawCircle(Offset.zero, p.size * 0.3, paintSnow);
    } else if (p.variant <= 6) {
      final paintTree = Paint()..color = const Color(0xFF2E7D32);
      Path path = Path();
      path.moveTo(0, -p.size * 0.5);
      path.lineTo(p.size * 0.4, p.size * 0.5);
      path.lineTo(-p.size * 0.4, p.size * 0.5);
      path.close();
      canvas.drawPath(path, paintTree);
    } else if (p.variant <= 8) {
      Color ballColor = p.variant == 7 ? const Color(0xFFC0392B) : const Color(0xFFF1C40F);
      final paintBall = Paint()..color = ballColor;
      canvas.drawCircle(Offset.zero, p.size * 0.4, paintBall);
      final paintHook = Paint()..color = Colors.grey[400]!..style = PaintingStyle.stroke..strokeWidth = 1.0;
      canvas.drawArc(Rect.fromCircle(center: Offset(0, -p.size * 0.4), radius: p.size * 0.1), pi, pi, false, paintHook);
    } else {
      final paintCookie = Paint()..color = const Color(0xFFD38D5F);
      canvas.drawCircle(Offset.zero, p.size * 0.4, paintCookie);
    }
    canvas.restore();
  }

  void _paintExtraRain(Canvas canvas) {
    double threshold = particleType == ParticleType.none ? 0.6 : 0.2;
    if (particleType == ParticleType.halloween || particleType == ParticleType.christmas) threshold = 0.7;

    int count = (stormParticles.length * (stormIntensity - threshold))
        .clamp(0, stormParticles.length)
        .toInt();
    Color rainColor = isDarkMode ? Colors.white : Colors.blueGrey.shade800;
    final Paint rainPaint = Paint()
      ..color = rainColor.withValues(alpha: 0.1 + 0.4 * stormIntensity)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < count; i++) {
      var p = stormParticles[i];
      canvas.drawLine(
          Offset(p.x, p.y), Offset(p.x - 2, p.y + p.length), rainPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}