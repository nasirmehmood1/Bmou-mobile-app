import 'package:app/Controller/mood_controller.dart';
import 'package:app/Utils/loading_overlays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../Constants/color.dart';

class Emoji {
  static List<String> message = [
    'Keep this good mood and the day will be smooth.',
    'Smile at yourself, something good may be will happen.',
    'Don\'t care about the bad things, try to look towards the good things.',
    'What happened? Do you want a hug? Tell me, let\'s disscuss what to do together.',
    'This is wonderful. Do you want to share it and make everyone happy for you?',
  ];
  static void showEmojiDailouge(BuildContext context, {required String image, required int index, required String mood}) {
    final TextEditingController noteController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool isValidated = false;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        elevation: 0.0,
        backgroundColor: AppColors.white,
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(image),
                const SizedBox(height: 15),
                Text(message[index].tr, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: 15),
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: noteController,
                    keyboardType: TextInputType.text,
                    autovalidateMode: isValidated == true ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                    decoration: InputDecoration(hintText: 'Type Here'.tr),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 60.0)),
                        onPressed: () => Get.back(),
                        child: Text('Cancel'.tr),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 60.0)),
                        onPressed: () {
                          isValidated = true;
                          if (formKey.currentState!.validate()) {
                            kOverlayWithAsync(
                              asyncFunction: () async {
                                await MoodController.to
                                    .addMood(
                                      context,
                                      mood: mood.replaceAll(' ', ''),
                                      note: noteController.text == '' ? null : noteController.text,
                                    )
                                    .then(
                                      (value) => Get.back(),
                                    );
                              },
                            );
                          }
                        },
                        child: Text('Continue'.tr),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
