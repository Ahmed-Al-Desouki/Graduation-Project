import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/core/widgets/tutorial_tooltip_widget.dart';
import 'package:showcaseview/showcaseview.dart';

class PatientHomeHeader extends StatelessWidget {
  final String userName;
  final String? imageUrl;
  final GlobalKey notificationKey;

  const PatientHomeHeader({
    super.key,
    required this.userName,
    this.imageUrl,
    required this.notificationKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      height: 150.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00BCD4), Color(0xff66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w),
        child: Row(
          children: [
            _buildUserAvatar(),
            SizedBox(width: 12.w),
            Expanded(child: _buildWelcomeText()),
            _buildNotificationIcon(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return CircleAvatar(
      radius: 33.r,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: CachedNetworkImage(
          key: ValueKey(imageUrl),
          imageUrl: imageUrl ?? '',
          width: 66.r,
          height: 66.r,
          fit: BoxFit.cover,
          cacheKey: imageUrl,
          placeholder:
              (context, url) => const CircularProgressIndicator(strokeWidth: 2),
          errorWidget: (context, url, error) => _buildErrorIcon(),
        ),
      ),
    );
  }

  Widget _buildErrorIcon() {
    return SvgPicture.asset(
      Assets.imagesHeartRate,
      height: 35.h,
      width: 35.w,
      colorFilter: const ColorFilter.mode(Color(0xff26A69A), BlendMode.srcIn),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome $userName',
          style: AppStyles.styleSemiBold18Dark.copyWith(color: Colors.white),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        Text(
          'How are you feeling today?',
          style: AppStyles.styleRegular14Gray.copyWith(color: Colors.white70),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return Showcase.withWidget(
      key: notificationKey,
      width: 270.w,
      tooltipPosition: TooltipPosition.bottom,
      container: TutorialTooltipWidget(
        title: 'Notifications',
        description: 'Check your reminders and updates.',
        currentStep: 1,
        totalSteps: 4,
        onNext: () => ShowCaseWidget.of(context).next(),
        onSkip: () => ShowCaseWidget.of(context).dismiss(),
      ),
      height: null,
      child: IconButton(
        icon: Icon(Icons.notifications, color: Colors.white, size: 28.sp),
        onPressed: () {},
      ),
    );
  }
}
