import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReviewCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String reviewDate;
  final String review;
  final double rating;
  const ReviewCard({
    super.key,
    required this.name,
    this.imageUrl,
    required this.reviewDate,
    required this.review,
    this.rating = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    imageUrl != null && imageUrl!.isNotEmpty
                        ? NetworkImage(imageUrl!)
                        : null,
                child:
                    imageUrl == null || imageUrl!.isEmpty
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
              ),

              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(5, (index) {
                          if (index < rating.floor()) {
                            return Icon(
                              Icons.star,
                              color: Colors.yellow.shade600,
                              size: 18,
                            );
                          } else if (index < rating) {
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
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Text(
                reviewDate,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            review,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}
