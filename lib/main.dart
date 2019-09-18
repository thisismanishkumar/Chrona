import 'package:flutter/material.dart';
import 'SignIn/app.dart';
import 'SignIn/state_widget.dart';

void main(){
  StateWidget stateWidget = new StateWidget(child:new MyApp());
  runApp(stateWidget);
}
