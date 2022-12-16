import 'package:flutter/material.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:moodie/shared/widgets/buttons/profile_button.dart';
import 'package:moodie/shared/widgets/cards/notification_card.dart';
import 'package:moodie/shared/widgets/cards/page_header.dart';
import 'package:moodie/shared/widgets/cards/record_card.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: ThemeColor.white,
                      ),
                    ),
                  ),
                  Container(
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.check,
                        color: ThemeColor.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: Image.network(
                'https://i.pinimg.com/564x/06/63/f5/0663f52b4e6775adcd134a27853004b3.jpg',
                width: Spacing.spacing * 20,
                height: Spacing.spacing * 20,
              ),
            ),
            const SizedBox(
              height: Spacing.spacing * 3,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(Spacing.spacing * 3),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: ThemeColor.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(CustomRadius.defaultRadius),
                    topRight: Radius.circular(CustomRadius.defaultRadius),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          top: Spacing.spacing,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nama',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'testName',
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ThemeColor.neutral_400,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              'Email',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'testEmail@gmail.com',
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ThemeColor.neutral_400,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: Spacing.spacing * 3),
                            Text(
                              'No. HP',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: ThemeColor.neutral_900,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                hintText: '082211113333',
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ThemeColor.neutral_400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
