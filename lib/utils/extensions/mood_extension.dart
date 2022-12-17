import 'package:moodie/shared/widgets/cards/mood_emoticon.dart';

extension MoodExtension on MoodEmoticon {
  String toShortString() {
    return this.toString().split('.').last;
  }
}
