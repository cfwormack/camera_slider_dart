import 'package:flutter/material.dart';

class MySlider extends StatefulWidget {
  const MySlider({super.key, required this.value, required this.onChanged, required this.label,this.min=0,this.max=1, this.divisions});
  final double value;
  final ValueChanged<double> onChanged;

  final String label;
  final double min;
  final double max;
  final int? divisions;
  @override
  State<MySlider> createState() => _MySliderState();
}

class _MySliderState extends State<MySlider> {
  @override
  Widget build(BuildContext context) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
      children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(widget.label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Color(0xFFf0f0f0)),),
              ),
              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Slider(
                
                value: widget.value,
                onChanged: widget.onChanged,
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                label: (widget.value * 100).toStringAsFixed(0),),
        ),
          
      ]
    ); 

  }
}