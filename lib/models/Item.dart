class Item {
  final Map<String, dynamic> parentData;
  final List<Map<String, dynamic>> childData;
  bool isExpanded;

  Item({required this.parentData,
    required this.childData, this.isExpanded = false});
}