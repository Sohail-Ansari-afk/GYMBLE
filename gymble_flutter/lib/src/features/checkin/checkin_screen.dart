import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  bool _isCheckedIn = false;
  DateTime _selectedDateTime = DateTime.now();
  final List<Map<String, dynamic>> _recentCheckins = [
    {'date': '2023-06-01', 'time': '09:30 AM'},
    {'date': '2023-05-29', 'time': '10:15 AM'},
    {'date': '2023-05-27', 'time': '08:45 AM'},
  ];

  void _showTimePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('Confirm'),
                    onPressed: () {
                      setState(() {
                        _isCheckedIn = true;
                      });
                      Navigator.of(context).pop();
                      _showSuccessAlert();
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: _selectedDateTime,
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      _selectedDateTime = newDateTime;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessAlert() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Check-in Successful'),
        content: Text(
          'You have successfully checked in at ${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showCheckinOptions(int index) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Check-in Options'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              // View details logic
            },
            child: const Text('View Details'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              // Delete check-in logic
              setState(() {
                _recentCheckins.removeAt(index);
              });
            },
            child: const Text('Delete Check-in'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Check-in'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6.resolveFrom(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isCheckedIn ? 'You\'re checked in!' : 'Not checked in yet',
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _isCheckedIn
                              ? CupertinoColors.activeGreen
                              : CupertinoColors.systemGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isCheckedIn
                          ? 'Checked in at ${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}'
                          : 'Tap the button below to check in',
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!_isCheckedIn)
                      CupertinoButton.filled(
                        onPressed: _showTimePicker,
                        child: const Text('Check In Now'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Check-ins',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _recentCheckins.length,
                  itemBuilder: (context, index) {
                    final checkin = _recentCheckins[index];
                    return CupertinoListTile(
                      title: Text(
                        checkin['date'],
                        style: GoogleFonts.inter(),
                      ),
                      subtitle: Text(
                        checkin['time'],
                        style: GoogleFonts.inter(),
                      ),
                      trailing: const Icon(
                        CupertinoIcons.chevron_right,
                        color: CupertinoColors.systemGrey,
                      ),
                      onTap: () => _showCheckinOptions(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}