import 'package:flutter/material.dart';
import 'package:gymbro/models/exercise.dart';
import 'package:gymbro/services/database_helper.dart';
import 'package:gymbro/screens/add_exercise_screen.dart'; // Will be created later
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart'; // For the heatmap
import 'package:intl/intl.dart'; // For date formatting
import 'package:home_widget/home_widget.dart'; // Import home_widget

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Exercise> _recentExercises = [];
  Map<DateTime, int> _heatmapData = {};
  int _currentStreak = 0;
  bool _hasExercisedToday = false;

  // Define a group ID for your widget updates
  // IMPORTANT: Make sure this matches the android:name in your <intent-filter> in AndroidManifest.xml for HomeWidget
  final String appGroupId =
      'group.com.example.gymbro.widget'; // Replace with your actual app group ID if needed
  final String iOSWidgetName =
      'StreakWidget'; // Name for iOS, if you plan to support it
  final String androidWidgetName =
      'StreakWidgetProvider'; // This should match the .kt file name

  @override
  void initState() {
    super.initState();
    HomeWidget.setAppGroupId(appGroupId);
    _loadScreenData();
  }

  Future<void> _updateWidget() async {
    try {
      await HomeWidget.saveWidgetData<int>('currentStreak', _currentStreak);
      await HomeWidget.saveWidgetData<bool>(
        'hasExercisedToday',
        _hasExercisedToday,
      );
      await HomeWidget.updateWidget(
        name: androidWidgetName, // Use 'name' for Android
        androidName: androidWidgetName,
        iOSName: iOSWidgetName,
      );
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  Future<void> _loadScreenData() async {
    await _loadRecentExercises();
    await _loadHeatmapData();
    await _calculateStreak();
    _hasExercisedToday = await _databaseHelper.hasExerciseForToday();
    if (mounted) {
      setState(() {});
    }
    await _updateWidget(); // Update widget after data is loaded
  }

  Future<void> _loadRecentExercises() async {
    _recentExercises = await _databaseHelper.getAllExercises();
    _recentExercises.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _loadHeatmapData() async {
    final allExercises =
        await _databaseHelper.getAllExercises(); // Get all exercises
    final Map<DateTime, int> activityCounts = {};

    for (var exercise in allExercises) {
      DateTime dateOnly = DateTime(
        exercise.date.year,
        exercise.date.month,
        exercise.date.day,
      );
      activityCounts.update(dateOnly, (count) => count + 1, ifAbsent: () => 1);
    }
    _heatmapData = activityCounts;
  }

  Future<void> _calculateStreak() async {
    final List<DateTime> uniqueDates =
        await _databaseHelper.getUniqueExerciseDates();
    if (uniqueDates.isEmpty) {
      _currentStreak = 0;
      return;
    }

    uniqueDates.sort((a, b) => b.compareTo(a)); // Sort in descending order

    int streak = 0;
    DateTime today = DateTime.now();
    DateTime todayDate = DateTime(today.year, today.month, today.day);
    DateTime yesterdayDate = todayDate.subtract(Duration(days: 1));

    bool hasExercisedToday = uniqueDates.any(
      (date) =>
          date.year == todayDate.year &&
          date.month == todayDate.month &&
          date.day == todayDate.day,
    );

    bool hasExercisedYesterday = uniqueDates.any(
      (date) =>
          date.year == yesterdayDate.year &&
          date.month == yesterdayDate.month &&
          date.day == yesterdayDate.day,
    );

    if (hasExercisedToday) {
      streak = 1;
      DateTime currentDate = todayDate;
      for (int i = 0; i < uniqueDates.length; i++) {
        DateTime exerciseDate = DateTime(
          uniqueDates[i].year,
          uniqueDates[i].month,
          uniqueDates[i].day,
        );
        if (exerciseDate.isAtSameMomentAs(currentDate)) {
          if (i > 0 && streak > 1)
            continue; // Already counted this date as part of streak
        } else if (exerciseDate.isAtSameMomentAs(
          currentDate.subtract(Duration(days: 1)),
        )) {
          streak++;
          currentDate = currentDate.subtract(Duration(days: 1));
        } else if (exerciseDate.isBefore(
          currentDate.subtract(Duration(days: 1)),
        )) {
          // Break if there's a gap
          break;
        }
      }
    } else if (hasExercisedYesterday) {
      // If no exercise today, but there was one yesterday, streak starts from yesterday
      streak = 1;
      DateTime currentDate = yesterdayDate;
      for (int i = 0; i < uniqueDates.length; i++) {
        DateTime exerciseDate = DateTime(
          uniqueDates[i].year,
          uniqueDates[i].month,
          uniqueDates[i].day,
        );
        if (exerciseDate.isAtSameMomentAs(currentDate)) {
          if (i > 0 && streak > 1) continue;
        } else if (exerciseDate.isAtSameMomentAs(
          currentDate.subtract(Duration(days: 1)),
        )) {
          streak++;
          currentDate = currentDate.subtract(Duration(days: 1));
        } else if (exerciseDate.isBefore(
          currentDate.subtract(Duration(days: 1)),
        )) {
          break;
        }
      }
    } else {
      streak = 0; // No exercise today or yesterday
    }
    _currentStreak = streak;
  }

  void _navigateToAddExerciseScreen() async {
    print("Navigating to Add Exercise Screen");

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddExerciseScreen()),
    );
    if (result == true) {
      // Check if an exercise was added
      _loadScreenData(); // Reload data if an exercise was added
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/gymbro_text.png'
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add Exercise',
            onPressed: _navigateToAddExerciseScreen,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadScreenData,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            _buildStreakCounter(),
            SizedBox(height: 20.0),
            Text(
              'Activity Heatmap',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 10.0),
            _buildHeatmap(),
            SizedBox(height: 20.0),
            Text(
              'Recent Exercises',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 10.0),
            _buildRecentExercisesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCounter() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final activeColor = Colors.orange;
    final inactiveColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_fire_department,
              color: _hasExercisedToday ? activeColor : inactiveColor,
              size: 30,
            ),
            SizedBox(width: 10),
            Text(
              '$_currentStreak Day Streak',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color:
                    _hasExercisedToday
                        ? (isDarkMode ? Colors.white : Colors.black)
                        : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmap() {
    if (_heatmapData.isEmpty && _recentExercises.isEmpty) {
      // Show message if no data at all
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Center(
          child: Text('Log your first exercise to see your activity heatmap!'),
        ),
      );
    }
    if (_heatmapData.isEmpty && _recentExercises.isNotEmpty) {
      // Show message if exercises exist but not processed for heatmap yet (edge case)
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Center(
          child: Text(
            'Processing heatmap... Pull to refresh if it doesn\'t appear.',
          ),
        ),
      );
    }

    // Get the current theme
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: HeatMapCalendar(
        // Ensure _heatmapData keys are DateTime objects at midnight for correct day mapping
        datasets: _heatmapData.map(
          (key, value) =>
              MapEntry(DateTime(key.year, key.month, key.day), value),
        ),
        // colorsets defines the color intensity for the heatmap squares
        colorsets: {
          1: Colors.green.shade200, // For 1 activity
          2: Colors.green.shade400,
          3: Colors.green.shade600,
          5: Colors.green.shade800, // For 5 or more activities
        },
        defaultColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
        textColor: isDarkMode ? Colors.white70 : Colors.black87,
        monthFontSize: 16,
        weekTextColor: isDarkMode ? Colors.white54 : Colors.black54,
        weekFontSize: 10,
        fontSize: 10,
        borderRadius: 5,
        // Sizing options
        size: 20, // Size of each heatmap square
        // margin: EdgeInsets.all(1.5), // Margin between squares

        // Optional: Customize further
        showColorTip: true, // Shows a color legend
        colorTipCount: 4,
        colorTipSize: 10,
        colorTipHelper: [
          // Text for the color tip legend
          Text(
            "Less ",
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontSize: 10,
            ),
          ),
          Text(
            " More",
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontSize: 10,
            ),
          ),
        ],
        onClick: (date) {
          print('Date clicked on heatmap: $date');
          // You could potentially filter the _recentExercises list
          // or navigate to a day-specific view here.
          // For example, show a dialog with exercises for that day:
          _showExercisesForDate(date);
        },
      ),
    );
  }

  void _showExercisesForDate(DateTime date) async {
    // Fetch exercises specifically for this date to show in a dialog
    // The date from heatmap might have time, normalize it
    DateTime normalizedDate = DateTime(date.year, date.month, date.day);
    List<Exercise> exercisesOnDate = await _databaseHelper.getExercisesByDate(
      normalizedDate,
    );

    if (!mounted) return; // Check if the widget is still in the tree

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Exercises on ${DateFormat.yMd().format(normalizedDate)}',
            ),
            content: SizedBox(
              width: double.maxFinite,
              child:
                  exercisesOnDate.isEmpty
                      ? Text('No exercises logged for this day.')
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: exercisesOnDate.length,
                        itemBuilder: (context, index) {
                          final exercise = exercisesOnDate[index];
                          String details = '';
                          if (exercise.duration != null) {
                            details += '${exercise.duration} min';
                          }
                          if (exercise.reps != null) {
                            if (details.isNotEmpty) details += ' / ';
                            details += '${exercise.reps} reps';
                          }
                          return ListTile(
                            title: Text(exercise.name),
                            subtitle: Text(
                              details.isNotEmpty
                                  ? details
                                  : (exercise.notes ?? 'No details'),
                            ),
                          );
                        },
                      ),
            ),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  Widget _buildRecentExercisesList() {
    if (_recentExercises.isEmpty) {
      return Center(child: Text('No exercises logged yet. Tap + to add one!'));
    }
    return ListView.builder(
      shrinkWrap: true, // Important for ListView inside another ListView
      physics:
          NeverScrollableScrollPhysics(), // Disable scrolling for this inner list
      itemCount: _recentExercises.length,
      itemBuilder: (context, index) {
        final exercise = _recentExercises[index];
        // final formattedDate = DateFormat.yMMMd().add_jm().format(exercise.date);
        final formattedDate =
            "${exercise.date.toLocal()}".split(' ')[0]; // Simpler date
        String details = '';
        if (exercise.duration != null) {
          details += '${exercise.duration} min';
        }
        if (exercise.reps != null) {
          if (details.isNotEmpty) details += ' / ';
          details += '${exercise.reps} reps';
        }

        return Card(
          margin: EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            title: Text(
              exercise.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '$formattedDate\n${details.isNotEmpty ? details : (exercise.notes ?? '')}',
            ),
            isThreeLine:
                details.isNotEmpty &&
                (exercise.notes != null && exercise.notes!.isNotEmpty),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.copy, color: Colors.blueAccent),
                  tooltip: 'Copy exercise',
                  onPressed: () => _copyExerciseToAddScreen(exercise),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () async {
                    if (exercise.id != null) {
                      await _databaseHelper.deleteExercise(exercise.id!);
                      _loadScreenData(); // Refresh the list
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _copyExerciseToAddScreen(Exercise exercise) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddExerciseScreen(
              prefilledExercise: Exercise(
                name: exercise.name,
                date: DateTime.now(), // Set to today
                duration: exercise.duration,
                reps: exercise.reps,
                notes: exercise.notes,
              ),
            ),
      ),
    );

    if (result == true) {
      _loadScreenData(); // Refresh if an exercise was added
    }
  }
}
