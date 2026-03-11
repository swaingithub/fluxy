import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'package:fluxy_animations/fluxy_animations.dart';
import 'auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.find<AuthController>();

    return Fx(() {
      final isDark = FxTheme.isDarkMode;

      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            Fx.image('https://images.unsplash.com/photo-1488085061387-422e29b40080?auto=format&fit=crop&w=1600&q=80')
                .hFull().wFull().cover().blur(5).opacity(isDark ? 0.4 : 0.2),
            
            Fx.safe(
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: FxEntrance(
                    slideOffset: const Offset(0, 50),
                    child: Fx.box(
                      style: FxStyle(
                        backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        glass: isDark ? 20 : 0,
                        padding: const EdgeInsets.all(32),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                        shadows: isDark ? [] : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          )
                        ],
                      ),
                      child: Fx.col(
                        gap: 32,
                        children: [
                          Fx.col(
                            gap: 8,
                            children: [
                              Fx.text('Welcome Back')
                                  .bold()
                                  .fontSize(28)
                                  .color(isDark ? Colors.white : const Color(0xFF0F172A)),
                              Fx.text('Sign in to continue your adventure')
                                  .color(isDark ? Colors.white54 : Colors.black45)
                                  .textSm(),
                            ],
                          ),
  
                          Fx.col(
                            gap: 20,
                            children: [
                              Fx.input(
                                signal: controller.email,
                                placeholder: 'Email Address',
                                icon: Icons.email_outlined,
                                style: FxStyle(
                                  backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                                  color: isDark ? Colors.white : Colors.black87,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              Fx.password(
                                signal: controller.password,
                                placeholder: 'Password',
                                icon: Icons.lock_outline,
                                style: FxStyle(
                                  backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                                  color: isDark ? Colors.white : Colors.black87,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ],
                          ),
  
                          Fx.row(
                            justify: MainAxisAlignment.end,
                            children: [
                              Fx.text('Forgot Password?').color(Fx.primary).textXs().bold().btn(onTap: () {}),
                            ],
                          ),
  
                          FxBoing(
                            onTap: controller.isLoggingIn.value ? null : () => controller.login(),
                            child: Fx.row(
                              justify: MainAxisAlignment.center,
                              children: [
                                if (controller.isLoggingIn.value)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                                  ),
                                Fx.text(controller.isLoggingIn.value ? 'Authenticating...' : 'Sign In')
                                    .bold()
                                    .whiteText()
                                    .textLg(),
                              ],
                            )
                            .wFull()
                            .py(18)
                            .bg.color(const Color(0xFF6366F1))
                            .rounded(16)
                            .shadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blur: 20, offset: const Offset(0, 8)),
                          ),
  
                          Fx.row(
                            justify: MainAxisAlignment.center,
                            gap: 8,
                            children: [
                              Fx.text("Don't have an account?")
                                  .color(isDark ? Colors.white54 : Colors.black45)
                                  .textSm(),
                              Fx.text('Create Account').color(Fx.primary).bold().textSm().btn(onTap: () {}),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
