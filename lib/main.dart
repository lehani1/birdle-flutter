import 'package:flutter/material.dart';
import 'game.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  bool get _isDarkMode => _themeMode == ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _isDarkMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Align(alignment: Alignment.centerLeft, child: Text("Birdle")),
          actions: [
            IconButton(
              tooltip: _isDarkMode
                  ? 'Switch to light mode'
                  : 'Switch to dark mode',
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
            ),
          ],
        ),
        body: Align(alignment: Alignment.center, child: GamePage()),
      ),
    );
  }
}

class Tile extends StatelessWidget {
  const Tile(this.letter, this.hitType, {super.key});

  final String letter;
  final HitType hitType;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.bounceIn,
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        color: switch (hitType) {
          HitType.hit => Colors.green,
          HitType.partial => Colors.yellow,
          HitType.miss => Colors.grey,
          _ => colorScheme.surfaceContainerHighest,
        },
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Game _game = Game();

  bool get _isGameOver => _game.didWin || _game.didLose;

  String get _statusMessage {
    if (_game.didWin) return 'You won!';
    if (_game.didLose) return 'Game over! The word was: "${_game.hiddenWord}"';
    return '';
  }

  void _restartGame() {
    setState(_game.resetGame);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: 5.0,
            children: [
              for (final guess in _game.guesses)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5.0,
                  children: [
                    for (final letter in guess) Tile(letter.char, letter.type),
                  ],
                ),
              if (_isGameOver) ...[
                GameStatus(message: _statusMessage),
                FilledButton.icon(
                  onPressed: _restartGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Play again'),
                ),
              ] else
                GuessInput(
                  onSubmitGuess: (String guess) {
                    if (!_game.isLegalGuess(guess)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter a five-letter word'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _game.guess(guess);
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameStatus extends StatelessWidget {
  const GameStatus({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class GuessInput extends StatelessWidget {
  GuessInput({super.key, required this.onSubmitGuess});

  final void Function(String) onSubmitGuess;

  final TextEditingController _textEditingController = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  void _onSubmit() {
    onSubmitGuess(_textEditingController.text.trim());
    _textEditingController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              maxLength: 5,
              decoration: InputDecoration(
                // counterText: "Start typing...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(35)),
                ),
                labelText: "Start guessing...",
              ),
              controller: _textEditingController,
              autofocus: true,
              onSubmitted: (_) {
                _onSubmit();
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.arrow_circle_up, size: 40.0),
            onPressed: _onSubmit,
          ),
        ),
      ],
    );
  }
}
