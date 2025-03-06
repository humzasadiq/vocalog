import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var path = "/storage/emulated/0/VocalogRecordings";
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Row(
            children: [
              Icon(
                Icons.history,
                color: Colors.blue,
                size: 30,
              ),
              SizedBox(width: 10),
              Text(style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold), "History"),
            ],
          )
        ),
      ),
      body: Scrollbar(
        child: FutureBuilder<List<File>>(
          future: getFileList(path),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Nothing here'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No files found'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return TextButton(
                      onPressed: () {},
                      child: ListTile(
                        title: Text((index + 1).toString()),
                        subtitle: Text(
                            "Dated: ${FileStat.statSync(snapshot.data![index].path).modified.toString()}"),
                        leading: Icon(Icons.record_voice_over),
                      ));
                },
              );
            }
          },
        ),
      ),
    );
  }
}

Future<List<File>> getFileList(String path) async {
  return Directory(path)
      .list()
      .where((entity) => entity is File)
      .cast<File>()
      .toList();
}
