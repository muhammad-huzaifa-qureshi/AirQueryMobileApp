import 'package:air_query/core/constants/app_spacings.dart';
import 'package:air_query/ui/home/widgets/query_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text("Air Query"),),
      floatingActionButton: FloatingActionButton(onPressed: (){}, tooltip: "Post a Query", child: Icon(Icons.add),),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: .all(AppSpacings.medium),
          child: Column(
            children: [
              QueryCard(author: "Huzaifa", query: "Where is cafe located?", timePosted: DateTime.now().subtract(Duration(days: 2))),
              QueryCard(author: "Huzaifa", query: "Where is cafe located", timePosted: DateTime.now().subtract(Duration(days: 20)))
            ],
          ),
        ),
      )
    );
  }
}
