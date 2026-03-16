import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_images.dart';

class DoctorProfileDrawer extends StatelessWidget {
  final Function(GlobalKey) onScrollToSection;

  final GlobalKey infoKey;
  final GlobalKey aboutKey;
  final GlobalKey achievementsKey;
  final GlobalKey hoursKey;
  final GlobalKey reviewsKey;
  final GlobalKey servicesKey;
  const DoctorProfileDrawer({
    super.key,
    required this.onScrollToSection,
    required this.infoKey,
    required this.aboutKey,
    required this.achievementsKey,
    required this.hoursKey,
    required this.reviewsKey,
    required this.servicesKey,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _item(
                  "Doctor Information",
                  infoKey,
                  icon: Icons.medical_information_outlined,
                ),
                _item("About Me", aboutKey, icon: Icons.description_outlined),
                _item(
                  "Achievements",
                  achievementsKey,
                  icon: Icons.emoji_events,
                ),
                _item("Working Hours", hoursKey, icon: Icons.schedule),
                _item(
                  "Patient's Reviews",
                  reviewsKey,
                  icon: Icons.reviews_outlined,
                ),
                _item(
                  "Services & Pricing",
                  servicesKey,
                  imageAsset: Assets.imagesServices,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      color: const Color(0xfffaf0ff),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
          ),
          SizedBox(height: 12),
          Text(
            "Quick Navigation",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
    String title,
    GlobalKey key, {
    IconData? icon,
    String? imageAsset,
  }) {
    return ListTile(
      leading:
          imageAsset != null
              ? SvgPicture.asset(
                imageAsset,
                width: 22,
                height: 22,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF754EA6),
                  BlendMode.srcIn,
                ),
              )
              : Icon(icon, color: const Color(0xFF754EA6)),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      onTap: () => onScrollToSection(key),
    );
  }
}
