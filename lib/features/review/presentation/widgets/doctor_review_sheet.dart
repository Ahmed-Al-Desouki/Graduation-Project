import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/review/presentation/review_cubit/review_cubit.dart';

// في ملف doctor_review_sheet.dart
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class DoctorReviewSheet extends StatefulWidget {
  final int doctorId;
  const DoctorReviewSheet({super.key, required this.doctorId});

  @override
  State<DoctorReviewSheet> createState() => _DoctorReviewSheetState();
}

class _DoctorReviewSheetState extends State<DoctorReviewSheet> {
  double _rating = 5.0; // الباك مستني int بس المكتبة بتعطي double
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // خط صغير فوق لتوضيح إنه شيت بيتقفل
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20.h),

          Text(
            "Rate your doctor",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15.h),

          // 🌟 الـ Rating Bar الاحترافي
          RatingBar.builder(
            initialRating: 5,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false, // الباك مستني رقم صحيح (1, 2, 3, 4, 5)
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder:
                (context, _) =>
                    const Icon(Icons.star_rounded, color: Colors.amber),
            onRatingUpdate: (rating) => setState(() => _rating = rating),
          ),

          SizedBox(height: 20.h),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: "Your feedback matters...",
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 20.h),

          BlocConsumer<ReviewCubit, ReviewState>(
            listener: (context, state) {
              if (state is ReviewSuccess) {
                Navigator.pop(context);
                showSnackBar(
                  context,
                  "Review submitted! Thanks.",
                  Colors.green,
                );
              }
              if (state is ReviewFailure) {
                showSnackBar(context, state.errMessage, Colors.red);
              }
            },
            builder: (context, state) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9333EA),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed:
                    state is ReviewLoading
                        ? null
                        : () {
                          context.read<ReviewCubit>().submitReview(
                            doctorId: widget.doctorId,
                            rating:
                                _rating
                                    .toInt(), // تحويل الـ double لـ int عشان الباك-إند
                            comment: _commentController.text,
                          );
                        },
                child:
                    state is ReviewLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "Submit Review",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              );
            },
          ),
        ],
      ),
    );
  }
}
