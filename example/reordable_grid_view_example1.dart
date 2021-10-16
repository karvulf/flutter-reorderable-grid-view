import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/reorderable_grid_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 100, 20, 0),
        child: Column(
          children: [
            Expanded(
              child: ReorderableGridView(
                spacing: 12,
                children: List.generate(
                  20,
                  (index) => Container(
                    color: Colors.blue,
                    height: 100,
                    width: 100,
                    child: Text(
                      'test $index',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.red,
              child: const SafeArea(
                child: Text(
                  'i bims 1 text',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
