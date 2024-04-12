import 'package:flutter/material.dart';
import 'sub_block.dart';

enum BlockMovement {
  UP,
  DOWN,
  LEFT,
  RIGHT,
  ROTATE_CLOCKWISE,
  ROTATE_COUNTER_CLOCKWISE,

}

class Block {
  List<List<SubBlock>> orientations;
  int x;
  int y = 0; // Gán giá trị mặc định ban đầu
  int orientationIndex;
  late Color _color;

  Block(this.orientations, Color color, this.orientationIndex) : x = 3 {
    this.color = color;
    _initialize();
  }

  void _initialize() {
    // Bây giờ bạn có thể sử dụng 'height' vì instance đã được tạo
    y = -height;
  }

  set color(Color color) {
    _color = color;
    orientations.forEach((orientation) {
      orientation.forEach((subBlock) {
        subBlock.color = color;
      });
    });
  }

  Color get color => _color;

  List<SubBlock> get subBlocks => orientations[orientationIndex];

  int get width {
    return subBlocks.fold(0, (int previousValue, subBlock) => subBlock.x > previousValue ? subBlock.x : previousValue) + 1;
  }

  int get height {
    return subBlocks.fold(0, (int previousValue, subBlock) => subBlock.y > previousValue ? subBlock.y : previousValue) + 1;
  }

  void move(BlockMovement blockMovement) {
    switch (blockMovement) {
      case BlockMovement.UP:
        y -= 1;
        break;
      case BlockMovement.DOWN:
        if (y < 20 - height) {
          y += 1;
        }
        break;
      case BlockMovement.LEFT:
        x -= 1;
        break;
      case BlockMovement.RIGHT:
        x += 1;
        break;
      case BlockMovement.ROTATE_CLOCKWISE:
        orientationIndex = (orientationIndex + 1) % 4;
        break;
      case BlockMovement.ROTATE_COUNTER_CLOCKWISE:
        orientationIndex = (orientationIndex + 3) % 4;
        break;
    }
  }
}


class IBlock extends Block {
  IBlock(int orientationIndex)
      : super([
    [SubBlock(0, 0, Colors.red[400]!), SubBlock(0, 1, Colors.red[400]!), SubBlock(0, 2, Colors.red[400]!), SubBlock(0, 3, Colors.red[400]!)],
    [SubBlock(0, 0, Colors.red[400]!), SubBlock(1, 0, Colors.red[400]!), SubBlock(2, 0, Colors.red[400]!), SubBlock(3, 0, Colors.red[400]!)],
    [SubBlock(0, 0, Colors.red[400]!), SubBlock(0, 1, Colors.red[400]!), SubBlock(0, 2, Colors.red[400]!), SubBlock(0, 3, Colors.red[400]!)],
    [SubBlock(0, 0, Colors.red[400]!), SubBlock(1, 0, Colors.red[400]!), SubBlock(2, 0, Colors.red[400]!), SubBlock(3, 0, Colors.red[400]!)],
  ], Colors.red[400]!, orientationIndex);
}
class JBlock extends Block {
  JBlock(int orientationIndex)
      : super([
    [SubBlock(1, 0, Colors.yellow[300]!), SubBlock(1, 1, Colors.yellow[300]!), SubBlock(1, 2, Colors.yellow[300]!), SubBlock(0, 2, Colors.yellow[300]!)],
    [SubBlock(0, 0, Colors.yellow[300]!), SubBlock(0, 1, Colors.yellow[300]!), SubBlock(1, 1, Colors.yellow[300]!), SubBlock(2, 1, Colors.yellow[300]!)],
    [SubBlock(0, 0, Colors.yellow[300]!), SubBlock(1, 0, Colors.yellow[300]!), SubBlock(0, 1, Colors.yellow[300]!), SubBlock(0, 2, Colors.yellow[300]!)],
    [SubBlock(0, 0, Colors.yellow[300]!), SubBlock(1, 0, Colors.yellow[300]!), SubBlock(2, 0, Colors.yellow[300]!), SubBlock(2, 1, Colors.yellow[300]!)],
  ], Colors.yellow[300]!, orientationIndex);
}

class LBlock extends Block {
  LBlock(int orientationIndex)
      : super([
    [SubBlock(0, 0, Colors.green[300]!), SubBlock(0, 1, Colors.green[300]!), SubBlock(0, 2, Colors.green[300]!), SubBlock(1, 2, Colors.green[300]!)],
    [SubBlock(0, 0, Colors.green[300]!), SubBlock(1, 0, Colors.green[300]!), SubBlock(2, 0, Colors.green[300]!), SubBlock(0, 1, Colors.green[300]!)],
    [SubBlock(0, 0, Colors.green[300]!), SubBlock(1, 0, Colors.green[300]!), SubBlock(1, 1, Colors.green[300]!), SubBlock(1, 2, Colors.green[300]!)],
    [SubBlock(2, 0, Colors.green[300]!), SubBlock(0, 1, Colors.green[300]!), SubBlock(1, 1, Colors.green[300]!), SubBlock(2, 1, Colors.green[300]!)],
  ], Colors.green[300]!, orientationIndex);
}

class OBlock extends Block {
  OBlock(int orientationIndex)
      : super([
    [SubBlock(0, 0, Colors.blue[300]!), SubBlock(1, 0, Colors.blue[300]!), SubBlock(0, 1, Colors.blue[300]!), SubBlock(1, 1, Colors.blue[300]!)],
    [SubBlock(0, 0, Colors.blue[300]!), SubBlock(1, 0, Colors.blue[300]!), SubBlock(0, 1, Colors.blue[300]!), SubBlock(1, 1, Colors.blue[300]!)],
    [SubBlock(0, 0, Colors.blue[300]!), SubBlock(1, 0, Colors.blue[300]!), SubBlock(0, 1, Colors.blue[300]!), SubBlock(1, 1, Colors.blue[300]!)],
    [SubBlock(0, 0, Colors.blue[300]!), SubBlock(1, 0, Colors.blue[300]!), SubBlock(0, 1, Colors.blue[300]!), SubBlock(1, 1, Colors.blue[300]!)],
  ], Colors.blue[300]!, orientationIndex);
}

class TBlock extends Block {
  TBlock(int orientationIndex)
      : super([
    [SubBlock(0, 0, Colors.purple[300]!), SubBlock(1, 0, Colors.purple[300]!), SubBlock(2, 0, Colors.purple[300]!), SubBlock(1, 1, Colors.purple[300]!)],
    [SubBlock(1, 0, Colors.purple[300]!), SubBlock(0, 1, Colors.purple[300]!), SubBlock(1, 1, Colors.purple[300]!), SubBlock(1, 2, Colors.purple[300]!)],
    [SubBlock(1, 0, Colors.purple[300]!), SubBlock(0, 1, Colors.purple[300]!), SubBlock(1, 1, Colors.purple[300]!), SubBlock(2, 1, Colors.purple[300]!)],
    [SubBlock(0, 0, Colors.purple[300]!), SubBlock(0, 1, Colors.purple[300]!), SubBlock(1, 1, Colors.purple[300]!), SubBlock(0, 2, Colors.purple[300]!)],
  ], Colors.purple[300]!, orientationIndex);
}

class SBlock extends Block {
  SBlock(int orientationIndex)
      : super([
    [SubBlock(1, 0, Colors.red[300]!), SubBlock(2, 0, Colors.red[300]!), SubBlock(0, 1, Colors.red[300]!), SubBlock(1, 1, Colors.red[300]!)],
    [SubBlock(0, 0, Colors.red[300]!), SubBlock(0, 1, Colors.red[300]!), SubBlock(1, 1, Colors.red[300]!), SubBlock(1, 2, Colors.red[300]!)],
    [SubBlock(1, 0, Colors.red[300]!), SubBlock(2, 0, Colors.red[300]!), SubBlock(0, 1, Colors.red[300]!), SubBlock(1, 1, Colors.red[300]!)],
    [SubBlock(0, 0, Colors.red[300]!), SubBlock(0, 1, Colors.red[300]!), SubBlock(1, 1, Colors.red[300]!), SubBlock(1, 2, Colors.red[300]!)],
  ], Colors.red[300]!, orientationIndex);
}

class ZBlock extends Block {
  ZBlock(int orientationIndex)
      : super([
    [SubBlock(0, 0, Colors.green[700]!), SubBlock(1, 0, Colors.green[700]!), SubBlock(1, 1, Colors.green[700]!), SubBlock(2, 1, Colors.green[700]!)],
    [SubBlock(1, 0, Colors.green[700]!), SubBlock(0, 1, Colors.green[700]!), SubBlock(1, 1, Colors.green[700]!), SubBlock(0, 2, Colors.green[700]!)],
    [SubBlock(0, 0, Colors.green[700]!), SubBlock(1, 0, Colors.green[700]!), SubBlock(1, 1, Colors.green[700]!), SubBlock(2, 1, Colors.green[700]!)],
    [SubBlock(1, 0, Colors.green[700]!), SubBlock(0, 1, Colors.green[700]!), SubBlock(1, 1, Colors.green[700]!), SubBlock(0, 2, Colors.green[700]!)],
  ], Colors.green[700]!, orientationIndex);
}
