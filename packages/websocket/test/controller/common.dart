import 'package:galileo_framework/galileo_framework.dart';
import 'package:galileo_websocket/server.dart';

class Game {
  final String playerOne, playerTwo;

  const Game({this.playerOne, this.playerTwo});

  factory Game.fromJson(Map data) =>
      Game(playerOne: data['playerOne'].toString(), playerTwo: data['playerTwo'].toString());

  Map<String, dynamic> toJson() {
    return {'playerOne': playerOne, 'playerTwo': playerTwo};
  }

  @override
  bool operator ==(other) => other is Game && other.playerOne == playerOne && other.playerTwo == playerTwo;
}

const Game johnVsBob = Game(playerOne: 'John', playerTwo: 'Bob');

@Expose('/game')
class GameController extends WebSocketController {
  GameController(GalileoWebSocket ws) : super(ws);

  @ExposeWs('search')
  search(WebSocketContext socket) async {
    print('User is searching for a game...');
    socket.send('searched', johnVsBob);
  }
}
