
import 'package:camera_slider/components/my_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

List<(String,double,double,double,double)> items = [('Default Preset',0.5,0.5,0.5,0.5)];


class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    double speedValue = 0.5;
    double xValue = 0.5;
    double yValue = 0.5;
    double zValue = 0.5;
    List<String> presetNames = [];
  (String,double,double,double,double) selectedItem = ('Default Preset', 0.5 ,0.5, 0.5, 0.5);
    final presetController = TextEditingController();

  void signUserOut() {
    // Implement your sign-out logic here
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: const Color(0xFF1e1e1e),
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text('User: ${FirebaseAuth.instance.currentUser?.email ?? "Guest"}', style: TextStyle(color: Color(0xFFf0f0f0))),
            ),
          ),
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout, color: Color(0xFFf0f0f0)),
          ),
        ],
        backgroundColor: Color(0xFF2b2b2b),
        
        title: Text('Home Page', style: TextStyle(color: Color(0xFFf0f0f0))),
      ),
      body:Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
            
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.all(16.0),
            decoration: 
            BoxDecoration(color: Color(0xFF2b2b2b), 
                       borderRadius: BorderRadius.circular(10.0),),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: Text('Control Panel', 
                  style: TextStyle(fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFf0f0f0),
                  ),
                  ),
                ),
            /*
                Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: Text('Adjust the sliders to control the camera slider', 
                  style: TextStyle(fontSize: 30,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Color(0xFF2b2b2b),
                  color: Color(0xFFf0f0f0),
                  ),
                  ),
                ),
              */
              //speed slider
             
              MySlider(value: speedValue, onChanged: (newValue) {setState(() => speedValue = newValue); }, label: 'Speed:'),
              //slide slider
              MySlider(value: xValue, onChanged: (newValue) {setState(() => xValue = newValue); }, label: 'Slide:  '),
              //pan slider
              MySlider(value: yValue, onChanged: (newValue) {setState(() => yValue = newValue); }, label: 'Pan:    '),
              //tilt slider
              MySlider(value: zValue, onChanged: (newValue) {setState(() => zValue = newValue); }, label: 'Tilt:    '),  
              SizedBox(height: 20,),
              // display current values
                Text('Speed: ${(speedValue * 100).toStringAsFixed(0)}%, Slide: ${(xValue * 100).toStringAsFixed(0)}, Pan: ${(yValue * 180).toStringAsFixed(0)}, Tilt: ${(zValue * 180).toStringAsFixed(0)}', 
                style: TextStyle(fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFf0f0f0),
                ),
                ),
          
              SizedBox(height: 20),
                // save preset
            
              Container(
                      margin: EdgeInsets.only(left: 20),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      width: 600,
            
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        
                        children: [
                        // Preset name input field 
                        Expanded(
                          child: TextField(
                      textAlign: TextAlign.center,
                      
                      controller: presetController,
                      decoration: InputDecoration(
                        hintText: 'save preset as...',
                        hintStyle: TextStyle(color: Color(0xFFf0f0f0)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFf0f0f0)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFf0f0f0)),
                        ),
                      ),
                      style: TextStyle(color: Color(0xFFf0f0f0)),
                    ),
                        ),
                    SizedBox(width: 20),
                     ElevatedButton(
                      onPressed: () {
                        // Implement save preset functionality
                        items.add((presetController.text,speedValue,xValue,yValue,zValue));
                      
                        setState(() {
                          selectedItem = (presetController.text,speedValue,xValue,yValue,zValue);
            
                        });
                       
                        //save the preset with the name from presetController.text
                        // and the current xValue, yValue, zValue
            
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Save Preset'),
                    ), SizedBox(width: 20), 
                    ElevatedButton(
                      onPressed: () {
                        // Implement delete preset functionality
                        setState(() {
                          items.removeWhere((item) => item.$1 == selectedItem.$1);
                          selectedItem = items.isNotEmpty ? items[0] : ('Default Preset',0.5,0.5,0.5,0.5);
                          speedValue = selectedItem.$2;
                          xValue = selectedItem.$3;
                          yValue = selectedItem.$4;
                          zValue = selectedItem.$5;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Delete Preset'),
                    ),
              ],
                      ),
                    ),
              
                    // keyframe presets
             
                      
            
            ]
                  ),
                         
            
                  ),
          ),
      //preset loader and keyframe list
      Expanded(
        child: Container(
           
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.all(16.0),
            decoration: 
            BoxDecoration(color: Color(0xFF2b2b2b), 
                       borderRadius: BorderRadius.circular(10.0),),
            child:
         Column(
                mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
               
                children: [
                  Text( 'Load presets:',
                  textAlign: TextAlign.center, 
                  style: TextStyle(fontSize: 20,color:Color(0xFFf0f0f0),fontWeight: FontWeight.bold),),
                Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                       decoration: 
                                    BoxDecoration(color: Color(0xFF2b2b2b), 
                       borderRadius: BorderRadius.circular(10.0),),
                      child:
                      DropdownButton<(String,double,double,double,double)>(
                        value: selectedItem,
                        dropdownColor: Color(0xFF2b2b2b),
                        style: TextStyle(color: Color(0xFFf0f0f0)),
                        items: items.map((item) {
                          return DropdownMenuItem<(String,double,double,double,double)>(
                            value: item,
                            child: Text(item.$1, style: TextStyle(color: Color(0xFFf0f0f0)),),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedItem = newValue!;
                            speedValue = selectedItem.$2;
                            xValue = selectedItem.$3;
                            yValue = selectedItem.$4;
                            zValue = selectedItem.$5;
                          });
                        },
                    ),
                    ),    
                    
                    //keyframe lists
                   Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                     children: [
                       items.isNotEmpty ? ListView.builder(itemBuilder: 
                        (context, index) {
                          return ListTile(
                            title:Text(items[index].$1, textAlign: TextAlign.center, ),
                            subtitle: Text('Speed: ${(items[index].$2 * 100).toStringAsFixed(0)}, Slide: ${(items[index].$3 * 100).toStringAsFixed(0)}, Pan: ${(items[index].$4 * 180).toStringAsFixed(0)}, Tilt: ${(items[index].$5 * 180).toStringAsFixed(0)}', 
                            style: TextStyle(color: Color(0xFFf0f0f0)), textAlign: TextAlign.center,),
                            selected: items[index].$1 == selectedItem.$1,
                            onTap: () {
                              setState(() {
                                selectedItem = items[index];
                                speedValue = selectedItem.$2;
                                xValue = selectedItem.$3;
                                yValue = selectedItem.$4;
                                zValue = selectedItem.$5;
                              });
                            },
                          );
                        },
                        
                        itemCount: items.length,
                        shrinkWrap: true,
                       ) : Text('No presets saved.', style: TextStyle(color: Color(0xFFf0f0f0)),),
                     ],
                   ),
                   SizedBox(height: 20),
                //action buttons
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Implement start functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Start'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Implement stop functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Stop'),
                    ),
                    // Preset name input field
                    SizedBox(width: 20),
                   ElevatedButton(
                      onPressed: () {
                        // Implement reset functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Reset'),
                    ),
                 
                  ],
                ),
              ),
                    
                    ],
                    ),
        ),
      )],
      ),
      );
  }
}