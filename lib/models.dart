import 'package:flutter/material.dart';

/// A dynamic, interchangeable identity. Mirrors `Persona` from the React types.
class Persona {
  final String id;
  final String name;
  final String webId;
  final bool isMaster;

  const Persona({
    required this.id,
    required this.name,
    required this.webId,
    required this.isMaster,
  });
}

/// A Solid application listed in the repository. Mirrors `SolidApp`.
class SolidApp {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String url;

  const SolidApp({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.url,
  });
}

/// An installed instance of a [SolidApp] bound to a [Persona].
/// Mirrors `InstalledApp`.
class InstalledApp {
  final String instanceId;
  final String appId;
  final String personaId;

  const InstalledApp({
    required this.instanceId,
    required this.appId,
    required this.personaId,
  });
}
