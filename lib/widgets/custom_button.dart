import 'package:flutter/material.dart';
import '../app/themes/app_colors.dart';
import '../app/themes/app_text_styles.dart';

/// Custom Button Widget
/// Reusable button dengan berbagai style
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final bool isOutlined;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50,
    this.borderRadius = 12,
    this.padding,
    this.icon,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool disabled = isDisabled || isLoading || onPressed == null;

    if (isOutlined) {
      return _buildOutlinedButton(disabled);
    }

    return _buildElevatedButton(disabled);
  }

  Widget _buildElevatedButton(bool disabled) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled
              ? AppColors.buttonDisabled
              : (backgroundColor ?? AppColors.buttonPrimary),
          foregroundColor: textColor ?? AppColors.buttonText,
          disabledBackgroundColor: AppColors.buttonDisabled,
          disabledForegroundColor: AppColors.textSecondary,
          elevation: 0,
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildOutlinedButton(bool disabled) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: disabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: disabled
              ? AppColors.textSecondary
              : (backgroundColor ?? AppColors.primary),
          disabledForegroundColor: AppColors.textSecondary,
          side: BorderSide(
            color: disabled
                ? AppColors.border
                : (backgroundColor ?? AppColors.primary),
            width: 1.5,
          ),
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.buttonLarge.copyWith(
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: AppTextStyles.buttonLarge.copyWith(
        color: textColor,
      ),
    );
  }
}
