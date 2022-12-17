import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:moodie/constants/asset_const.dart';
import 'package:moodie/modules/record/controllers/record_controller.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/radius.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:get/get.dart';

class AddMoodDesc extends StatelessWidget {
  const AddMoodDesc({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RecordController recordController = Get.find();
    return Container(
      decoration: const BoxDecoration(
        color: ThemeColor.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(CustomRadius.defaultRadius),
          topRight: Radius.circular(CustomRadius.defaultRadius),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.keyboard_arrow_down),
                          Container(
                            margin: const EdgeInsets.only(
                              top: Spacing.spacing * 2,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextFormField(
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(20),
                                    fillColor: ThemeColor.neutral_200,
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    hintText: 'Title',
                                  ),
                                  controller: recordController.titleController,
                                ),
                                const SizedBox(height: Spacing.spacing * 3),
                                TextFormField(
                                  maxLines: 10,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(20),
                                    fillColor: ThemeColor.neutral_200,
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    hintText: 'How you feel?',
                                  ),
                                  controller: recordController.noteController,
                                ),
                                const SizedBox(height: 165),
                                SizedBox(
                                  width: double.infinity,
                                  height: 45,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: ThemeColor.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () {
                                      recordController.addMood();
                                    },
                                    child: const Text(
                                      "Next",
                                      style: TextStyle(
                                        color: ThemeColor.white,
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
            GetBuilder<RecordController>(
              id: 'addMood',
              builder: (state) {
                if (state.isLoading.value) {
                  return Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child:
                          Lottie.asset(AssetConst.animationLoading, width: 48),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
