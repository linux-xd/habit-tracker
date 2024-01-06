import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:habit_tracker/theme/theme_provider.dart';

class MyHeatMap extends StatelessWidget {
  final DateTime startDate;
  final Map<DateTime, int> dataSets;
  const MyHeatMap({
    super.key,
    required this.startDate,
    required this.dataSets,
  });

  @override
  Widget build(BuildContext context) {
    return HeatMap(
      startDate: startDate,
      endDate: DateTime.now(),
      datasets: dataSets,
      colorMode: ColorMode.color,
      size: 30,
      defaultColor: Theme.of(context).colorScheme.secondary,
      textColor: ThemeProvider().isDarkMode
          ? Colors.white
          : Theme.of(context).colorScheme.inversePrimary,
      showColorTip: false,
      showText: true,
      scrollable: true,
      colorsets: {
        1: Colors.green.shade200,
        2: Colors.green.shade300,
        3: Colors.green.shade400,
        4: Colors.green.shade500,
        5: Colors.green.shade600,
      },
    );
  }
}
