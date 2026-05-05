import 'package:flutter/material.dart';
import 'package:graduation_project/core/widgets/fading_widget.dart';
import 'package:graduation_project/core/widgets/skeleton_grey_box.dart';

class DoctorCardLoadingIndicator extends StatelessWidget {
  const DoctorCardLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return FadingWidget(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonGreyBox(width: 150, height: 16),
                          const SizedBox(height: 8),
                          SkeletonGreyBox(width: 100, height: 14),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(left: 60),
                  child: SkeletonGreyBox(width: 180, height: 14),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: SkeletonGreyBox(width: 90, height: 14),
                    ),
                    SizedBox(width: 10),
                    SkeletonGreyBox(width: 90, height: 14),
                  ],
                ),
                const SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    width: double.infinity,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
