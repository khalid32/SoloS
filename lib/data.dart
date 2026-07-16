import 'package:flutter/material.dart';
import 'models.dart';

/// The verified, decentralized Solid applications listed in the repository.
/// Mirrors `REPOSITORY_APPS` from the React `data.ts`.
///
/// lucide-react icons are mapped to their closest Material icon:
///   FileText  -> description
///   Users     -> group
///   Calendar  -> calendar_month
///   Mail      -> mail
///   HardDrive -> storage
const List<SolidApp> repositoryApps = [
  SolidApp(
    id: 'solid-notes',
    name: 'Solid Notes',
    description: 'Decentralized markdown note-taking.',
    icon: Icons.description_outlined,
    url: 'https://example.com/notes',
  ),
  SolidApp(
    id: 'solid-contacts',
    name: 'Solid Contacts',
    description: 'Manage your contacts securely.',
    icon: Icons.group_outlined,
    url: 'https://example.com/contacts',
  ),
  SolidApp(
    id: 'solid-calendar',
    name: 'Solid Calendar',
    description: 'Private, syncable calendar.',
    icon: Icons.calendar_month_outlined,
    url: 'https://example.com/calendar',
  ),
  SolidApp(
    id: 'solid-mail',
    name: 'Solid Mail',
    description: 'End-to-end encrypted email client.',
    icon: Icons.mail_outline,
    url: 'https://example.com/mail',
  ),
  SolidApp(
    id: 'pod-explorer',
    name: 'Pod Explorer',
    description: 'Manage files in your Solid Pod.',
    icon: Icons.storage_outlined,
    url: 'https://example.com/explorer',
  ),
];

/// Convenience lookup mirroring `REPOSITORY_APPS.find(a => a.id === ...)`.
SolidApp? findAppById(String id) {
  for (final app in repositoryApps) {
    if (app.id == id) return app;
  }
  return null;
}
