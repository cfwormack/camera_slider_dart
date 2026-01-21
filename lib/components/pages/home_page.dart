
//Todo: abstract the preset widgets into their own component files
//Todo: implement persistent storage for presets

//todo: implement preset class 

import 'package:camera_slider/components/my_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io';


class Preset{
  String name;
  double speed;
  double x;
  double y;
  double z;

  Preset({required this.name, required this.speed, required this.x, required this.y, required this.z});
}

List<(String,double,double,double,double)> items = [('Default Preset',0.5,0.5,0.5,0.5)];

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    // backend socket
    late IO.Socket socket;
 
    
     @override
      void initState() {
      super.initState();
      initSocket();
    }
    void initSocket() {
    // Replace with your IP address if using a physical device
    socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    socket.onConnect((_) => print('Connected to Backend'));
    //socket.onDisconnect((_) => print('Disconnected from Backend'));
    //setupWindowCloseHandler();  
    initBackend();
  }

  // start the python backend process
  void main() async {
    var result = await Process.start(
      '.venv\\Scripts\\python.exe',
      ['c:/Users/genar/Flutter_Projects/camera_slider/camera_slider/lib/components/api/backened_socket.py'],
      mode: ProcessStartMode.detached,
      runInShell: true,
    );
      
  }
  

  void initBackend(){
    if (Platform.isWindows) {
       main();
        
      } else if (Platform.isLinux || Platform.isMacOS) {
        //Mac and linux implementation
        main();
      }
  }

  @override
  void dispose() {
    socket.dispose(); // Clean up connection
    super.dispose();
  }


// send slider and button commands to the python backend
 void sendData(String command,double value,bool b) {
    b ?socket.emit('slider_move',{'value': "$command${value.toInt()}>"}) :
           socket.emit('slider_move',{'value': "$command>"});
  
  }

  Future<void> setupWindowCloseHandler() async {
    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      // Perform any necessary cleanup here
      // For example, sign out the user
      await FirebaseAuth.instance.signOut();
      dispose();
      socket.onDisconnect((_) => print('Disconnected from Backend'));
      return true; // Allow the window to close
    });
  }

   // initial slider values  
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
    socket.onDisconnect((_) => print('Disconnected from Backend'));

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
            
              //speed slider
              MySlider(value: speedValue, onChanged: (newValue) {setState(() => speedValue = newValue); sendData('V', speedValue*100, true); }, label: 'Speed:'),
              //slide slider
              MySlider(value: xValue, onChanged: (newValue) {setState(() => xValue = newValue); sendData('X', xValue*1000, true);}, label: 'Slide:  '),
              //pan slider
              MySlider(value: yValue, onChanged: (newValue) {setState(() => yValue = newValue); sendData('Y', yValue*180, true);}, label: 'Pan:    '),
              //tilt slider
              MySlider(value: zValue, onChanged: (newValue) {setState(() => zValue = newValue); sendData('Z', zValue*180 , true);} , label: 'Tilt:    '),  
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
                              sendData('V', speedValue*100, true);
                              sendData('X', xValue*100, true);
                              sendData('Y', yValue*180, true);
                              sendData('Z', zValue*180, true);
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
                        // Implement set functionality
                        sendData('S', 0, false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Set'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Implement reset functionality
                        sendData('R', 0, false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
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