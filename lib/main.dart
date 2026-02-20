import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Premium Calculator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF17171C), // Deep dark background
        useMaterial3: true,
      ),
      home: const CalculatorHome(),
    );
  }
}

class CalculatorHome extends StatefulWidget {
  const CalculatorHome({super.key});

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String _expression = '';
  String _result = '0';

  // Function to handle button clicks
  void _onPressed(String text) {
    setState(() {
      if (text == 'C') {
        _expression = '';
        _result = '0';
      } else if (text == '=') {
        _calculateResult();
      } else if (['+', '-', '*', '/'].contains(text)) {
        // Handle multiple operators: replace last if already an operator
        if (_expression.isNotEmpty) {
          String lastChar = _expression[_expression.length - 1];
          if (['+', '-', '*', '/'].contains(lastChar)) {
            _expression = _expression.substring(0, _expression.length - 1) + text;
          } else {
            _expression += text;
          }
        }
      } else {
        // Numbers and decimal
        if (_expression == '0' && text != '.') {
          _expression = text;
        } else {
          _expression += text;
        }
      }
    });
  }

  void _calculateResult() {
    if (_expression.isEmpty) return;

    try {
      // Basic manual parsing for simplicity as requested (no external packages)
      double result = _evaluateSimpleExpression(_expression);
      
      if (result.isInfinite || result.isNaN) {
        _result = 'Error';
      } else {
        // Format result: remove .0 if it's an integer
        _result = result.toString().replaceAll(RegExp(r'\.0$'), '');
      }
    } catch (e) {
      _result = 'Error';
    }
  }

  // Simple sequential evaluator
  double _evaluateSimpleExpression(String expr) {
    final tokens = RegExp(r'(\d+\.?\d*)|([\+\-\*\/])').allMatches(expr).map((m) => m.group(0)!).toList();
    
    if (tokens.isEmpty) return 0;
    
    double total = double.tryParse(tokens[0]) ?? 0;
    
    for (int i = 1; i < tokens.length; i += 2) {
      if (i + 1 >= tokens.length) break;
      String op = tokens[i];
      double nextVal = double.tryParse(tokens[i + 1]) ?? 0;
      
      switch (op) {
        case '+': total += nextVal; break;
        case '-': total -= nextVal; break;
        case '*': total *= nextVal; break;
        case '/': 
          if (nextVal == 0) return double.infinity;
          total /= nextVal; 
          break;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Display Screen
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _expression,
                      style: const TextStyle(fontSize: 32, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _result,
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Buttons Grid
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF21212B),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    _buildRow(['C', '/', '*', '-']),
                    _buildRow(['7', '8', '9', '+']),
                    _buildRow(['4', '5', '6', '']), 
                    _buildRow(['1', '2', '3', '=']),
                    _buildRow(['0', '.', '']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> buttons) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buttons.map((btn) {
          if (btn.isEmpty) return Expanded(child: SizedBox());
          return _buildButton(btn);
        }).toList(),
      ),
    );
  }

  Widget _buildButton(String text) {
    bool isOperator = ['+', '-', '*', '/', '=', 'C'].contains(text);
    Color btnColor = text == 'C' 
        ? Colors.redAccent.withOpacity(0.2) 
        : (text == '=' ? Colors.blueAccent : Colors.transparent);
    Color textColor = text == 'C' 
        ? Colors.redAccent 
        : (isOperator ? Colors.blueAccent : Colors.white);

    if (text == '=') textColor = Colors.white;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          color: btnColor,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: () => _onPressed(text),
            borderRadius: BorderRadius.circular(24),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
