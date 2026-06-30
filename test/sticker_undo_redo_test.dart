import 'package:flutter_test/flutter_test.dart';
import 'package:diy_wallpaper/features/garage/sticker_layer.dart';

// Unit test for undo/redo stack logic (extracted from GarageScreen)
class StickerStack {
  List<StickerLayer> stickers = [];
  List<List<StickerLayer>> undoStack = [];
  List<List<StickerLayer>> redoStack = [];

  void add(StickerLayer s) {
    undoStack.add(List.from(stickers));
    redoStack.clear();
    stickers = [...stickers, s];
  }

  bool undo() {
    if (undoStack.isEmpty) return false;
    redoStack.add(List.from(stickers));
    stickers = List.from(undoStack.removeLast());
    return true;
  }

  bool redo() {
    if (redoStack.isEmpty) return false;
    undoStack.add(List.from(stickers));
    stickers = List.from(redoStack.removeLast());
    return true;
  }
}

void main() {
  group('StickerStack undo/redo', () {
    test('add → undo removes sticker', () {
      final stack = StickerStack();
      const s = StickerLayer(src: 'a.png');
      stack.add(s);
      expect(stack.stickers.length, 1);
      stack.undo();
      expect(stack.stickers.length, 0);
    });

    test('undo → redo restores sticker', () {
      final stack = StickerStack();
      const s = StickerLayer(src: 'a.png');
      stack.add(s);
      stack.undo();
      stack.redo();
      expect(stack.stickers.length, 1);
      expect(stack.stickers.first.src, 'a.png');
    });

    test('add after undo clears redo branch', () {
      final stack = StickerStack();
      stack.add(const StickerLayer(src: 'a.png'));
      stack.undo();
      stack.add(const StickerLayer(src: 'b.png'));
      expect(stack.redoStack.isEmpty, true);
      expect(stack.stickers.first.src, 'b.png');
    });

    test('undo on empty returns false', () {
      final stack = StickerStack();
      expect(stack.undo(), false);
    });

    test('redo on empty returns false', () {
      final stack = StickerStack();
      expect(stack.redo(), false);
    });

    test('multiple undo/redo in sequence', () {
      final stack = StickerStack();
      stack.add(const StickerLayer(src: 'a.png'));
      stack.add(const StickerLayer(src: 'b.png'));
      stack.add(const StickerLayer(src: 'c.png'));
      expect(stack.stickers.length, 3);
      stack.undo();
      expect(stack.stickers.length, 2);
      stack.undo();
      expect(stack.stickers.length, 1);
      stack.redo();
      expect(stack.stickers.length, 2);
      expect(stack.stickers.last.src, 'b.png');
    });
  });
}
