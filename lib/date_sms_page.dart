import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_sms/flutter_sms.dart';

class DateSMSPage extends StatefulWidget {
  @override
  _DateSMSPageState createState() => _DateSMSPageState();
}

class _DateSMSPageState extends State<DateSMSPage> {
  List<dynamic> messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse('https://script.google.com/macros/s/AKfycbwzCsCl0UGeS58nKTR1KmMpp4DJskTwWEe41EDaO7xxRFd3Z7LGIaySpsi0Bv6M0hBS/exec'));
    setState(() {
      messages = json.decode(response.body);
      _isLoading = false;
    });
  }

  Future<void> doPostRequest(int rowId, String status) async {
    final url = 'https://script.google.com/macros/s/AKfycbwzCsCl0UGeS58nKTR1KmMpp4DJskTwWEe41EDaO7xxRFd3Z7LGIaySpsi0Bv6M0hBS/exec';
    await http.post(
      Uri.parse(url),
      body: {
        'row': rowId.toString(),
        'status': status,
      },
    );
  }

  Future<void> _sendSMSAndUpdateStatus(String message, String recipient, int rowId) async {
    String result = await sendSMS(message: message, recipients: [recipient]);
    if (result == 'SMS Sent!') {
      await doPostRequest(rowId, 'SMS Sent');
      _refreshPage(); // Refresh page after SMS is sent and status is updated
    }
  }

  Future<void> _cancelAndUpdateStatus(int rowId) async {
    await doPostRequest(rowId, 'SMS Sent');
    _refreshPage(); // Refresh page after status is updated
  }

  Future<void> _sendAllSMS() async {
    for (var i = 0; i < messages.length; i++) {
      await _sendSMSAndUpdateStatus(messages[i][2], messages[i][1], i + 1);
    }
    _refreshPage(); // Refresh page after all SMS are sent and statuses are updated
  }

  Future<void> _cancelAllSMS() async {
    for (var i = 0; i < messages.length; i++) {
      await _cancelAndUpdateStatus(i + 1);
    }
    _refreshPage(); // Refresh page after all statuses are updated
  }

  void _refreshPage() {
    setState(() {
      _isLoading = true;
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Date SMS'),
            Text('${DateTime.now().hour}:${DateTime.now().minute}'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Text('${index + 1}'), // Added serial number here
            title: Text(messages[index][2]),
            subtitle: Text(messages[index][1]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    _cancelAndUpdateStatus(index + 1);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendSMSAndUpdateStatus(messages[index][2], messages[index][1], index + 1);
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _refreshPage, // Refresh page when Refresh button is pressed
              child: Text('Refresh'),
            ),
            TextButton(
              onPressed: _sendAllSMS,
              child: Text('Send All SMS'),
            ),
            TextButton(
              onPressed: _cancelAllSMS, // Cancel all and refresh page
              child: Text('Cancel All'),
            ),
          ],
        ),
      ),
    );
  }
}
