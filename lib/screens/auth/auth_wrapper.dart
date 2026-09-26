import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../representative/representative_dashboard_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const _AuthLoadingScreen(),
      error: (error, _) => _AuthErrorScreen(
        message: 'Authentication error: $error',
      ),
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        final profileAsync = ref.watch(userProfileProvider);

        return profileAsync.when(
          loading: () => const _AuthLoadingScreen(),
          error: (error, _) => _AuthErrorScreen(
            message: 'Failed to load user profile: $error',
            showLogout: true,
          ),
          data: (profile) {
            if (profile == null) {
              return const _AuthErrorScreen(
                message:
                    'User profile not found. Please contact the administrator.',
                showLogout: true,
              );
            }

            if (!profile.active) {
              return const _AuthErrorScreen(
                message:
                    'Your account is inactive. Please contact the administrator.',
                showLogout: true,
              );
            }

            switch (profile.role) {
              case 'admin':
                return AdminDashboardScreen(user: profile);
              case 'medical_rep':
                return RepresentativeDashboardScreen(user: profile);
              default:
                return _AuthErrorScreen(
                  message:
                      'Invalid role (${profile.role}). Please contact the administrator.',
                  showLogout: true,
                );
            }
          },
        );
      },
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_hospital_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Medical Order Management',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthErrorScreen extends ConsumerWidget {
  final String message;
  final bool showLogout;

  const _AuthErrorScreen({
    required this.message,
    this.showLogout = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (showLogout) ...[
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await ref.read(authServiceProvider).signOut();
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Back to Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
