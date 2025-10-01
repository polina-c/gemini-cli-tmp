import 'dart:collection';

import 'package:flutter/material.dart';

class GenUi {}

/// Controller for the dashboard view.
///
/// It holds a list of dashboards and notifies listeners when the list changes.
class DashboardViewController with ChangeNotifier {
  // ignore: prefer_collection_literals, we want to preserve order.
  final _dashboards = LinkedHashMap<String, GenUi>();
  final _updated = <String>{};
  String? _selection;

  void setDashboards(Map<String, GenUi> dashboards) {
    if (dashboards.isEmpty) {
      return;
    }
    _dashboards.addAll(dashboards);
    _updated.clear();
    _updated.addAll(dashboards.keys);
    _selection = dashboards.keys.first;
    notifyListeners();
  }

  void setSelection(String id) {
    if (_dashboards.containsKey(id)) {
      _selection = id;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _updated.clear();
    _dashboards.clear();
    super.dispose();
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView(this.controller, {super.key});

  final DashboardViewController controller;

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  void emptySetState() => setState(() {});

  @override
  void initState() {
    widget.controller.addListener(emptySetState);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(emptySetState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _DashboardList(
            dashboardNames: widget.controller._dashboards.keys.toList(),
            updated: widget.controller._updated,
            selection: widget.controller._selection,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 3,
          child: widget.controller._selection != null
              ? _GenUiView(
                  widget.controller._dashboards[widget.controller._selection]!,
                )
              : const Center(child: Icon(Icons.dashboard)),
        ),
      ],
    );
  }
}

class _GenUiView extends StatelessWidget {
  const _GenUiView(this.genUi);

  final GenUi genUi;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _DashboardList extends StatelessWidget {
  _DashboardList({
    required this.dashboardNames,
    required this.updated,
    required this.selection,
  });

  final List<String> dashboardNames;
  final Set<String> updated;
  final String? selection;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
