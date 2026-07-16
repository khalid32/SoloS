import 'package:flutter/widgets.dart';
import 'package:solidpod/solidpod.dart';

/// Configuration for the Solid Protocol integration.
///
/// [clientId] is the URL of our hosted Solid-OIDC client identifier document
/// (`web/client-profile.jsonld`, deployed to GitHub Pages). The Solid server
/// validates the login redirect against the `redirect_uris` declared there, so
/// [redirectUris] must stay in sync with that document.
class SolidConfig {
  SolidConfig._();

  /// Our client identifier document, served from the deployed web app.
  static const String clientId =
      'https://khalid32.github.io/SoloS/client-profile.jsonld';

  /// Default Community Solid Server (CSS) issuer to authenticate against.
  static const String defaultServer = 'https://pods.solidcommunity.au';

  /// One redirect URI per platform; solidpod's [pickRedirectUri] selects the
  /// correct one at runtime (https for web, custom scheme for mobile,
  /// localhost loopback for desktop). Must match client-profile.jsonld.
  static const List<String> redirectUris = [
    'https://khalid32.github.io/SoloS/callback.html',
    'com.solos.app://redirect',
    'http://localhost:4400/callback.html',
  ];

  /// The app's data directory name on the Pod.
  static const String appDir = 'solos';

  /// The demo note file. Stored at the Pod root (relative to the Pod) as
  /// plaintext JSON so it round-trips without an encryption key.
  static const String noteFile = 'solos_note.json';
}

/// Thin wrapper around the `solidpod` package: authentication plus a single
/// read/write demo file, so the rest of the app never imports solidpod
/// directly.
class SolidService {
  SolidService._();

  static bool _initialised = false;

  /// Set the app directory name once. Safe to call repeatedly.
  static Future<void> init() async {
    if (_initialised) return;
    await setAppDirName(SolidConfig.appDir);
    _initialised = true;
  }

  /// Whether there is a valid (non-expired) Solid session.
  static Future<bool> isLoggedIn() => isUserLoggedIn();

  /// The logged-in user's WebID, or null if not connected.
  static Future<String?> currentWebId() => getWebId();

  /// Authenticate against [server] (a WebID or issuer URI) using Solid-OIDC.
  /// Returns the resolved WebID on success, or null if login failed/cancelled.
  static Future<String?> connect(BuildContext context, String server) async {
    final result = await solidAuthenticate(
      server,
      context,
      clientId: SolidConfig.clientId,
      redirectUris: SolidConfig.redirectUris,
      postLogoutRedirectUris: SolidConfig.redirectUris,
    );
    if (result == null) return null;
    // solidAuthenticate returns [SolidAuthData, webId, profileTurtle].
    return result[1] as String?;
  }

  /// Write [jsonString] to the demo note file on the Pod (plaintext),
  /// overwriting any existing note. This is a real HTTP write to CSS.
  static Future<void> saveNote(String jsonString) async {
    await writePod(
      SolidConfig.noteFile,
      jsonString,
      encrypted: false,
      createAcl: false,
      overwrite: true,
      pathType: PathType.relativeToPod,
    );
  }

  /// Read the demo note file back from the Pod. Throws
  /// [ResourceNotExistException] if nothing has been saved yet.
  static Future<String> readNote() =>
      readPod(SolidConfig.noteFile, pathType: PathType.relativeToPod);

  /// Log out of the Pod and clear the local session.
  static Future<void> disconnect() async {
    await logoutPod();
  }
}
