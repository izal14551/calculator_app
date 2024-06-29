import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math';
import 'package:intl/intl.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpleCalculator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.brown,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = '';
  String _expression = '';
  bool _isExpanded = false;
  bool _isNewCalculation = false;

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'AC') {
        _output = '';
        _expression = '';
        _isNewCalculation = false;
      } else if (buttonText == '=') {
        try {
          String finalExpression = _expression
              .replaceAll('×', '*')
              .replaceAll('÷', '/')
              .replaceAll('%', '*0.01');
          Expression exp = Parser().parse(finalExpression);
          ContextModel cm = ContextModel();
          double result = exp.evaluate(EvaluationType.REAL, cm);
          _output = _formatResult(result);
          _expression = _output;
          _isNewCalculation = true;
        } catch (e) {
          _output = 'Error';
          _isNewCalculation = true;
        }
      } else if (buttonText == '√' ||
          buttonText == 'x²' ||
          buttonText == 'sin' ||
          buttonText == 'cos' ||
          buttonText == 'tan' ||
          buttonText == '!') {
        try {
          double value;
          if (_expression.isEmpty) {
            value = 0.0;
          } else {
            value = double.parse(_expression.replaceAll(',', ''));
          }
          double result;
          if (buttonText == '√') {
            result = sqrt(value);
          } else if (buttonText == 'x²') {
            result = pow(value, 2) as double;
          } else if (buttonText == 'sin') {
            result = sin(value);
          } else if (buttonText == 'cos') {
            result = cos(value);
          } else if (buttonText == 'tan') {
            result = tan(value);
          } else if (buttonText == '!') {
            result = _factorial(value.toInt());
          } else {
            result = 0.0;
          }
          _output = _formatResult(result);
          _expression = _output;
          _isNewCalculation = true;
        } catch (e) {
          _output = 'Error';
          _isNewCalculation = true;
        }
      } else if (buttonText == 'π') {
        if (_isNewCalculation) {
          _expression = '';
          _isNewCalculation = false;
        }
        _expression += pi.toString();
        _output = _expression;
      } else if (buttonText == 'e') {
        if (_isNewCalculation) {
          _expression = '';
          _isNewCalculation = false;
        }
        _expression += e.toString();
        _output = _expression;
      } else if (buttonText == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _output = _formatNumber(_expression);
        }
      } else if (buttonText == '()') {
        int openParentheses = _expression.split('(').length - 1;
        int closeParentheses = _expression.split(')').length - 1;
        if (openParentheses > closeParentheses) {
          _expression += ')';
        } else {
          _expression += '(';
        }
        _output = _expression;
      } else if (buttonText == '%') {
        try {
          if (_expression.isNotEmpty) {
            double value = double.parse(_expression.replaceAll(',', ''));
            double result = value * 0.01;
            _output = _formatResult(result);
            _expression = _output;
            _isNewCalculation = true;
          }
        } catch (e) {
          _output = 'Error';
          _isNewCalculation = true;
        }
      } else {
        if (_isNewCalculation) {
          if (RegExp(r'[\d.]').hasMatch(buttonText)) {
            _expression = '';
          }
          _isNewCalculation = false;
        }
        if (_expression.endsWith('(') && RegExp(r'[\d.]').hasMatch(buttonText)) {
          _expression += buttonText;
        } else {
          _expression += buttonText;
        }
        _output = _expression;
      }
    });
  }

  double _factorial(int n) {
    if (n < 0) return double.nan; // Faktorial tidak terdefinisi untuk bilangan negatif
    return n == 0 ? 1 : n * _factorial(n - 1);
  }

  String _formatResult(double result) {
    NumberFormat numberFormat = NumberFormat("#,##0.###");
    return numberFormat.format(result);
  }

  String _formatNumber(String number) {
    NumberFormat numberFormat = NumberFormat("#,##0");
    return numberFormat.format(double.tryParse(number.replaceAll(',', '')) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SimpleCalculator'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.centerRight,
              child: Text(
                _output,
                style: const TextStyle(
                  fontSize: 48.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _buildTopRow(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? 200 : 0,
            child: _isExpanded ? _buildAdditionalButtons() : null,
          ),
          Expanded(
            flex: 3,
            child: _buildButtons(_basicButtonNames),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      children: [
        _buildCustomButton('√'),
        _buildCustomButton('π'),
        _buildCustomButton('^'),
        _buildCustomButton('!'),
        
              IconButton(
          icon: Icon(
            _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCustomButton(String buttonText, {bool isDropdown = false}) {
    return Expanded(
      child: CalculatorButton(
        buttonText: buttonText,
        callback: _onButtonPressed,
        isTransparent: true,
        isDropdown: isDropdown,
        onDropdownPressed: isDropdown
            ? () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              }
            : null,
      ),
    );
  }

  Widget _buildButtons(List<String> buttonNames) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double buttonHeight = constraints.maxHeight / 6;
        double buttonWidth = constraints.maxWidth / 4;
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: buttonNames.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: buttonWidth / buttonHeight,
          ),
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              height: buttonHeight,
              width: buttonWidth,
              child: CalculatorButton(
                buttonText: buttonNames[index],
                callback: _onButtonPressed,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAdditionalButtons() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _additionalButtonNames.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      ),
      itemBuilder: (BuildContext context, int index) {
        return CalculatorButton(
          buttonText: _additionalButtonNames[index],
          callback: _onButtonPressed,
          isTransparent: true,
        );
      },
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String buttonText;
  final Function(String) callback;
  final bool isTransparent;
  final bool isDropdown;
  final VoidCallback? onDropdownPressed;

  const CalculatorButton({
    required this.buttonText,
    required this.callback,
    this.isTransparent = false,
    this.isDropdown = false,
    this.onDropdownPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1.0),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor:
              isTransparent ? Colors.transparent : _getButtonColor(buttonText),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        onPressed: isDropdown ? onDropdownPressed : () => callback(buttonText),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getButtonColor(String buttonText) {
    if (buttonText == 'AC') {
      return Colors.green;
    } else if (buttonText == '⌫') {
      return Colors.red;
    } else if (buttonText == '√' ||
        buttonText == 'π' ||
        buttonText == '^' ||
        buttonText == '!' ||
        buttonText == '%' ||
        buttonText == '÷' ||
        buttonText == '×' ||
        buttonText == '-' ||
        buttonText == '+' ||
        buttonText == '=') {
      return Colors.brown.shade700;
    } else {
      return Colors.brown.shade900;
    }
  }
}

final List<String> _basicButtonNames = [
  'AC', '()', '%', '÷',
  '7', '8', '9', '×',
  '4', '5', '6', '-',
  '1', '2', '3', '+',
  '0', ',', '⌫', '=',
];

final List<String> _additionalButtonNames = [
  'sin', 'cos', 'tan', 'x²', 'e'
];
