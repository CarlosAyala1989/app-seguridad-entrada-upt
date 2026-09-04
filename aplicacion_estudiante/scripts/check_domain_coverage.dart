import 'dart:io';

void main(List<String> arguments) {
  if (arguments.length != 2) {
    stderr.writeln('Uso: dart run scripts/check_domain_coverage.dart <lcov> <umbral>');
    exitCode = 64;
    return;
  }

  final report = File(arguments[0]);
  final threshold = double.tryParse(arguments[1]);
  if (!report.existsSync() || threshold == null) {
    stderr.writeln('No se encontró el reporte o el umbral no es válido.');
    exitCode = 65;
    return;
  }

  var inDomainFile = false;
  var found = 0;
  var hit = 0;

  for (final line in report.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      final normalized = line.substring(3).replaceAll('\\', '/');
      final isFeatureSource = normalized.startsWith('lib/features/') ||
          normalized.contains('/lib/features/');
      inDomainFile = isFeatureSource &&
          normalized.contains('/domain/');
    } else if (inDomainFile && line.startsWith('DA:')) {
      final parts = line.substring(3).split(',');
      if (parts.length >= 2) {
        found++;
        if ((int.tryParse(parts[1]) ?? 0) > 0) hit++;
      }
    }
  }

  if (found == 0) {
    stderr.writeln('No se encontraron líneas ejecutables de dominio en LCOV.');
    exitCode = 1;
    return;
  }

  final coverage = hit * 100 / found;
  stdout.writeln(
    'Cobertura de dominio: ${coverage.toStringAsFixed(2)}% ($hit/$found)',
  );
  if (coverage < threshold) {
    stderr.writeln('La cobertura es inferior al umbral de $threshold%.');
    exitCode = 1;
  }
}
