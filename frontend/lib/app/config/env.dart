enum AppFlavor {
  dev,
  staging,
  prod,
}

class Env {
  Env._();

  static const AppFlavor flavor = AppFlavor.dev;

  static String get appName {
    switch (flavor) {
      case AppFlavor.dev:
        return 'Mixera Dev';
      case AppFlavor.staging:
        return 'Mixera Staging';
      case AppFlavor.prod:
        return 'Mixera';
    }
  }

  static bool get isDebug => flavor != AppFlavor.prod;
}
