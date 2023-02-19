import 'package:amplify_api/model_mutations.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:calendar202211/models/schedule.dart';
import 'package:intl/intl.dart';

class ScheduleRepository {
  static Future<void> insertSchedule() async {
    try {
      final schedule = Schedule(
        title: 'my first schedule',
        startAt: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        endAt: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      );
      final request = ModelMutations.create(schedule);
      final response = await Amplify.API.mutate(request: request).response;

      final createdSchedule = response.data;
      if (createdSchedule == null) {
        print('失敗');
        return;
      }
      print('Mutation result: ${createdSchedule.title}');
    } on ApiException catch (e) {
      print('Mutation failed: $e');
    }
  }
}
