import 'package:flutter/material.dart';

import '../../../../constants/api_constants.dart';
import '../../../../constants/strings.dart';
import '../../../../core/services/network_test_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';

class NetworkDiagnosticDialog extends StatefulWidget {
  final String? testUrl;

  const NetworkDiagnosticDialog({super.key, this.testUrl});

  @override
  State<NetworkDiagnosticDialog> createState() => _NetworkDiagnosticDialogState();
}

class _NetworkDiagnosticDialogState extends State<NetworkDiagnosticDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  NetworkTestResult? _apiResult;
  MediaTestResult? _mediaResult;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
    _runDiagnostics();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
      _apiResult = null;
      _mediaResult = null;
    });

    // Тест API подключения
    _apiResult = await NetworkTestService.testApiConnection();
    setState(() {});

    // Тест медиа файла, если URL предоставлен
    if (widget.testUrl != null) {
      _mediaResult = await NetworkTestService.testMediaUrl(widget.testUrl!);
      setState(() {});
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450, maxHeight: 650),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.05),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.network_check,
                              color: AppColors.primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppStrings.networkDiagnosticsTitle,
                            style: AppFonts.headlineLarge.copyWith(
                              color: AppColors.blackColor,
                            ),
                          ),
                          const Spacer(),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.close,
                                  color: AppColors.greyColor,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoSection(
                              AppStrings.platformLabel,
                              NetworkTestService.getPlatformInfo(),
                              Icons.phone_android,
                            ),
                            
                            _buildInfoSection(
                              AppStrings.apiBaseUrlLabel,
                              ApiConstants.baseUrl,
                              Icons.api,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            if (_apiResult != null) ...[
                              _buildTestResult(
                                AppStrings.apiConnectionLabel,
                                _apiResult!.success,
                                _apiResult!.message,
                                Icons.cloud,
                              ),
                            ],
                            
                            if (_mediaResult != null) ...[
                              const SizedBox(height: 12),
                              _buildTestResult(
                                AppStrings.mediaFileAccessLabel,
                                _mediaResult!.success,
                                _mediaResult!.message,
                                Icons.audiotrack,
                              ),
                              if (_mediaResult!.success && _mediaResult!.contentType != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGreyColor.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Type: ${_mediaResult!.contentType}, Size: ${_mediaResult!.contentLength} bytes',
                                    style: AppFonts.bodySmall.copyWith(
                                      color: AppColors.greyColor,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                            
                            if (_isLoading) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    const CircularProgressIndicator(
                                      color: AppColors.primaryColor,
                                      strokeWidth: 3,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      AppStrings.runningDiagnostics,
                                      style: AppFonts.bodyMedium.copyWith(
                                        color: AppColors.greyColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 24),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _isLoading ? null : _runDiagnostics,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        decoration: BoxDecoration(
                                          color: AppColors.lightGreyColor,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.lightGreyColor,
                                            width: 1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            AppStrings.retestButton,
                                            style: AppFonts.labelLarge.copyWith(
                                              color: _isLoading ? AppColors.greyColor.withOpacity(0.5) : AppColors.greyColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => Navigator.of(context).pop(),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primaryColor.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            AppStrings.closeButton,
                                            style: AppFonts.labelLarge.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            if (_apiResult != null && !_apiResult!.success) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFED7AA),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF59E0B).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Icon(
                                            Icons.lightbulb_rounded,
                                            color: Color(0xFFF59E0B),
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          AppStrings.troubleshootingTips,
                                          style: AppFonts.titleSmall.copyWith(
                                            color: const Color(0xFFF59E0B),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '• Ensure backend is running on ${ApiConstants.baseUrl}\n'
                                      '• For iOS Simulator, use your machine\'s IP address\n'
                                      '• Check if CORS is properly configured\n'
                                      '• Verify network connectivity',
                                      style: AppFonts.bodySmall.copyWith(
                                        color: const Color(0xFFD97706),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGreyColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.lightGreyColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.greyColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.greyColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$title: ',
            style: AppFonts.titleSmall.copyWith(
              color: AppColors.blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.greyColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResult(String title, bool success, String message, IconData icon) {
    final Color bgColor = success ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);
    final Color borderColor = success ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA);
    final Color iconColor = success ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final Color textColor = success ? const Color(0xFF065F46) : const Color(0xFF991B1B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.titleSmall.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppFonts.bodySmall.copyWith(
                    color: textColor.withOpacity(0.8),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}