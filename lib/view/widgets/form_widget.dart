import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nasis_wedding/colors.dart';

import '../../model/program_model.dart';

class ProgramForm extends StatefulWidget {
  final String eventId;

  ProgramForm({required this.eventId});

  @override
  _ProgramFormState createState() => _ProgramFormState();
}

class _ProgramFormState extends State<ProgramForm> {
  final _formKey = GlobalKey<FormState>();
  List<Program> programs = [];

  TextEditingController _nameController = TextEditingController();
  TextEditingController _linkController = TextEditingController();

  void _addProgram(Program program) {
    setState(() {
      programs.add(program);
    });
  }

  void _savePrograms() {
    // Save programs to Firestore using the eventID
    // Create documents within the 'programs' collection for each program

    FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .collection('programs')
        .add({
      'songName': _nameController.text,
      'videoLink': _linkController.text,
    }).then((value) {
      log(value.toString());
    }).onError((error, stackTrace) {
      log(error.toString());
    });

    print(_nameController.text);
    print(_linkController.text);

    // Clear the form and reset programs
    setState(() {
      programs = [];
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    log('doc id');
    log(widget.eventId);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display existing programs if needed
            
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Song Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a song name';
                  }
                  // Add additional validation if required
                  return null;
                },
              ),
              TextFormField(
                controller: _linkController,
                decoration: InputDecoration(labelText: 'Video Link'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a video link';
                  }
                  // Add additional validation if required
                  return null;
                },
              ),
              SizedBox(
                height: 30,
              ),
              InkWell(
                onTap: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
            
                    _savePrograms();
                  }
                },
                child: Container(
                  height: 40,
                  // width: MediaQuery.of(context).size.width/2,
                  decoration: BoxDecoration(
                      color: primaryColor, borderRadius: BorderRadius.circular(8)),
                  child: Center(
                      child: Text(
                    'Add song',
                    style: TextStyle(color: Colors.white),
                  )),
                ),
              ),
            
              // ElevatedButton(
              //   style:  ButtonStyle(),
              //   onPressed: () {
              //     if (_formKey.currentState?.validate() ?? false) {
              //       _formKey.currentState?.save();
            
              //       _savePrograms();
              //     }
              //   },
              //   child: Text('Add Program'),
              // ),
              // ElevatedButton(
              //   onPressed: () {
              //     _savePrograms();
              //   },
              //   child: Text('Save Programs'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
