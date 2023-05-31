import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nasis_wedding/model/program_model.dart';

class EventModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final String venue;
  final String date;
 // final List<String>? program;
 final List<Map<String, dynamic>>? songList;

  EventModel(
      {required this.id,
      required this.name,
      required this.description,
      required this.image,
      required this.venue,
      required this.date,
      this.songList
     // this.program

      });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<Map<String, dynamic>> songs = [];
    if (data.containsKey('songList')) {
      songs = (data['songList'] as List<dynamic>)
          .map((songData) => {
                'songName': songData['songName'],
                'videoLink': songData['videoLink'],
                'likeCount': songData['likeCount'] ?? 0
              })
          .toList();
    }

   
    return EventModel(
        id: doc.id,
        name: data['name'],
        description: data['description'],
        image: data['image'],
        venue: data['venue'],
        date: data['date'],
        songList: songs
       // program: data['songs']
       );
  }
}
