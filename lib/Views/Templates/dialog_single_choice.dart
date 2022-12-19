import 'package:flutter/material.dart';

Future<int> showSingleChoiceDialog(
    BuildContext context, String title, List<String> choices) async {
  return await showDialog(
      context: context,
      builder: (context) {
        int? choice = 0;

        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {

            var tiles = choices.map((e) => RadioListTile<int>(
                  title: Text(e),
                  value: choices.indexOf(e),
                  groupValue: choice,
                  onChanged: (int? value) {
                    setState(() => choice = value);
                  },
                ));
            return Container(
                height: 320,
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(children: <Widget>[
                    Text(title),
                    const Divider(),
                    Column(
                      children: tiles.toList(),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: const Text('CANCEL'),
                          onPressed: () {
                            return Navigator.pop(context, -1);
                          },
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          child: const Text('CONFIRM'),
                          onPressed: () {
                            return Navigator.pop(context, choice);
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ]),
                ));
          }),
        );
      })??-1;
}
