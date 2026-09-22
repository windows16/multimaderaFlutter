import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/data/services/auth_service.dart'; // 👈 agregá este import

// 👇 AGREGAR: expone el AuthService para poder hacer ref.read(authServiceProvider)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Escucha CADA cambio de sesión (login, logout, token refresh)
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// Usuario actual, derivado del stream de arriba (se actualiza solo)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return authState.when(
    data: (state) => state.session?.user,
    loading: () => Supabase.instance.client.auth.currentUser, // valor inicial
    error: (_, __) => null,
  );
});

// Booleano simple, útil para el redirect del router
final estaLogueadoProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});
