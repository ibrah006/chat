import 'package:flutter/material.dart';


class CustomRadios extends StatefulWidget {
  const CustomRadios(
    {super.key, required this.children, required this.onChanged}
  );

  final List<Widget> children;
  final Function(int index) onChanged;

  @override
  State<CustomRadios> createState() => _CustomRadiosState();
}

class _CustomRadiosState extends State<CustomRadios> {

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.children.length,
        (index) {
          return Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    widget.onChanged(index);
                    selectedIndex = index;
                  });
                },
                child: Container(
                  height: 21,
                  width: 21,
                  margin: EdgeInsets.only(left: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: selectedIndex==index? Colors.blue : null,
                    border: selectedIndex!=index? Border.all(color: Colors.grey, width: 3) : null
                  )
                ),
              ),
              Expanded(child: widget.children[index])
            ],
          );
        })
    );
  }
}