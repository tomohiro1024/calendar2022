import 'package:amplify_api/model_mutations.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:calendar202211/models/Schedule.dart';

class ScheduleRepository {
  static Future<void> insertSchedule(Schedule newSchedule) async {
    try {
      final request = ModelMutations.create(newSchedule);
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
