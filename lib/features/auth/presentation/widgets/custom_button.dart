import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isLoading;
  final double borderRadius;
  final double height;  // Tambah properti height

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.borderRadius = 50,
    this.height = 42,  // default tinggi 50
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: height,  // gunakan properti height di sini
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF64B5F6),
              Color(0xFF2196F3),
              Color(0xFF1565C0),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withAlpha(77),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}
