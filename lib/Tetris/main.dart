import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'score_bar.dart';
import 'game.dart';
import 'next_block.dart';
import 'block.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (context) => Data(),
    child: MyApp(),
  ),
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartPage(),
    );
  }
}
class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('START GAME'),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Khi nút được nhấn, điều hướng đến trang Tetris
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Tetris()),
            );
          },
          child: Text('START GAME'),
        ),
      ),
    );
  }
}

class Tetris extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TetrisState();
}

class _TetrisState extends State<Tetris> {
  GlobalKey<GameState> _keyGame = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TETRIS'),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
      ),
      backgroundColor: Colors.indigo,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ScoreBar(),
            Expanded(
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 10.0),
                        child: Game(key: _keyGame),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            // Widget hiển thị thời gian
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Consumer<Data>(
                                builder: (context, data, child) => Container(
                                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo[700], // Màu nền của container
                                    borderRadius: BorderRadius.circular(10.0), // Bo tròn góc
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5), // Màu bóng
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: Offset(0, 2), // Thay đổi vị trí của bóng
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'Time: ${data.playTime} s',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold, // Đặt chữ đậm
                                      shadows: [
                                        Shadow( // Hiệu ứng bóng cho văn bản
                                          blurRadius: 2.0,
                                          color: Colors.black.withOpacity(0.5),
                                          offset: Offset(1.0, 1.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Widget NextBlock như cũ
                            NextBlock(),
                            SizedBox(
                              height: 20,
                            ),
                            // Nút bắt đầu/kết thúc game
                            ElevatedButton(
                              child: Text(
                                Provider.of<Data>(context).isPlaying ? 'End' : 'Start',
                                style: TextStyle(
                                  fontSize: 10, // Điều chỉnh kích thước phù hợp
                                  color: Colors.grey[200],
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo[700],
                              ),
                              onPressed: () {
                                if (Provider.of<Data>(context, listen: false).isPlaying) {
                                  _keyGame.currentState?.endGame();
                                } else {
                                  _keyGame.currentState?.startGame();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Thêm phần này cho các nút điều khiển dưới cùng
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Colors.white,
                    iconSize: 36, // Kích thước của biểu tượng
                    padding: EdgeInsets.all(8), // Khoảng cách xung quanh biểu tượng
                    onPressed: () => _keyGame.currentState?.move(BlockMovement.LEFT),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_downward),
                    color: Colors.white,
                    iconSize: 36, // Kích thước của biểu tượng
                    padding: EdgeInsets.all(8), // Khoảng cách xung quanh biểu tượng
                    onPressed: () => _keyGame.currentState?.move(BlockMovement.DOWN),
                  ),
                  IconButton(
                    icon: Icon(Icons.rotate_right),
                    color: Colors.white,
                    iconSize: 36, // Kích thước của biểu tượng
                    padding: EdgeInsets.all(8), // Khoảng cách xung quanh biểu tượng
                    onPressed: () => _keyGame.currentState?.move(BlockMovement.ROTATE_CLOCKWISE),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    color: Colors.white,
                    iconSize: 36, // Kích thước của biểu tượng
                    padding: EdgeInsets.all(8), // Khoảng cách xung quanh biểu tượng
                    onPressed: () => _keyGame.currentState?.move(BlockMovement.RIGHT),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class Data with ChangeNotifier {
  int score = 0;
  bool isPlaying = false;
  Block? nextBlock;

  void setScore(int score) {
    this.score = score;
    notifyListeners();
  }

  void addScore(int score) {
    this.score += score;
    notifyListeners();
  }

  void setIsPlaying(bool isPlaying) {
    this.isPlaying = isPlaying;
    notifyListeners();
  }

  void setNextBlock(Block nextBlock) {
    this.nextBlock = nextBlock;
    notifyListeners();
  }

  int playTime = 0; // Thời gian chơi tính bằng giây

  // Phương thức để cập nhật thời gian chơi
  void updatePlayTime() {
    playTime++;
    notifyListeners();
  }

  // Reset thời gian chơi khi bắt đầu game mới
  void resetPlayTime() {
    playTime = 0;
    notifyListeners();
  }

  Widget getNextBlockWidget() {
    if (!isPlaying || nextBlock == null) return Container();

    var width = nextBlock!.width;
    var height = nextBlock!.height;
    var color;

    List<Widget> columns = [];
    for (var y = 0; y < height; ++y) {
      List<Widget> rows = [];
      for (var x = 0; x < width; ++x) {
        if (nextBlock!.subBlocks.where((subBlock) => subBlock.x == x && subBlock.y == y).length > 0) {
          color = nextBlock!.color;
        } else {
          color = Colors.transparent;
        }

        rows.add(Container(width: 12, height: 12, color: color));
      }

      columns.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: rows));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: columns,
    );
  }
}
