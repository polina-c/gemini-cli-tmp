// import 'dart:collection';

// import 'package:flutter/material.dart';

// class GenUi {}

// class DashboardViewController with ChangeNotifier {

//   // ignore: prefer_collection_literals, we want to preserve order.
//   final _dashboards = LinkedHashMap<String, GenUi>();
//   final _updated = <String>{};
//   String? _selection;

//   void setDashboards(Map<String, GenUi> dashboards) {
//     if (dashboards.isEmpty) {
//       return;
//     }
//     _dashboards.addAll(dashboards);
//     _updated.clear();
//     _updated.addAll(dashboards.keys);
//     _selection = dashboards.keys.first;
//     notifyListeners();
//   }

//   @override
//   void dispose() {
//     _dashboards.clear();
//     _updated.clear();
//     super.dispose();
//   }
// }

// class DashboardView extends StatefulWidget {
//   const DashboardView(this.controller, {super.key});

//   final DashboardViewController controller;

//   @override
//   State<DashboardView> createState() => _DashboardViewState();
// }

// class _DashboardViewState extends State<DashboardView> {
//   final int _selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(valueListenable: widget.controller, builder: builder)
//   }
// }
