// screens/payment/widgets/complete_payment_button.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 「会計を完了する」ボタンウィジェット
class CompletePaymentButton extends StatelessWidget {
  final bool isEnabled;
  final bool isProcessing;
  final VoidCallback onPressed;

  const CompletePaymentButton({
    super.key,
    required this.isEnabled,
    required this.isProcessing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.mPlusRounded1c(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: isProcessing
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(),
              )
            : const Text('会計を完了する'),
      ),
    );
  }
}
