import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Regressão Linear',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Regressão Linear'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double sliderValue = 0.0;
  double? _resultado;
  Interpreter? _interpreter;

  @override
  void initState() {
    super.initState();
    carregarModelo();
  }

  Future<void> carregarModelo() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        "assets/model/linear_regression.tflite",
      );

      if (_interpreter != null) {
        _estimarValor(sliderValue);
      }
      setState(() {});
    } catch (e, stack) {
      print("Erro ao carregar modelo: $e");
      print(stack);
      setState(() => _interpreter = null);
    }
  }

  Future<double> previsao(double input) async {
    if (_interpreter == null) {
      return 0.0;
    }

    var w = [
      [input],
    ];
    var outp = List.filled(1 * 1, 0.0).reshape([1, 1]);
    _interpreter!.run(w, outp);
    return outp[0][0];
  }

  Future<void> _estimarValor(double input) async {
    if (_interpreter == null) return;
    final resultado = await previsao(input);
    setState(() => _resultado = resultado);
  }

  @override
  void dispose() {
    if (_interpreter != null) {
      _interpreter!.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isModeloPronto = _interpreter != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8EFF9),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Escolha um valor para a regressão linear",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 3,
              color: const Color(0xFFF1ECF4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Text(
                      "Input value: ${sliderValue.round().toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 17),
                    ),
                    const SizedBox(height: 2),
                    Slider(
                      value: sliderValue,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: sliderValue.toStringAsFixed(2),
                      onChanged: (v) {
                        setState(() {
                          sliderValue = v;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: isModeloPronto
                    ? () => _estimarValor(sliderValue)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  "Estimar valor",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 30),

            Card(
              elevation: 2,
              color: const Color(0xFFF1ECF4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "Resultado da Regressão: ",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      !isModeloPronto
                          ? "Carregando..."
                          : (_resultado == null
                                ? "Aguardando..."
                                : _resultado!.toStringAsFixed(2)),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
