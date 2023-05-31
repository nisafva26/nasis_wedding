import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nasis_wedding/model/event.dart';

import '../model/program_model.dart';

class EventController extends ChangeNotifier {
  List<EventModel> _events = [];

  List<EventModel> get events => _events;

  Future<void> fetchEvents() async {
    log('calling fetching events');
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('events').get();

    _events = querySnapshot.docs
        .map((documentSnapshot) => EventModel.fromFirestore(documentSnapshot))
        .toList()
        .reversed
        .toList();

    log('events:');
    log(_events.toString());

    _events.forEach((element) {
      print(element.name);
   
    });

    notifyListeners();
  }

  Stream<EventModel> getEventByIdStream(String eventId) {
    return FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .snapshots()
        .map((snapshot) => EventModel.fromFirestore(snapshot));
  }
}
