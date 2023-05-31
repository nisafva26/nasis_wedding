import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nasis_wedding/controller/event_controller.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../colors.dart';
import '../../model/event.dart';
import '../../model/program_model.dart';
import '../widgets/form_widget.dart';

class EventDescriptionScreen extends StatefulWidget {
  final EventModel? event;
  const EventDescriptionScreen({super.key, this.event});

  @override
  State<EventDescriptionScreen> createState() => _EventDescriptionScreenState();
}

class _EventDescriptionScreenState extends State<EventDescriptionScreen> {
  @override
  final _formKey = GlobalKey<FormState>();
  List<Program> programs = [];

  bool isLiked = false;

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

    FirebaseFirestore.instance.collection('events').doc(widget.event!.id).update({
      'songList': FieldValue.arrayUnion([
        {
          'songName': _nameController.text,
          'videoLink': _linkController.text,
          'likeCount': 0
        }
      ])
    });

    print(_nameController.text);
    print(_linkController.text);

    // Clear the form and reset programs
    setState(() {
      programs = [];
    });
    _formKey.currentState?.reset();
  }

  String findDayOfWeek() {
    DateTime date = DateTime.parse(widget.event!.date);
    List<String> weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    int dayIndex = date.weekday - 1;
    return weekdays[dayIndex];
  }

  Widget build(BuildContext context) {
    var day = findDayOfWeek();
    EventController eventProvider = Provider.of<EventController>(context);

    Future<void> _launchUrl(String url) async {
      if (!await launchUrl(Uri.parse(url))) {
        throw Exception('Could not launch $url');
      }
    }

    return Scaffold(
        //backgroundColor: bgColor,
        floatingActionButton: Stack(
          children: [
            // Positioned(
            //   bottom: 80,
            //   right: 0,
            //   child: FloatingActionButton.extended(
            //     onPressed: () {
            //       _showProgramForm(context);
            //     },
            //     backgroundColor: bgColor,
            //     label: Text('Add Programs'),
            //     icon: Icon(Icons.add),
            //   ),
            // ),
            Positioned(
              bottom: 0,
              right: 0,
              child: FloatingActionButton.extended(
                onPressed: () {
                  _showProgramForm(context);
                },
                backgroundColor: bgColor,
                label: Text('Add song'),
                icon: Icon(Icons.add),
              ),
            ),
          ],
        ),
        body: StreamBuilder<EventModel>(
          stream: eventProvider.getEventByIdStream(widget.event!.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text('Error occurred: ${snapshot.error}');
            } else if (snapshot.hasData) {
              EventModel event = snapshot.data!;
              // Display the event details using the event object

              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 3,
                        decoration: BoxDecoration(
                            // borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                                image: NetworkImage(event.image), fit: BoxFit.cover)),
                      ),
                      Positioned(
                          top: 35,
                          left: 13,
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.white),
                            child: Center(
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.arrow_back_ios),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 20,
                              color: primaryColor,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Text(
                              'Date : ',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: yellow,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${event.date.toUpperCase()}  $day ',
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Venue : ',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: yellow,
                                  fontWeight: FontWeight.w600),
                            ),
                            Expanded(
                              child: Text(
                                '${event.venue}',
                                style: const TextStyle(fontSize: 18, color: primaryColor),
                              ),
                            ),
                          ],
                        ),
                        //  SizedBox(height: 10,),
                        const Text(
                          'Description ',
                          style: TextStyle(
                              fontSize: 18, color: yellow, fontWeight: FontWeight.w600),
                        ),

                        Text(
                          event.description,
                          style: const TextStyle(fontSize: 18, color: primaryColor),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Dance Tutorials ',
                          style: TextStyle(
                              fontSize: 18, color: yellow, fontWeight: FontWeight.w600),
                        ),

                        ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: event.songList!.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            var song = event.songList![index];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${song['songName']}',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      InkWell(
                                        onTap: () => _launchUrl(song['videoLink']),
                                        child: Text(
                                          song['videoLink'],
                                          style:
                                              TextStyle(color: Colors.blue, fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: 50,
                        )
                      ],
                    ),
                  ),
                ]),
              );
            } else {
              return const Text('Event not found');
            }
          },
        ));
  }

  void _showProgramForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Program'),
          content: SingleChildScrollView(
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
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  _savePrograms();
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void toggleLikeCount(String eventId, int songIndex, bool isLiked) async {
    try {
      // Get the event document reference

      log('isLiked: $isLiked');

      DocumentReference eventRef =
          FirebaseFirestore.instance.collection('events').doc(eventId);

      // Get the event document snapshot
      DocumentSnapshot eventSnapshot = await eventRef.get();

      // Get the song list from the event document data
      List<dynamic>? songList =
          (eventSnapshot.data() as Map<String, dynamic>?)?['songList'];

      // Get the specific song from the song list based on the index
      Map<String, dynamic> song = songList![songIndex];

      // Get the current like count
      int currentLikeCount = song['likeCount'];

      // Update the like count based on whether the song was liked or not
      int updatedLikeCount = isLiked ? currentLikeCount - 1 : currentLikeCount + 1;

      // Update the like count in the song
      song['likeCount'] = updatedLikeCount;

      // Update the song in the song list
      songList[songIndex] = song;

      // Update the song list in the event document
      await eventRef.update({'songList': songList});

      print('Like count updated for song at index $songIndex');

      setState(() {
        isLiked = !isLiked;
      });
      log('isLiked: $isLiked');
    } catch (error) {
      print('Error updating like count: $error');
    }
  }
}
