import 'package:flutter/material.dart';
import 'package:lecture_formater/core/services/loading_manager.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;

  const LoadingOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LoadingState>(
      valueListenable: LoadingManager.listenable,

      // ========================================================
      // مهم جدًا جدًا
      // ========================================================
      //
      // التطبيق الكامل يوضع هنا كـ child.
      //
      // عندما تتغير LoadingState:
      // سيتم إعادة بناء builder فقط،
      // وليس child نفسه.
      //
      child: child,

      builder: (context, state, child) {
        return Stack(
          children: [
            // ==================================================
            // التطبيق
            // ==================================================

            child!,

            // ==================================================
            // Loading Overlay
            // ==================================================
            if (state.isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black26,

                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 180,
                        maxWidth: 320,
                      ),

                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 25,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ====================================
                          // الرسالة
                          // ====================================

                          if (state.message != null &&
                              state.message!.trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),

                              child: Text(
                                state.message!,
                                textAlign: TextAlign.center,

                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),

                          // ====================================
                          // دائرة التحميل
                          // ====================================
                          SizedBox(
                            width: 38,
                            height: 38,

                            child: CircularProgressIndicator(
                              color: state.color,
                              strokeWidth: 3.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
