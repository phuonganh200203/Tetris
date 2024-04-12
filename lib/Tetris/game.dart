import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import 'main.dart';
import 'block.dart';
import 'sub_block.dart';

// Enum để xác định các loại va chạm
enum Collision { LANDED, LANDED_BLOCK, HIT_WALL, HIT_BLOCK, NONE }

// Các hằng số cơ bản
const BLOCKS_X = 10; // Số lượng khối ngang
const BLOCKS_Y = 20; // Số lượng khối dọc
const REFRESH_RATE = 500; // Tốc độ làm mới
const GAME_AREA_BORDER_WIDTH = 2.0; // Độ rộng đường viền khu vực game
const SUB_BLOCK_EDGE_WIDTH = 2.0; // Độ rộng cạnh của sub-block

// Class Game kế thừa từ StatefulWidget
class Game extends StatefulWidget {
  Game({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => GameState();
}

// Trạng thái của game
class GameState extends State<Game> {
  bool isGameOver = false; // Trạng thái kết thúc game
  double subBlockWidth = 0.0; // Độ rộng của sub-block
  Duration duration = Duration(milliseconds: REFRESH_RATE); // Thời gian làm mới
  Block? currentBlock;
  GlobalKey _keyGameArea = GlobalKey(); // Key cho khu vực game

  BlockMovement? action; // Hành động của khối
  Block? block; // Khối hiện tại
  Timer? timer; // Đối tượng Timer
  Timer? playTimeTimer;

  List<SubBlock> oldSubBlocks = []; // Danh sách các sub-block cũ

  // Hàm tạo khối mới ngẫu nhiên
  Block getNewBlock() {
    int blockType = Random().nextInt(7); // Loại khối
    int orientationIndex = Random().nextInt(4); // Chỉ số hướng

    // Chọn loại khối dựa trên giá trị ngẫu nhiên
    switch (blockType) {
      case 0:
        return IBlock(orientationIndex);
      case 1:
        return JBlock(orientationIndex);
      case 2:
        return LBlock(orientationIndex);
      case 3:
        return OBlock(orientationIndex);
      case 4:
        return TBlock(orientationIndex);
      case 5:
        return SBlock(orientationIndex);
      case 6:
        return ZBlock(orientationIndex);
      default:
        throw Exception("Invalid block type");
    }
  }

  @override
  void initState() {
    super.initState();
    startGame(); // Bắt đầu game
  }

  // Hàm bắt đầu game
  void startGame() {
    // Khởi tạo và bắt đầu Timer
    Provider.of<Data>(context, listen: false).resetPlayTime();
    playTimeTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      Provider.of<Data>(context, listen: false).updatePlayTime();
    });
    Provider.of<Data>(context, listen: false).setIsPlaying(true); // Bắt đầu phát
    Provider.of<Data>(context, listen: false).setScore(0); // Đặt điểm số về 0
    isGameOver = false; // Đặt trạng thái game chưa kết thúc
    oldSubBlocks = []; // Làm mới danh sách sub-block cũ

    // Cài đặt độ rộng cho sub-block
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox? renderBoxGame = _keyGameArea.currentContext?.findRenderObject() as RenderBox?;
      if (renderBoxGame != null) {
        subBlockWidth = (renderBoxGame.size.width - GAME_AREA_BORDER_WIDTH * 2) / BLOCKS_X;
      }
    });

    // Đặt khối tiếp theo và khối hiện tại
    Provider.of<Data>(context, listen: false).setNextBlock(getNewBlock());
    block = getNewBlock();

    // Bắt đầu timer
    timer = Timer.periodic(duration, onPlay);
  }

  // Hàm kết thúc game
  void endGame() {
    Provider.of<Data>(context, listen: false).setIsPlaying(false); // Dừng phát
    timer?.cancel(); // Hủy timer
    // Dừng game và timer
    playTimeTimer?.cancel();
  }

  // Hàm xử lý khi timer được gọi
  void onPlay(Timer timer) {
    var status = Collision.NONE; // Trạng thái va chạm

    setState(() {
      // Kiểm tra và di chuyển khối nếu không va chạm cạnh
      if (action != null && block != null) {
        if (!checkOnEdge(action!)) {
          block!.move(action!);
        }
      }

      // Action đảo ngược nếu khối chạm vào các khối khác
      // Xử lý va chạm giữa khối hiện tại và các sub-block cũ
      for (var oldSubBlock in oldSubBlocks) {
        if (block != null) {
          for (var subBlock in block!.subBlocks) {
            var x = block!.x + subBlock.x;
            var y = block!.y + subBlock.y;
            // Nếu tìm thấy va chạm, thực hiện di chuyển ngược lại
            if (x == oldSubBlock.x && y == oldSubBlock.y) {
              switch (action) {
                case BlockMovement.LEFT:
                  block!.move(BlockMovement.RIGHT);
                  break;
                case BlockMovement.RIGHT:
                  block!.move(BlockMovement.LEFT);
                  break;
                case BlockMovement.DOWN:
                  block!.move(BlockMovement.UP);
                  status = Collision.LANDED_BLOCK;
                  break;
                case BlockMovement.ROTATE_CLOCKWISE:
                  block!.move(BlockMovement.ROTATE_COUNTER_CLOCKWISE);
                  break;
                default:
                  break;
              }
            }
          }
        }
      }
      // Kiểm tra xem khối có nằm ngoài ranh giới không và sửa lại vị trí nếu cần thiết
      if (block != null) {
        switch (action) {
          case BlockMovement.LEFT:
            if (block!.x < 0) {
              block!.x = 0;
            }
            break;
          case BlockMovement.RIGHT:
            if (block!.x + block!.width > BLOCKS_X) {
              block!.x = BLOCKS_X - block!.width;
            }
            break;
          case BlockMovement.ROTATE_CLOCKWISE:
          // Kiểm tra xem khối có gần đáy không, nếu gần thì xoay mà không mất phần khối ở dưới đáy
            if (block!.y + block!.height >= BLOCKS_Y ) {
              block!.move(BlockMovement.ROTATE_COUNTER_CLOCKWISE);
            }
            // Kiểm tra xem khối có nằm ngoài ranh giới không
            else if (block!.x < 0) {
              block!.x = 0;
            } else if (block!.x + block!.width > BLOCKS_X) {
              block!.x = BLOCKS_X - block!.width;
            }
            break;
          default:
            break;
        }
      }

// Kiểm tra nếu khối không ở dưới cùng và chưa va chạm với khối khác
      if (!checkAtBottom() && block != null) {
        if (!checkAboveBlock()) {
          block!.move(BlockMovement.DOWN); // Di chuyển khối xuống
        } else {
          status = Collision.LANDED_BLOCK; // Đã va chạm với khối khác
        }
      } else {
        status = Collision.LANDED; // Đã chạm đất
      }

// Nếu khối đã va chạm với khối khác và y < 0, game over
      if (status == Collision.LANDED_BLOCK && block != null && block!.y < 0) {
        isGameOver = true;
        endGame(); // Kết thúc game
      } else if (status == Collision.LANDED || status == Collision.LANDED_BLOCK) {
        // Thêm các sub-block của khối hiện tại vào danh sách các sub-block cũ
        if (block != null) {
          block!.subBlocks.forEach((subBlock) {
            if (block != null) {
              subBlock.x += block!.x;
              subBlock.y += block!.y;
            }
            oldSubBlocks.add(subBlock);
          });
        }

        // Chuẩn bị khối tiếp theo
        block = Provider.of<Data>(context, listen: false).nextBlock;
        Provider.of<Data>(context, listen: false).setNextBlock(getNewBlock());
      }

      action = null; // Reset hành động sau mỗi lần update
      updateScore(); // Cập nhật điểm số
    });
  }

  void updateScore() {
    var combo = 1; // Biến combo để tính điểm thưởng
    Map<int, int> rows = Map(); // Sử dụng Map để lưu trữ số sub-block trong mỗi hàng
    List<int> rowsToBeRemoved = []; // Danh sách các hàng cần được xóa

    // Đếm số lượng sub-block trong mỗi hàng
    oldSubBlocks.forEach((subBlock) {
      rows.update(subBlock.y, (value) => ++value, ifAbsent: () => 1);
    });

    // Thêm điểm nếu tìm thấy hàng đầy
    rows.forEach((rowNum, count) {
      if (count == BLOCKS_X) {
        Provider.of<Data>(context, listen: false).addScore(combo++);
        rowsToBeRemoved.add(rowNum);
      }
    });

    // Xóa các hàng đã đầy
    if (rowsToBeRemoved.isNotEmpty) {
      removeRows(rowsToBeRemoved);
    }
  }
  void move(BlockMovement direction) {
    setState(() {
      action = direction; // Lưu hành động di chuyển hiện tại
    });
  }

  void removeRows(List<int> rowsToBeRemoved) {
    rowsToBeRemoved.sort(); // Sắp xếp các hàng cần xóa
    // Xóa hàng và di chuyển các hàng phía trên xuống
    rowsToBeRemoved.forEach((rowNum) {
      oldSubBlocks.removeWhere((subBlock) => subBlock.y == rowNum);
      oldSubBlocks.forEach((subBlock) {
        if (subBlock.y < rowNum) {
          ++subBlock.y;
        }
      });
    });
  }

  bool checkAtBottom() {
    return (block?.y ?? 0) + (block?.height ?? 0) == BLOCKS_Y; // Kiểm tra khối đã ở dưới cùng chưa
  }

  bool checkAboveBlock() {
    // Kiểm tra xem có khối nào ở ngay trên khối hiện tại không
    for (var oldSubBlock in oldSubBlocks) {
      if (block != null) {
        for (var subBlock in block!.subBlocks) {
          var x = block!.x + subBlock.x;
          var y = block!.y + subBlock.y;
          if (x == oldSubBlock.x && y + 1 == oldSubBlock.y) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool checkOnEdge(BlockMovement action) {
    // Kiểm tra khối có ở mép trái hoặc phải của khu vực chơi không
    return (action == BlockMovement.LEFT && (block?.x ?? 0) <= 0) ||
        (action == BlockMovement.RIGHT && (block?.x ?? 0) + (block?.width ?? 0) >= BLOCKS_X);
  }

  Widget getPositionedSquareContainer(Color color, int x, int y) {
    // Tạo một container có vị trí xác định dùng để hiển thị mỗi sub-block
    return Positioned(
      left: x * subBlockWidth,
      top: y * subBlockWidth,
      child: Container(
        width: subBlockWidth - SUB_BLOCK_EDGE_WIDTH,
        height: subBlockWidth - SUB_BLOCK_EDGE_WIDTH,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(const Radius.circular(3.0)),
        ),
      ),
    );
  }

  Widget drawBlocks() {
    if (block == null) return SizedBox(); // Trả về một widget rỗng

    List<Widget> subBlocks = []; // Sửa đổi kiểu dữ liệu thành List<Widget>

    // Block hiện tại
    block!.subBlocks.forEach((subBlock) {
      subBlocks.add(getPositionedSquareContainer(
          subBlock.color, subBlock.x + (block?.x ?? 0), subBlock.y + (block?.y ?? 0)));
    });

    // Các sub-block cũ
    oldSubBlocks.forEach((oldSubBlock) {
      subBlocks.add(getPositionedSquareContainer(
          oldSubBlock.color, oldSubBlock.x, oldSubBlock.y));
    });

    if (isGameOver) {
      subBlocks.add(getGameOverRect());
    }

    return Stack(
      children: subBlocks,
    );
  }

  Widget getGameOverRect() {
    // Tạo và trả về một widget hiển thị thông báo "Game Over"
    return Positioned(
      left: subBlockWidth * 1.0, // Vị trí từ trái của màn hình
      top: subBlockWidth * 6.0, // Vị trí từ trên của màn hình
      child: Container(
          width: subBlockWidth * 8.0, // Đặt chiều rộng cho container
          height: subBlockWidth * 7.0, // Đặt chiều cao cho container
          alignment: Alignment.center, // Căn giữa nội dung trong container
          decoration: BoxDecoration(
            color: Colors.red, // Màu nền là đỏ
            borderRadius: BorderRadius.all(Radius.circular(10.0)), // Bo tròn góc
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("GAME OVER", style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white,
              ),
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                  onPressed: () {
                    startGame();
                  },
                  child: Text("RESTART", style: TextStyle(fontSize: 20),))
            ],
          )
      ),

    );
  }

  @override
  @Deprecated(
    'Use KeyboardListener instead. '
        'This feature was deprecated after v3.18.0-2.0.pre.',
  )
  Widget build(BuildContext context) {
    // Xây dựng và trả về widget cho game
    return FocusScope(
      node: FocusScopeNode(),
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          // Xử lý sự kiện nhấn phím
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              action = BlockMovement.LEFT; // Di chuyển sang trái
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              action = BlockMovement.RIGHT; // Di chuyển sang phải
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              action = BlockMovement.ROTATE_CLOCKWISE; // Xoay khối
            }
          }
        },
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            // Xử lý sự kiện kéo ngang
            if (details.delta.dx > 0) {
              action = BlockMovement.RIGHT; // Kéo sang phải
            } else {
              action = BlockMovement.LEFT; // Kéo sang trái
            }
          },
          onTap: () {
            action = BlockMovement.ROTATE_CLOCKWISE; // Xoay khối khi tap
          },
          child: AspectRatio(
            aspectRatio: BLOCKS_X / BLOCKS_Y, // Tỉ lệ kích thước game
            child: Container(
              key: _keyGameArea, // Key cho khu vực game
              decoration: BoxDecoration(
                color: Colors.indigo[800], // Màu nền khu vực game
                border: Border.all(
                  width: GAME_AREA_BORDER_WIDTH, // Độ rộng đường viền
                  color: Colors.indigoAccent, // Màu đường viền
                ),
                borderRadius: BorderRadius.all(Radius.circular(10.0)), // Bo góc
              ),
              child: drawBlocks(), // Vẽ các khối trong game
            ),
          ),
        ),
      ),
    );
  }

}
