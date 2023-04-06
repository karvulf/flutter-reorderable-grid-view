import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorder_update_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import 'package:flip_card/flip_card.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _globalKey = UniqueKey();
  final _gridViewKey = GlobalKey<_MyHomePageState>();
  final itemsModel = ItemsModel();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Widget _buildCard(String title, Color? backColor, bool locked) {
      return Card(
        color: backColor,
        key: widget.key,
        elevation: 2,
        shadowColor: Colors.black,
        child: Container(
          child: Padding(
              padding: EdgeInsets.all(5),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              )),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ChangeNotifierProvider.value(
          value: itemsModel,
          child: Consumer<ItemsModel>(builder: (context, model, child) {
            return ReorderableBuilder(
                key: _globalKey,
                scrollController: _scrollController,
                enableScrollingWhileDragging: true,
                enableDraggable: true,
                fadeInDuration: Duration.zero,
                onReorder: (ReorderedListFunction reorderedListFunction) {
                  var items =
                      reorderedListFunction(model.items) as List<String>;
                  model.reorderSongs(reorderedItems: items);
                },
                builder: (children) {
                  return GridView(
                    key: _gridViewKey,
                    controller: _scrollController,
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                      childAspectRatio: 1,
                    ),
                    children: children,
                  );
                },
                children: model.items.mapIndexed((index, item) {
                  final FlipCardController _controller = FlipCardController();
                  return FlipCard(
                    key: ValueKey(item),
                    controller: _controller,
                    fill: Fill.fillBack,
                    // Fill the back side of the card to make in the same size as the front.
                    direction: FlipDirection.HORIZONTAL,
                    side: CardSide.FRONT,
                    flipOnTouch: true,
                    autoFlipDuration: null,
                    onFlip: () {},
                    front: _buildCard(item, Colors.grey, false),
                    back: _buildCard(item, Colors.greenAccent, false),
                  );
                }).toList());
          }),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ItemsModel extends ChangeNotifier {
  List<String> items = [];

  ItemsModel() {
    items = List<String>.generate(64, (int index) => index.toString(),
        growable: false);
  }

  reorderSongs({required List<String> reorderedItems}) {
    items = reorderedItems;
    notifyListeners();
  }
}
