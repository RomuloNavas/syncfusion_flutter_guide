import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:developer';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      showPerformanceOverlay: true,
      title: 'Syncfusion Guide',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  late Timer timer;

  @override
  void initState() {
    super.initState();

    // timer = Timer.periodic(
    //     const Duration(milliseconds: 50), (timer) => _addAndRemove(40));
  }

  /// Specifies the list of chart sample data.
  List<ChartSampleData> chartData = <ChartSampleData>[];

  /// Creates an instance of random to generate the random number.
  final math.Random random = math.Random();

  late ChartSeriesController _chartSeriesController;

  /// `xValueCounter` will determinate the x values on the chart.
  int xValueCounter = 0;

  /// Get the random value.
  num _getRandomInt(int min, int max) {
    return min + random.nextInt(max - min);
  }

  void _addDataPoint() {
    // final int length = chartData.length;
    final int length = xValueCounter;
    chartData.add(ChartSampleData(x: length, y: _getRandomInt(10, 20)));
    _chartSeriesController.updateDataSource(
      addedDataIndexes: <int>[chartData.length - 1],
    );
    xValueCounter++;
  }

  /// Remove the data point from the series.
  void _removeLast() {
    if (chartData.isNotEmpty) {
      chartData.removeLast(); // chartData.removeAt(chartData.length - 1);
      _chartSeriesController.updateDataSource(
        updatedDataIndexes: <int>[chartData.length - 1],
        removedDataIndexes: <int>[chartData.length - 1],
      );
      xValueCounter--;
    }
  }

  /// Remove the data point from the series.
  void _removeFirst() {
    if (chartData.isNotEmpty) {
      chartData.removeAt(0);
      _chartSeriesController.updateDataSource(
        removedDataIndexes: <int>[0],
        updatedDataIndexes: <int>[0],
      );
      // xValueCounter--; //!It should not decrease the value of xValueCounter. Otherwise, when you add values, you will start adding from the deleted xValues, not from the last one.
    }
  }

  /// Method to add new data points to the chart source.
  void _addMultipleValues({required int quantity}) {
    if (chartData.isNotEmpty) {
      for (int i = 0; i < quantity; i++) {
        chartData
            .add(ChartSampleData(x: xValueCounter, y: _getRandomInt(10, 20)));

        ///  Could have updated here, but, is better to do it after the loop.
        // _chartSeriesController.updateDataSource(
        //   addedDataIndexes: <int>[chartData.length - 1],
        // );
        xValueCounter++;
      }

      /// Returns the newly added indexes value.
      final List<int> indexes = <int>[];
      for (int i = quantity - 1; i >= 0; i--) {
        indexes.add(chartData.length - 1 - i);
      }

      /// Update chart
      _chartSeriesController.updateDataSource(
        addedDataIndexes: indexes,
      );
    }
  }

  void _removeMultipleValues({required int quantity}) {
    if (chartData.length > quantity) {
      chartData.removeRange(0, quantity);
      List<int> removedIndexes = List.generate(quantity, (index) => index);
      _chartSeriesController.updateDataSource(
        removedDataIndexes: removedIndexes,
        updatedDataIndexes: removedIndexes,
      );
    }
  }

  void _addAndRemove(quantity) {
    if (chartData.length == 160) {
      chartData.removeRange(0, quantity);
      for (int i = 0; i < quantity; i++) {
        chartData
            .add(ChartSampleData(x: xValueCounter, y: _getRandomInt(10, 20)));
        //  While bigger is the chart (the space that the y values use in the area), the more will be the raster (worse performance)
        // with a 20valueMax/100areaMax graphic, the raster is 17ms  (+gradient)
        // with a 20valueMax/60areaMax graphic, the raster is 22ms (+gradient)
        // with a 20valueMax/20areaMax graphic, the raster is 33ms (+gradient)
        //gradient affects in just a couple of ms (1-4)ms
        xValueCounter++;
      }

      final List<int> indexes = <int>[];
      for (int i = quantity - 1; i >= 0; i--) {
        indexes.add(chartData.length - 1 - i);
      }
      List<int> removedIndexes = List.generate(quantity, (index) => index);

      _chartSeriesController.updateDataSource(
        removedDataIndexes: removedIndexes,
        addedDataIndexes: indexes,
        updatedDataIndexes: removedIndexes,
      );
    } else {
      _addDataPoint();
      // _addMultipleValues(quantity: quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    child: const Text('Add 30 values'),
                    onPressed: () => _addMultipleValues(quantity: 20)),
                TextButton(
                  child: const Text('Remove 30 values'),
                  onPressed: () => _removeMultipleValues(quantity: 20),
                ),
                IconButton(
                    onPressed: () => _addDataPoint(),
                    icon: const Icon(Icons.add)),
                TextButton(
                    onPressed: () => _removeFirst(),
                    child: const Text('Remove first')),
                TextButton(
                    onPressed: () => _removeLast(),
                    child: const Text('Remove last')),
                TextButton(
                  onPressed: () => _addAndRemove(20),
                  child: const Text('Add and remove'),
                ),
              ],
            ),
            Center(
              child: Container(
                height: 500,
                width: MediaQuery.of(context).size.width - 32,
                decoration: const BoxDecoration(color: Color(0xffD5E6F2)),
                child: SfCartesianChart(
                  margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),

                  title: ChartTitle(
                    alignment: ChartAlignment.near,
                    text: 'Chart',
                  ),
                  series: <CartesianSeries>[
                    AreaSeries<ChartSampleData, num>(
                      onRendererCreated:
                          (ChartSeriesController chartSeriesController) {
                        _chartSeriesController = chartSeriesController;
                      },
                      dataSource: chartData,
                      xValueMapper: (ChartSampleData data, _) => data.x,
                      yValueMapper: (ChartSampleData data, _) => data.y,
                      borderColor: Colors.blueAccent.shade400,
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue.shade800,
                            Colors.blue.shade300,
                            Colors.blue.shade100
                          ]),
                      borderWidth: 3,
                    ),
                  ],
                  primaryXAxis: NumericAxis(
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                    isVisible: false,
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    maximum: 60,
                    isVisible: false,
                    labelFormat: '',
                    // labelStyle: TextStyle(color: Colors.transparent),
                    rangePadding: ChartRangePadding.none,
                  ),

                  borderColor: const Color(0xffF2F3F5), //frame of widgetƑ
                  backgroundColor:
                      const Color(0xffF2F3F5), // Background of frame
                  plotAreaBackgroundColor:
                      const Color(0xffF2F3F5), // main background
                  plotAreaBorderColor: const Color(
                      0xff7a7575), // Thick line, the last one at the top
                  borderWidth: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartSampleData {
  ChartSampleData({required this.x, required this.y});
  num x;
  num y;
}
