import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class RealTimeDateTime extends StatefulWidget {
  const RealTimeDateTime({super.key});

  @override
  _RealTimeDateTimeState createState() => _RealTimeDateTimeState();
}

class _RealTimeDateTimeState extends State<RealTimeDateTime> {
  late StreamController<DateTime> _streamController;
  late Stream<DateTime> _dateTimeStream;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<DateTime>();
    _dateTimeStream = _streamController.stream;

    // Update the date and time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!_streamController.isClosed) {
        _streamController.add(DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _streamController.close();
    _timer.cancel(); // Cancel the timer when disposing the widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _dateTimeStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          DateTime dateTime = snapshot.data!;
          String formattedDateTime =
              DateFormat.yMMMMd().add_jms().format(dateTime);

          return Text(
            'As of $formattedDateTime',
            style: GoogleFonts.poppins(),
          );
        } else {
          return Text('Loading...', style: GoogleFonts.poppins());
        }
      },
    );
  }
}
