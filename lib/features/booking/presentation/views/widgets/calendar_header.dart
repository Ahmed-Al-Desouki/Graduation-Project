import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';

class CalendarHeader extends StatelessWidget {
  final bool isPatientView;
  final String? doctorName;

  const CalendarHeader({
    super.key,
    this.isPatientView = false,
    this.doctorName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPatientView ? "Booking with" : "Welcome, Doctor",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                isPatientView ? "Dr. $doctorName" : "Your Schedule",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          if (!isPatientView)
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.more_vert, color: Colors.blue),
              ),
              onSelected: (value) {
                if (value == 'agenda') {
                  context.push(AppRouter.kAppointmentsCenter);
                } else if (value == 'setup') {
                  context.push(AppRouter.kScheduleSetup);
                }
              },
              itemBuilder:
                  (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'agenda',
                      child: Row(
                        children: [
                          Icon(
                            Icons.view_agenda_outlined,
                            color: Colors.blue,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text('Agenda View', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'calendar',
                      enabled: false,
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Calendar View',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'setup',
                      child: Row(
                        children: [
                          Icon(
                            Icons.settings_outlined,
                            color: Colors.blueGrey,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Schedule Settings',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
            ),
        ],
      ),
    );
  }
}
