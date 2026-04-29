import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/review_entity.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/review_card.dart';

class ReviewsSection extends StatelessWidget {
  final double averageRating;
  final List<ReviewEntity> reviews;
  const ReviewsSection({
    super.key,
    required this.averageRating,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Patient's Reviews",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  if (reviews.length > 3)
                    TextButton(
                      onPressed: () {
                        AppRouter.router.push(
                          AppRouter.kAllReviews,
                          extra: {
                            'reviews': reviews,
                            'averageRating': averageRating,
                          },
                        );
                      },
                      child: const Text(
                        "View All",
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...List.generate(5, (index) {
                              if (index < averageRating.floor()) {
                                return Icon(
                                  Icons.star,
                                  color: Colors.yellow.shade600,
                                  size: 18,
                                );
                              } else if (index < averageRating) {
                                return Icon(
                                  Icons.star_half,
                                  color: Colors.yellow.shade600,
                                  size: 18,
                                );
                              }
                              return Icon(
                                Icons.star_border,
                                color: Colors.yellow.shade600,
                                size: 18,
                              );
                            }),
                            SizedBox(width: 3.w),
                            Text(
                              averageRating.toStringAsFixed(2),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          "out of 5",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),

                    SizedBox(height: 6.h),
                    Text(
                      "Based on ${reviews.length} ${reviews.length == 1 ? 'reviews' : 'reviews'}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15),
              if (reviews.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Text(
                      'No reviews yet',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                )
              else
                ...reviews.take(3).map((review) {
                  return Column(
                    children: [
                      ReviewCard(
                        name: review.patientName,
                        imageUrl: review.patientImagePorfile,
                        reviewDate: _formatDate(review.reviewDate),
                        review: review.comment,
                        rating: review.rating,
                      ),
                      SizedBox(height: 15),
                    ],
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
