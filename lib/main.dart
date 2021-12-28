import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}
// VoidCallback? onLongPress,

class Benchmark {
  String name;
  int iterations;
  int precision;
  Function method;

  Benchmark(this.name, this.iterations, this.precision, this.method);
}

class BenchmarkResult {
  String result;
  String duration;
  BenchmarkResult(this.result, this.duration);
}

double gaussLegendre(int iterations) {
  double a = 1.0;
  double b = 1.0 / sqrt(2);
  double t = 1.0 / 4.0;
  double p = 1.0;

  for (int i = 0; i < iterations; i++) {
    double aNext = (a + b) / 2;
    double bNext = sqrt(a * b);
    double tNext = t - p * pow(a - aNext, 2.0);
    double pNext = 2 * p;
    a = aNext;
    b = bNext;
    t = tNext;
    p = pNext;
  }
  return pow(a + b, 2) / (4 * t);
}

double getOneByPi(int k) {
  double ak = 6.0 - 4 * sqrt(2);
  double yk = sqrt(2) - 1.0;
  double ak1;
  double yk1;
  for (int i = 0; i < k; i++) {
    yk1 = (1 - pow((1 - yk * yk * yk * yk), (0.25))) /
        (1 + pow((1 - yk * yk * yk * yk), (0.25)));
    ak1 = ak * pow((1 + yk1), 4) -
        pow(2, 2 * i + 3) * yk1 * (1 + yk1 + yk1 * yk1);
    yk = yk1;
    ak = ak1;
  }
  return ak;
}

double factorial(int n) {
  if (n > 1) {
    return n * factorial(n - 1);
  } else {
    return 1;
  }
}

List<Benchmark> benchmarks = [
  Benchmark('Borwein', 1000, 100, getOneByPi),
  Benchmark('GaussLegendre', 1000, 100, gaussLegendre),
  Benchmark('RecursiveFactorial', 1000, 15, factorial)
];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, BenchmarkResult> benchmarkResults = {
    'Borwein': BenchmarkResult('', ''),
    'GaussLegendre': BenchmarkResult('', ''),
    'RecursiveFactorial': BenchmarkResult('', ''),
  };

  void startBenchmark() {
    for (var b in benchmarks) {
      Stopwatch stopwatch = Stopwatch()..start();
      String _res = '${b.method(b.precision)}';

      for (int i = 1; i < b.iterations; i++) {
        b.method(b.precision);
      }

      stopwatch.stop();
      var _benchmarkResults = {...benchmarkResults};
      _benchmarkResults[b.name] = BenchmarkResult(
          _res, '${stopwatch.elapsedMicroseconds.toDouble() / 1000}');

      setState(() {
        benchmarkResults = _benchmarkResults;
      });
    }
  }

  List<Widget> getChildren() {
    List<Widget> children = [];

    for (var b in benchmarks) {
      var column = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Algo: ${b.name}',
            style: Theme.of(context).textTheme.headline5,
          ),
          Text(
            'Iterations: ${b.iterations}',
          ),
          Text(
            'Precision: ${b.precision}',
          ),
          Text(
            'Result: ${benchmarkResults[b.name]?.result}',
          ),
          Text(
            'Duration ${benchmarkResults[b.name]?.duration}',
          ),
        ],
      );
      children.add(column);
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
                onPressed: startBenchmark,
                child: const Text('Start benchmarks')),
            ...getChildren()
          ],
        ),
      ),
    );
  }
}
