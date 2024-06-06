import 'package:flutter/material.dart';
import 'package:mobile/services/appwrite_service.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({Key? key}) : super(key: key);

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  final AppwriteService _appwriteService = AppwriteService();
  String currentColor = '';

  final List<String> colors = [
    'green',
    'blue',
    'yellow',
    'red',
    'purple',
    'orange',
    'pink',
    'black'
  ];

  final Map<String, Color> colorMap = {
    'green': Colors.green,
    'blue': Colors.blue,
    'yellow': Colors.yellow,
    'red': Colors.red,
    'purple': Colors.purple,
    'orange': Colors.orange,
    'pink': Colors.pink,
    'black': Colors.black,
  };

  @override
  void initState() {
    super.initState();
    _loadCurrentColor();
  }

  Future<void> _loadCurrentColor() async {
    final userId = await _appwriteService.getCurrentUserId();
    final user = await _appwriteService.getUserByID(userId);
    setState(() {
      currentColor = user.data['backgroundColor'];
    });
  }

  Future<void> _updateColor(String color) async {
    final userId = await _appwriteService.getCurrentUserId();
    await _appwriteService.updateUserColor(userId, color);
    setState(() {
      currentColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Select your messages background color:',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              return GestureDetector(
                onTap: () => _updateColor(color),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorMap[color],
                    shape: BoxShape.circle,
                    border: currentColor == color
                        ? Border.all(color: Colors.blue, width: 3)
                        : null,
                  ),
                  child: currentColor == color
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
