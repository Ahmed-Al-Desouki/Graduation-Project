import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/review_card.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key});

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
                  TextButton(
                    onPressed: () {},
                    child: Text(
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (index) => Icon(
                              Icons.star,
                              color: Colors.yellow.shade600,
                              size: 15,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "4.9",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
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
                      "Based on 2,847 reviews",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              ReviewCard(
                name: "Emily Rodriguez",
                imageUrl: "https://i.pravatar.cc/150?img=47",
                daysAgo: "2 days ago",
                review:
                    "Dr. Johnson is exceptional! She took the time to explain my condition thoroughly and made me feel comfortable throughout the entire process.",
              ),
              SizedBox(height: 15),
              ReviewCard(
                name: "Michael Chen",
                imageUrl: "https://i.pravatar.cc/150?img=12",
                daysAgo: "5 days ago",
                review:
                    "Outstanding doctor! Very professional, knowledgeable, and caring. Highly recommend Dr. Johnson for any cardiac concerns.",
              ),
              SizedBox(height: 15),
              ReviewCard(
                name: "Sarah Williams",
                imageUrl: "https://i.pravatar.cc/150?img=28",
                daysAgo: "1 week ago",
                review:
                    "Great experience overall. Dr. Johnson is very thorough in her examinations and provides clear explanations. The only minor issue was the waiting time, but the quality of care made up for it.",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
