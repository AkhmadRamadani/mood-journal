import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:moodie/constants/asset_const.dart';
import 'package:moodie/modules/hydrate/controllers/hydrate_controller.dart';
import 'package:moodie/modules/hydrate/models/cup_choice.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:moodie/shared/themes/spacing.dart';
import 'package:moodie/shared/widgets/cards/page_header.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class HydrateView extends StatelessWidget {
  HydrateView({super.key});

  static const _backgroundColor = Color(0xFFF15BB5);

  static const _durations = [
    5000,
    4000,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = HydrateController.to;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Stack(
        children: [
          Scaffold(
            body: Stack(
              children: [
                GetBuilder<HydrateController>(
                  id: "wave",
                  builder: (state) {
                    return WaveWidget(
                      config: CustomConfig(
                        colors: [
                          ThemeColor.primary.withOpacity(0.5),
                          ThemeColor.primary,
                        ],
                        durations: _durations,
                        heightPercentages: state.heightPercentages,
                      ),
                      backgroundColor: ThemeColor.background,
                      size: const Size(double.infinity, double.infinity),
                      waveAmplitude: 0,
                    );
                  },
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Get.defaultDialog(
                                      title: "Settings",
                                      titlePadding: const EdgeInsets.all(16),
                                      content: Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Goal with textinput
                                                Text(
                                                  "Goal",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Container(
                                                  height: 40,
                                                  width: 140,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        ThemeColor.background,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Expanded(
                                                        child: TextField(
                                                          controller: controller
                                                              .targetController,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter
                                                                .digitsOnly
                                                          ],
                                                          decoration:
                                                              const InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                              left: 16,
                                                              right: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 40,
                                                        width: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: ThemeColor
                                                              .primaryColorDark,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "ml",
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: ThemeColor
                                                                  .background,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          child: Text(
                                            "Cancel",
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  ThemeColor.primaryColorDark,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            controller.addTarget();
                                          },
                                          child: Text(
                                            "Save",
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  ThemeColor.primaryColorDark,
                                            ),
                                          ),
                                        ),
                                      ],
                                      contentPadding: const EdgeInsets.all(16),
                                    );
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: ThemeColor.primaryColorDark,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.settings,
                                        color: ThemeColor.background,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                PageHeader(
                                  greet: false,
                                  isDark: false,
                                  type: 'heading',
                                  name: '',
                                  image: controller.repository.user?.photoURL ??
                                      '',
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            GetBuilder<HydrateController>(
                              builder: (state) {
                                return Text(
                                  "${state.targetWater.value} ml",
                                  style: GoogleFonts.poppins(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w600,
                                    color: ThemeColor.primaryColorDark,
                                  ),
                                );
                              },
                            ),
                            GetBuilder<HydrateController>(
                              id: 'remaining',
                              builder: (state) {
                                return Text(
                                  "Remaining ${state.remainingWater.value < 0 ? 0 : state.remainingWater.value} ml",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        // Percentage
                        GetBuilder<HydrateController>(
                          id: 'percentage',
                          builder: (state) {
                            return CircularPercentIndicator(
                              radius: Spacing.spacing * 8,
                              lineWidth: Spacing.spacing,
                              animation: true,
                              percent: state.waterPercentage.value / 100 > 1
                                  ? 1
                                  : state.waterPercentage.value / 100,
                              center: Text(
                                "${state.waterPercentage.value / 100 > 1 ? 100 : state.waterPercentage.value}%",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      color: ThemeColor.primaryColorDark,
                                      // : ThemeColor.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              circularStrokeCap: CircularStrokeCap.round,
                              backgroundColor: ThemeColor.background,
                              backgroundWidth: Spacing.spacing / 2,
                              progressColor: ThemeColor.primaryColorDark,
                            );
                          },
                        ),
                        // Grid for the water cup
                        Column(
                          children: [
                            GetBuilder<HydrateController>(
                              id: 'cup',
                              builder: (state) {
                                return GridView.count(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: (6 / 2),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: List.generate(
                                      state.cupChoices.length, (index) {
                                    CupChoice cup = state.cupChoices[index];
                                    return InkWell(
                                      onTap: () {
                                        state.selectCup(cup);
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: state.selectedCup?.name ==
                                                    cup.name
                                                ? ThemeColor.primaryColorDark
                                                : cup.color,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  cup.image,
                                                  width: 36,
                                                  height: 36,
                                                  color:
                                                      state.selectedCup?.name ==
                                                              cup.name
                                                          ? ThemeColor.white
                                                          : null,
                                                ),
                                                const SizedBox(
                                                  width: 8,
                                                ),
                                                Text(
                                                  '${cup.ml} ml',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                    color: state.selectedCup
                                                                ?.name ==
                                                            cup.name
                                                        ? ThemeColor.white
                                                        : null,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                    );
                                  }),
                                );
                              },
                            ),
                            const SizedBox(
                              height: 60,
                            ),

                            // Button to add water
                            InkWell(
                              onTap: () {
                                controller.addCurrentWater();
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: ThemeColor.primaryColorDark,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.add,
                                    color: ThemeColor.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          GetBuilder<HydrateController>(
            id: 'loading',
            builder: (state) {
              if (state.isLoading.value) {
                return Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Lottie.asset(AssetConst.animationLoading, width: 48),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
