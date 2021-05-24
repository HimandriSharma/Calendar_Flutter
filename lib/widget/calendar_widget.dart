import 'package:calender/model/event_data_source.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calender/provider/event_provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'tasks_widget.dart';
class CalendarWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    final events = Provider.of<EventProvider>(context).events;
    return SfCalendar(
      view: CalendarView.month,
      dataSource: EventDataSource(events),
      initialSelectedDate: DateTime.now(),
      onLongPress: (details){
        final provider = Provider.of<EventProvider>(context,listen: false);
        provider.setDate(details.date!);
        showModalBottomSheet(
          context: context, 
          builder: (context)=>TasksWidget(),
        );
      },
    );
  }
}