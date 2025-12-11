import 'package:flutter/material.dart';

import '../../../core/theme/app_fonts.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/recent_track_card.dart';
import '../widgets/separation_card.dart';
import '../widgets/upload_card.dart';
import '../data/home_data.dart';
import '../../../constants/strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 120;

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: HomeAppBar(),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: bottomPadding,
        ),
        children: [
          UploadCard(onPressed: () {}),
          const SizedBox(height: 10),
          const Text(AppStrings.separationMode, style: AppFonts.displaySmall),
          const SizedBox(height: 10),
          Row(
            children: List.generate(kSeparationOptions.length, (i) {
              final item = kSeparationOptions[i];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: i == 0 ? 0 : 8,
                    right: i == kSeparationOptions.length - 1 ? 0 : 8,
                  ),
                  child: SeparationCard(
                    model: item,
                    isActive: _selectedIndex == i,
                    onTap: () => setState(() => _selectedIndex = i),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 40),
          const Text(AppStrings.recentTracks, style: AppFonts.displaySmall),
          const SizedBox(height: 10),
          RecentTrackCard(),
        ],
      ),
    );
  }
}
