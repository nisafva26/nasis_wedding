import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nasis_wedding/colors.dart';
import 'package:nasis_wedding/controller/event_controller.dart';
import 'package:nasis_wedding/view/screens/event_description_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchEvent();
    _animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    DateTime weddingDate = DateTime(2023, 7, 2);
    Duration timeDifference = weddingDate.difference(DateTime.now());

    _animation = Tween<double>(begin: 0, end: timeDifference.inDays.toDouble())
        .animate(_animationController);
    _animationController.forward();
  }

  fetchEvent() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventController>(context, listen: false).fetchEvents();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime weddingDate = DateTime(2023, 7, 2);
    Duration timeDifference = weddingDate.difference(DateTime.now());

    log('time difference:$timeDifference');
    print(timeDifference.inDays);

    String findDayOfWeek(String dateStr) {
      DateTime date = DateTime.parse(dateStr);
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

    return Scaffold(
      //1
      body: Consumer<EventController>(builder: (context, controller, child) {
        return CustomScrollView(slivers: <Widget>[
          //2
          SliverAppBar(
            backgroundColor: primaryColor,
            expandedHeight: 250.0,
            pinned: true,
            snap: true,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: EdgeInsets.all(13),
              title: Text(
                'Nasi\'s Kalyanam',
                style: GoogleFonts.vollkorn(fontSize: 25),
              ),
              background: Opacity(
                opacity: .6,
                child: Image.asset(
                  'assets/nasi3.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          //3
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: [
                      // Text(
                      //   timeDifference.inDays.toString(),
                      //   style: TextStyle(fontSize: 85, color: primaryColor),
                      // ),
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (BuildContext context, Widget? child) {
                          return Text(
                            _animation.value.toInt().toString(),
                           style: TextStyle(fontSize: 85, color: primaryColor),
                          );
                        },
                      ),
                      Text(
                        'Days to go',
                        style: TextStyle(fontSize: 18, color: primaryColor),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Events',
                    style: TextStyle(
                        fontSize: 25, color: primaryColor, fontWeight: FontWeight.w500),
                  ),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    itemBuilder: (BuildContext context, int index) {
                      // Create your GridView items here

                      var event = controller.events[index];
                      var day = findDayOfWeek(event.date);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDescriptionScreen(
                                    event: event,
                                  ),
                                ));
                          },
                          child: Card(
                            elevation: 5,
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                  color: bgColor, borderRadius: BorderRadius.circular(8)),
                              child: Column(
                                  //  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 130,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          image: DecorationImage(
                                              image: NetworkImage(event.image),
                                              fit: BoxFit.cover)),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      event.name.toUpperCase(),
                                      style: TextStyle(fontSize: 17, color: primaryColor),
                                    ),
                                    Text(
                                      '${event.date.toUpperCase()} $day',
                                      style: TextStyle(fontSize: 17, color: primaryColor),
                                    )
                                  ]),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount:
                        controller.events.length, // Replace with your actual item count
                    shrinkWrap: true,
                    physics:
                        NeverScrollableScrollPhysics(), // Disable scrolling of the GridView
                  ),
                ],
              ),
            ),
          )
        ]);
      }),
    );
  }
}
