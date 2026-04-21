import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReviewCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String daysAgo;
  final String review;
  const ReviewCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.daysAgo,
    required this.review,
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
            color: Colors.black.withValues(alpha: 0.04),
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
              CircleAvatar(radius: 20, backgroundImage: NetworkImage(imageUrl)),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          color: Colors.yellow.shade600,
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                daysAgo,
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
