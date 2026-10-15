import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

/// Point d'entrée et thème général de l'application.
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculatrice',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '';
  String _display = '0';
  String? _error;
  bool _resultShown = false;

  // Disposition du clavier. Le zéro occupe deux colonnes sur la dernière ligne.
  static const List<List<String>> _rows = [
    ['C', '%', '÷', '×'],
    ['7', '8', '9', '−'],
    ['4', '5', '6', '+'],
    ['1', '2', '3', '='],
    ['0', '.', '⌫'],
  ];

  void _onPressed(String key) {
    setState(() {
      if (key == 'C') {
        _clear();
      } else if (key == '⌫') {
        _deleteLast();
      } else if (key == '=') {
        _calculate();
      } else if (_isOperator(key)) {
        _addOperator(key);
      } else if (key == '.') {
        _addDecimalPoint();
      } else {
        _addDigit(key);
      }
    });
  }

  bool _isOperator(String value) =>
      value == '+' || value == '−' || value == '×' || value == '÷' || value == '%';

  String _normalise(String expression) {
    return expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-');
  }

  void _clear() {
    _expression = '';
    _display = '0';
    _error = null;
    _resultShown = false;
  }

  void _addDigit(String digit) {
    _error = null;

    // Après un résultat, un chiffre commence un nouveau calcul.
    if (_resultShown) {
      _expression = '';
      _display = '0';
      _resultShown = false;
    }

    if (_expression == '0') {
      _expression = digit;
    } else {
      _expression += digit;
    }
    _display = _expression;
  }

  void _addDecimalPoint() {
    _error = null;
    if (_resultShown) {
      _expression = '';
      _display = '0';
      _resultShown = false;
    }

    // Un point décimal ne peut apparaître qu'une fois dans le nombre courant.
    final currentNumber = _currentNumber(_expression);
    if (currentNumber.contains('.')) return;

    if (_expression.isEmpty || _isOperator(_expression.characters.last)) {
      _expression += '0.';
    } else {
      _expression += '.';
    }
    _display = _expression;
  }

  String _currentNumber(String expression) {
    if (expression.isEmpty) return '';
    final parts = expression.split(RegExp(r'[+\-×÷%]'));
    return parts.isEmpty ? '' : parts.last;
  }

  void _addOperator(String op) {
    _error = null;
    if (_expression.isEmpty) {
      // Autorise un nombre négatif au début de l'expression.
      if (op == '−') {
        _expression = '−';
        _display = _expression;
      }
      return;
    }

    if (_resultShown) {
      // Après un résultat, un opérateur poursuit le calcul à partir du résultat.
      _expression = _display;
      _resultShown = false;
    }

    final last = _expression.characters.last;
    if (_isOperator(last)) {
      // Remplace l'opérateur précédent au lieu d'empiler des opérateurs.
      _expression = _expression.substring(0, _expression.length - 1) + op;
    } else if (last == '.') {
      // Termine proprement un nombre écrit comme « 12. ».
      _expression += '0$op';
    } else {
      _expression += op;
    }
    _display = _expression;
  }

  void _deleteLast() {
    _error = null;
    if (_resultShown) {
      _clear();
      return;
    }
    if (_expression.isNotEmpty) {
      _expression = _expression.substring(0, _expression.length - 1);
    }
    _display = _expression.isEmpty ? '0' : _expression;
  }

  void _calculate() {
    if (_expression.isEmpty) return;

    try {
      final cleaned = _expression;
      if (_isOperator(cleaned.characters.last) || cleaned.endsWith('.')) {
        _error = 'Expression incomplète';
        return;
      }

      final result = _ExpressionParser(_normalise(cleaned)).parse();
      if (!result.isFinite) {
        _error = 'Résultat non défini';
        return;
      }

      // Conserve l'opération en petit et affiche le résultat en grand.
      _display = _formatResult(result);
      _expression = cleaned;
      _error = null;
      _resultShown = true;
    } on FormatException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Calcul impossible';
    }
  }

  String _formatResult(double value) {
    // Évite les affichages comme 4.0 et limite les erreurs d'arrondi visibles.
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsPrecision(10).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  Color _buttonColor(String label) {
    if (label == '=') return const Color(0xFFFF9500);
    if (label == 'C' || label == '%' || label == '÷' || label == '×' ||
        label == '−' || label == '+') {
      return const Color(0xFF505050);
    }
    return const Color(0xFF242424);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final maxCalculatorWidth = isWide ? 520.0 : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxCalculatorWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 24 : 16,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      // Zone d'affichage : elle prend l'espace restant en haut.
                      Expanded(
                        flex: 4,
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.bottomRight,
                          padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _expression.isEmpty ? ' ' : _expression,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _error ?? _display,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: _error == null
                                        ? Colors.white
                                        : Colors.redAccent,
                                    fontSize: 58,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Clavier : les boutons se redimensionnent avec l'écran.
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            for (int rowIndex = 0; rowIndex < _rows.length; rowIndex++)
                              Expanded(
                                child: Row(
                                  children: [
                                    for (int colIndex = 0;
                                        colIndex < _rows[rowIndex].length;
                                        colIndex++)
                                      Expanded(
                                        flex: rowIndex == 4 &&
                                                _rows[rowIndex][colIndex] == '0'
                                            ? 2
                                            : 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: _buildButton(_rows[rowIndex][colIndex]),
                                        ),
                                      ),
                                    // Espace visuel pour garder la grille alignée.
                                    if (rowIndex == 4)
                                      const Expanded(child: SizedBox()),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildButton(String label) {
    final isEquals = label == '=';
    return SizedBox.expand(
      child: Material(
        color: _buttonColor(label),
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () => _onPressed(label),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: isEquals ? 32 : 27,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Analyse et calcule une expression avec la priorité ×, ÷ et % sur + et -.
/// Le parseur est écrit en Dart pour éviter une dépendance externe.
class _ExpressionParser {
  _ExpressionParser(this.input);

  final String input;
  int _index = 0;

  double parse() {
    final result = _parseAdditionSubtraction();
    if (_index != input.length) {
      throw const FormatException('Expression invalide');
    }
    return result;
  }

  double _parseAdditionSubtraction() {
    var value = _parseMultiplicationDivisionModulo();

    while (_index < input.length) {
      final op = input[_index];
      if (op != '+' && op != '-') break;
      _index++;
      final right = _parseMultiplicationDivisionModulo();
      value = op == '+' ? value + right : value - right;
    }
    return value;
  }

  double _parseMultiplicationDivisionModulo() {
    var value = _parseNumber();

    while (_index < input.length) {
      final op = input[_index];
      if (op != '*' && op != '/' && op != '%') break;
      _index++;
      final right = _parseNumber();

      if ((op == '/' || op == '%') && right == 0) {
        throw const FormatException('Division par zéro');
      }

      if (op == '*') {
        value *= right;
      } else if (op == '/') {
        value /= right;
      } else {
        value %= right;
      }
    }
    return value;
  }

  double _parseNumber() {
    var sign = 1.0;
    if (_index < input.length && (input[_index] == '-' || input[_index] == '+')) {
      if (input[_index] == '-') sign = -1.0;
      _index++;
    }

    final start = _index;
    var dotCount = 0;
    while (_index < input.length) {
      final char = input[_index];
      if (char == '.') {
        dotCount++;
        if (dotCount > 1) throw const FormatException('Nombre décimal invalide');
        _index++;
      } else if (RegExp(r'[0-9]').hasMatch(char)) {
        _index++;
      } else {
        break;
      }
    }

    if (start == _index) throw const FormatException('Nombre attendu');

    final number = double.tryParse(input.substring(start, _index));
    if (number == null) throw const FormatException('Nombre invalide');
    return sign * number;
  }
}
