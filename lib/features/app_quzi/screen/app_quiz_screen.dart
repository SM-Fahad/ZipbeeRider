import 'package:ZipBee_Driver/core/common/widgets/custom_app_bar.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/core/utils/constants/iconpath.dart';
import 'package:ZipBee_Driver/features/app_quzi/controller/app_quiz_controller.dart';
import 'package:ZipBee_Driver/features/app_quzi/widgets/small_box.dart';
import 'package:ZipBee_Driver/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppQuizScreen extends StatelessWidget {
  AppQuizScreen({super.key});

  final AppQuizController ctrl = Get.put(AppQuizController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (ctrl.errorMessage.value.isNotEmpty) {
          return RefreshIndicator(
            onRefresh: ctrl.reloadQuiz,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'No Quiz Available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Pull to refresh or tap reload.',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: ctrl.reloadQuiz,
                          icon: Icon(Icons.refresh, color: Colors.black),
                          label: Text('Reload'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (ctrl.quiz.value == null) {
          return RefreshIndicator(
            onRefresh: ctrl.reloadQuiz,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.quiz, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No quiz available'),
                        SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: ctrl.reloadQuiz,
                          icon: Icon(Icons.refresh, color: Colors.black),
                          label: Text('Reload'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final quiz = ctrl.quiz.value!;

        return RefreshIndicator(
          onRefresh: ctrl.reloadQuiz,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                CustomAppBar(lable: 'App Quiz',),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.description.isNotEmpty
                            ? quiz.description
                            : 'Brief explanation about quiz',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          SmallBox(
                            iconPath: IconPath.file,
                            title: '${ctrl.getNumberOfQuestions()} Question',
                            description:
                                '${ctrl.getPointsPerCorrectAnswer()} Point for Correct\nanswer',
                          ),
                          Spacer(),
                          SmallBox(
                            iconPath: IconPath.timer,
                            title: '${quiz.timeLimit} Min',
                            description: 'Total duration of the\nquiz',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      SizedBox(height: 30),
                      Center(
                        child: Text(
                          quiz.category.isNotEmpty
                              ? quiz.category
                              : 'One time Quiz',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFB38F00),
                            fontFamily: 'Nunito Sans',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationStyle: TextDecorationStyle.solid,
                            decorationColor: const Color(0xFFB38F00),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Please read the text below carefully so you can understand it',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '- ${ctrl.getPointsPerCorrectAnswer()} point awarded for a correct answer and no marks for a incorrect answer',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.fontColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '- Tap on options to select the correct answer',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.fontColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '- Tap on the bookmark icon to save interesting questions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.fontColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '- Click submit if you are sure you want to complete all the quizzes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.fontColor,
                        ),
                      ),
                      SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: ctrl.reloadQuiz,
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48),
                        ),
                        icon: Icon(Icons.refresh, color: Colors.black),
                        label: Text(
                          'Reload Quiz Data',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 80),
                      ElevatedButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.appCouresScreen);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButtonColor,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Continue Quiz',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
