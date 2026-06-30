class StickerLayer {
  final String src;
  final double x;
  final double y;
  final double scale;

  const StickerLayer({
    required this.src,
    this.x = 100,
    this.y = 200,
    this.scale = 1.0,
  });

  StickerLayer copyWith({String? src, double? x, double? y, double? scale}) =>
      StickerLayer(
        src: src ?? this.src,
        x: x ?? this.x,
        y: y ?? this.y,
        scale: scale ?? this.scale,
      );

  Map<String, dynamic> toJson() => {'src': src, 'x': x, 'y': y, 'scale': scale};

  factory StickerLayer.fromJson(Map<String, dynamic> json) => StickerLayer(
        src: json['src'] as String,
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        scale: (json['scale'] as num).toDouble(),
      );
}
