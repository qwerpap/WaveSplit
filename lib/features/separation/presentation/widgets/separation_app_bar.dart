import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/strings.dart';
import '../../../../core/shared/widgets/icon_circle.dart';
import '../../../../core/theme/app_fonts.dart';
import '../bloc/separation_bloc.dart';
import '../bloc/separation_event.dart';

class SeparationAppBar extends StatelessWidget {
  const SeparationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(AppStrings.nowPlaying, style: AppFonts.displaySmall),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {
          context.read<SeparationBloc>().add(const StopTrackEvent());
          context.pop();
        },
      ),
      actions: [
        const IconInCircle(icon: Icons.more_vert),
      ],
    );
  }
}
