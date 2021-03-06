import 'package:calender/provider/event_provider.dart';
import 'package:calender/widget/calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:calender/page/event_editing_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:googleapis/calendar/v3.dart' as googleAPI;
import 'package:http/io_client.dart';
import 'package:http/http.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static final String title = 'Event Calendar';
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create:(context)=>EventProvider(),
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        accentColor: Colors.white,
      ),
      home: MainPage(),
    ),
  );
}

class MainPage extends StatelessWidget{
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        'OAuth Client ID',
    scopes: <String>[
      googleAPI.CalendarApi.calendarScope,
          ],
        );
        Widget build(BuildContext context) => Scaffold(
          appBar: AppBar(
            title: Text('Event Calendar'),
            centerTitle: true,
          ),
          body: Container(
              child: FutureBuilder(
                future: getGoogleEventsData(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return Container(
                      child: Stack(
                    children: [
                      Container(
                        child:CalendarWidget(),
                      ),
                      snapshot.data != null
                          ? Container()
                          : Center(
                              // child: CircularProgressIndicator(),
                            )
                    ],
                  ));
                },
              ),
            ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add, color: Colors.black,),
            backgroundColor: Colors.white,
            onPressed: ()=> Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => EventEditingPage())
            ),
          ),
        );
        // @override
        void dispose(){
          if(_googleSignIn.currentUser != null) {
            _googleSignIn.disconnect();
            _googleSignIn.signOut();
          }
      
          // super.dispose();
        }
      
        Future<List<googleAPI.Event>> getGoogleEventsData() async {
          final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
          final GoogleAPIClient httpClient =
              GoogleAPIClient(await googleUser!.authHeaders);
          final googleAPI.CalendarApi calendarAPI = googleAPI.CalendarApi(httpClient);
          final googleAPI.Events calEvents = await calendarAPI.events.list(
            "primary",
          );
          final List<googleAPI.Event> appointments = <googleAPI.Event>[];
          if (calEvents != null && calEvents.items != null) {
            for (int i = 0; i < calEvents.items!.length; i++) {
              final googleAPI.Event event = calEvents.items![i];
              if (event.start == null) {
                continue;
              }
              appointments.add(event);
            }
          }
          return appointments;
        }
      }
      
class GoogleDataSource extends CalendarDataSource {
  GoogleDataSource({required List<googleAPI.Event> events}) {
    this.appointments = events;
  }

  @override
  DateTime getStartTime(int index) {
    final googleAPI.Event event = appointments![index];
    return event.start!.date ?? event.start!.dateTime!.toLocal();
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].start.date != null;
  }

  @override
  DateTime getEndTime(int index) {
    final googleAPI.Event event = appointments![index];
    return event.endTimeUnspecified != null 
    // && event.endTimeUnspecified
        ? (event.start!.date ?? event.start!.dateTime!.toLocal())
        : (event.end!.date != null
            ? event.end!.date!.add(Duration(days: -1))
            : event.end!.dateTime!.toLocal());
  }

  @override
  String getLocation(int index) {
    return appointments![index].location;
  }

  @override
  String getNotes(int index) {
    return appointments![index].description;
  }

  // @override
  // String? getSubject(int index) {
  //   final googleAPI.Event event = appointments![index];
  //   return event.summary == null || event.summary!.isEmpty
  //       ? 'No Title'
  //       : event.summary;
  // }
}

class GoogleAPIClient extends IOClient {
  Map<String, String> _headers;

  GoogleAPIClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  // @override
  // Future<Response> head(Object url, {required Map<String, String> headers}) =>
  //     super.head(url, headers: headers..addAll(_headers));
}




// import 'package:calender/provider/event_provider.dart';
// import 'package:calender/widget/calendar_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:calender/page/event_editing_page.dart';
// import 'package:provider/provider.dart';
// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   static final String title = 'Event Calendar';
//   @override
//   Widget build(BuildContext context) => ChangeNotifierProvider(
//       create:(context)=>EventProvider(),
//       child: MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: title,
//       themeMode: ThemeMode.dark,
//       darkTheme: ThemeData.dark().copyWith(
//         scaffoldBackgroundColor: Colors.black,
//         accentColor: Colors.white,
//       ),
//       home: MainPage(),
//     ),
//   );
// }

// class MainPage extends StatelessWidget{
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(
//       title: Text('Event Calendar'),
//       centerTitle: true,
//     ),
//     body: CalendarWidget(),
//     floatingActionButton: FloatingActionButton(
//       child: Icon(Icons.add, color: Colors.black,),
//       backgroundColor: Colors.white,
//       onPressed: ()=> Navigator.of(context).push(
//         MaterialPageRoute(builder: (context) => EventEditingPage())
//       ),
//     ),
//   );
// }