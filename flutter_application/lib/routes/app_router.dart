import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'route_names.dart';
import '../core/widgets/home_screen.dart';
import '../core/widgets/login_screen.dart';
import '../features/clientes/presentation/clientes_screen.dart';

// Adaptador: convierte un Stream en un Listenable que go_router entiende
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.login,

    // Escucha directo el stream de Supabase (no depende de que Riverpod reconstruya el provider)
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),

    redirect: (context, state) {
      final autenticado = Supabase.instance.client.auth.currentSession != null;
      final vaHaciaLogin = state.matchedLocation == AppRoutes.login;

      if (!autenticado && !vaHaciaLogin) return AppRoutes.login;
      if (autenticado && vaHaciaLogin) return AppRoutes.home;
      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.clientes,
        builder: (context, state) => const ClientesScreen(),
      ),
    ],
  );
});
