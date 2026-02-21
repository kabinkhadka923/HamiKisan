import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

class SecurityAudit {
  // Enhanced patterns for security scanning
  static final Map<String, RegExp> _sensitivePatterns = {
    'hardcoded_passwords':
        RegExp(r'''password\s*[:=]\s*["'][^"']*["']''', caseSensitive: false),
    'tokens': RegExp(
        r'''(token|api[_-]?key|secret|private[_-]?key)\s*[:=]\s*["'][^"']*["']''',
        caseSensitive: false),
    'firebase': RegExp(r'''firebase.*["'][^"']*["']''', caseSensitive: false),
    'aws_keys': RegExp(r'(aws[_-]?(secret|key|access))|AKIA[0-9A-Z]{16}',
        caseSensitive: false),
    'database_urls': RegExp(r'''(postgres|mysql|mongodb)://[^"']*["']''',
        caseSensitive: false),
    'email_credentials':
        RegExp(r'''(smtp|email).*["'][^"']*["']''', caseSensitive: false),
  };

  static final Map<String, RegExp> _debugPatterns = {
    'print': RegExp(r'print\('),
    'logger_calls': RegExp(r'Logger\.(d|i|w|e|v)\('),
    'console_log': RegExp(r'console\.log'),
    'flutter_logs': RegExp(r'log\('),
  };

  static final Map<String, RegExp> _insecurePatterns = {
    'shared_prefs': RegExp(
        r'SharedPreferences.*setString.*(token|password|secret)',
        caseSensitive: false),
    'file_storage': RegExp(r'File.*writeAsString.*(token|password|secret)',
        caseSensitive: false),
    'insecure_crypto': RegExp(r'crypto\..*MD5|SHA1', caseSensitive: false),
    'http_not_https': RegExp(r'''http://[^"']*["']''', caseSensitive: false),
    'permissions_missing':
        RegExp(r'Missing.*permission.*check', caseSensitive: false),
  };

  static final Map<String, RegExp> _performancePatterns = {
    'nested_builders':
        RegExp(r'Build.*build.*Build.*build', caseSensitive: false),
    'setstate_in_build': RegExp(r'setState.*build', caseSensitive: false),
    'large_lists': RegExp(r'List\.generate.*1000', caseSensitive: false),
  };

  static final Map<String, RegExp> _securityBestPractices = {
    'input_validation':
        RegExp(r'validate.*input|sanitize.*input', caseSensitive: false),
    'error_handling': RegExp(r'try.*catch|on.*Error', caseSensitive: false),
    'encryption_used': RegExp(r'encrypt|AES|RSA', caseSensitive: false),
    'biometric_auth':
        RegExp(r'biometric|fingerprint|faceid', caseSensitive: false),
  };

  // Configuration
  static final Map<String, dynamic> _config = {
    'exclude_directories': ['test', 'mock', 'generated'],
    'exclude_files': ['*.g.dart', '*.freezed.dart'],
    'max_file_size_mb': 10,
    'auto_fix_enabled': true,
    'generate_report': true,
    'report_format': 'markdown', // json, markdown, html
  };

  static Future<void> performSecurityAudit({
    bool autoFix = true,
    bool verbose = false,
    String outputFormat = 'markdown',
  }) async {
    final auditStartTime = DateTime.now();
    final issues = <SecurityIssue>[];
    final stats = AuditStats();

    // Load configuration
    await _loadConfiguration();

    // Run all security checks
    await _runAllChecks(issues, stats, verbose);

    // Generate comprehensive report
    await _generateEnhancedReport(issues, stats, auditStartTime, outputFormat);

    // Auto-fix issues if enabled
    if (autoFix && _config['auto_fix_enabled']) {
      await _autoFixIssues(issues, verbose);
    }

    // Export results
    await _exportResults(issues, stats, outputFormat);
  }

  static Future<void> _runAllChecks(
    List<SecurityIssue> issues,
    AuditStats stats,
    bool verbose,
  ) async {
    final dartFiles = await _getDartFiles();
    stats.totalFiles = dartFiles.length;

    if (verbose) {}

    for (final file in dartFiles) {
      if (verbose) {}

      final content = await file.readAsString();
      final lines = content.split('\n');
      stats.totalLines += lines.length;

      // Check file size
      final fileSize = file.lengthSync();
      if (fileSize > _config['max_file_size_mb'] * 1024 * 1024) {
        issues.add(SecurityIssue(
          file: file.path,
          line: 0,
          column: 0,
          severity: Severity.medium,
          type: IssueType.performance,
          message:
              'File too large (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)',
          recommendation: 'Split into smaller files',
          code: 'File: ${path.basename(file.path)}',
        ));
      }

      // Run pattern checks
      await _checkPatterns(content, lines, file.path, issues, stats);

      // Check imports
      await _checkImports(content, file.path, issues, stats);

      // Check dependencies
      await _checkDependencies(file.path, issues, stats);
    }

    // Analyze pubspec.yaml
    await _analyzePubspec(issues, stats);

    // Analyze Android/iOS configurations
    await _analyzePlatformConfigs(issues, stats);
  }

  static Future<void> _checkPatterns(
    String content,
    List<String> lines,
    String filePath,
    List<SecurityIssue> issues,
    AuditStats stats,
  ) async {
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineNumber = i + 1;

      // Check for sensitive data
      for (final entry in _sensitivePatterns.entries) {
        if (entry.value.hasMatch(line)) {
          final issue = SecurityIssue(
            file: filePath,
            line: lineNumber,
            column: _getColumnNumber(line, entry.value),
            severity: Severity.critical,
            type: IssueType.hardcodedCredentials,
            message: '${entry.key.replaceAll('_', ' ')} found',
            recommendation: 'Use environment variables or secure storage',
            code: line.trim(),
          );
          issues.add(issue);
          stats.sensitiveDataFound++;
        }
      }

      // Check for debug statements
      for (final entry in _debugPatterns.entries) {
        if (entry.value.hasMatch(line)) {
          final issue = SecurityIssue(
            file: filePath,
            line: lineNumber,
            column: _getColumnNumber(line, entry.value),
            severity: Severity.medium,
            type: IssueType.debugStatement,
            message: '${entry.key.replaceAll('_', ' ')} found',
            recommendation: 'Remove for production',
            code: line.trim(),
          );
          issues.add(issue);
          stats.debugStatementsFound++;
        }
      }

      // Check for insecure patterns
      for (final entry in _insecurePatterns.entries) {
        if (entry.value.hasMatch(line)) {
          final issue = SecurityIssue(
            file: filePath,
            line: lineNumber,
            column: _getColumnNumber(line, entry.value),
            severity: Severity.high,
            type: IssueType.insecureStorage,
            message: '${entry.key.replaceAll('_', ' ')} found',
            recommendation: 'Use secure alternatives',
            code: line.trim(),
          );
          issues.add(issue);
          stats.insecurePatternsFound++;
        }
      }

      // Check for performance issues
      for (final entry in _performancePatterns.entries) {
        if (entry.value.hasMatch(line)) {
          final issue = SecurityIssue(
            file: filePath,
            line: lineNumber,
            column: _getColumnNumber(line, entry.value),
            severity: Severity.low,
            type: IssueType.performance,
            message: '${entry.key.replaceAll('_', ' ')} found',
            recommendation: 'Optimize for better performance',
            code: line.trim(),
          );
          issues.add(issue);
          stats.performanceIssuesFound++;
        }
      }

      // Check for security best practices
      for (final entry in _securityBestPractices.entries) {
        if (entry.value.hasMatch(line)) {
          stats.securityBestPracticesFound++;
        }
      }
    }
  }

  static Future<void> _checkImports(
    String content,
    String filePath,
    List<SecurityIssue> issues,
    AuditStats stats,
  ) async {
    final importPattern = RegExp(r'''^import\s+['"]([^'"]+)['"]''');
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final match = importPattern.firstMatch(lines[i]);
      if (match != null) {
        final import = match.group(1)!;

        // Check for insecure imports
        if (_isInsecureImport(import)) {
          issues.add(SecurityIssue(
            file: filePath,
            line: i + 1,
            column: 0,
            severity: Severity.high,
            type: IssueType.insecureDependency,
            message: 'Insecure import detected',
            recommendation: 'Use alternative package',
            code: import,
          ));
          stats.insecureImportsFound++;
        }

        stats.totalImports++;
      }
    }
  }

  static bool _isInsecureImport(String import) {
    final insecureImports = [
      'package:http/http.dart', // Should use package:dio with interceptors
      'package:sqflite/sqflite.dart', // Should have proper encryption
      'package:shared_preferences/shared_preferences.dart', // For sensitive data
    ];

    return insecureImports.any((insecure) => import.contains(insecure));
  }

  static Future<void> _checkDependencies(
    String filePath,
    List<SecurityIssue> issues,
    AuditStats stats,
  ) async {
    // Check for outdated or vulnerable dependencies
    // This would integrate with external vulnerability databases
    // For now, we'll check for known vulnerable patterns
  }

  static Future<void> _analyzePubspec(
    List<SecurityIssue> issues,
    AuditStats stats,
  ) async {
    final pubspecFile = File('pubspec.yaml');
    if (!await pubspecFile.exists()) return;

    final content = await pubspecFile.readAsString();
    final pubspec = loadYaml(content);

    if (pubspec is! YamlMap) return;

    // Check dependencies
    final dependencies = pubspec['dependencies'] as YamlMap?;
    if (dependencies != null) {
      stats.totalDependencies = dependencies.length;

      // Check for outdated or vulnerable dependencies
      for (final dep in dependencies.keys) {
        final version = dependencies[dep];

        // Check for known vulnerable versions
        if (_isVulnerableDependency(dep.toString(), version.toString())) {
          issues.add(SecurityIssue(
            file: 'pubspec.yaml',
            line: 0,
            column: 0,
            severity: Severity.high,
            type: IssueType.vulnerableDependency,
            message: 'Potentially vulnerable dependency: $dep',
            recommendation: 'Update to latest secure version',
            code: '$dep: $version',
          ));
          stats.vulnerableDependencies++;
        }
      }
    }

    // Check for security-related packages
    final hasSecurityPackages = _hasSecurityPackages(dependencies);
    if (!hasSecurityPackages) {
      issues.add(SecurityIssue(
        file: 'pubspec.yaml',
        line: 0,
        column: 0,
        severity: Severity.medium,
        type: IssueType.missingSecurity,
        message: 'Missing security packages',
        recommendation:
            'Add packages like flutter_secure_storage, encrypt, etc.',
        code: 'No security packages found',
      ));
    }
  }

  static bool _isVulnerableDependency(String package, String version) {
    // This should integrate with vulnerability databases
    // For now, check for known patterns
    final vulnerablePackages = {
      'sqflite': r'^[0-1]\.', // Versions below 2.0
      'http': r'^[0-9]\.12\.', // Specific vulnerable versions
    };

    if (vulnerablePackages.containsKey(package)) {
      return RegExp(vulnerablePackages[package]!).hasMatch(version);
    }

    return false;
  }

  static bool _hasSecurityPackages(YamlMap? dependencies) {
    if (dependencies == null) return false;

    final securityPackages = [
      'flutter_secure_storage',
      'encrypt',
      'flutter_local_auth',
      'sentry_flutter',
      'firebase_crashlytics',
    ];

    return securityPackages.any((pkg) => dependencies.keys.contains(pkg));
  }

  static Future<void> _analyzePlatformConfigs(
    List<SecurityIssue> issues,
    AuditStats stats,
  ) async {
    // Check Android manifest
    await _checkAndroidManifest(issues, stats);

    // Check iOS info.plist
    await _checkIOSInfoPlist(issues, stats);
  }

  static Future<void> _checkAndroidManifest(
    List<SecurityIssue> issues,
    AuditStats stats,
  ) async {
    final manifestFile = File('android/app/src/main/AndroidManifest.xml');
    if (!await manifestFile.exists()) return;

    final content = await manifestFile.readAsString();

    // Check for network security config
    if (!content.contains('networkSecurityConfig')) {
      issues.add(SecurityIssue(
        file: manifestFile.path,
        line: 0,
        column: 0,
        severity: Severity.high,
        type: IssueType.missingSecurity,
        message: 'Missing network security configuration',
        recommendation: 'Add networkSecurityConfig to AndroidManifest.xml',
        code: 'android:networkSecurityConfig="@xml/network_security_config"',
      ));
    }

    // Check for backup permissions
    if (content.contains('android:allowBackup="true"')) {
      issues.add(SecurityIssue(
        file: manifestFile.path,
        line: 0,
        column: 0,
        severity: Severity.medium,
        type: IssueType.insecureConfiguration,
        message: 'App backup enabled',
        recommendation: 'Disable app backup or exclude sensitive data',
        code: 'android:allowBackup="true"',
      ));
    }
  }

  static Future<void> _checkIOSInfoPlist(
    List<SecurityIssue> issues,
    AuditStats stats,
  ) async {
    final infoPlistFile = File('ios/Runner/Info.plist');
    if (!await infoPlistFile.exists()) return;

    final content = await infoPlistFile.readAsString();

    // Check for ATS (App Transport Security)
    if (!content.contains('NSAppTransportSecurity')) {
      issues.add(SecurityIssue(
        file: infoPlistFile.path,
        line: 0,
        column: 0,
        severity: Severity.high,
        type: IssueType.missingSecurity,
        message: 'Missing App Transport Security configuration',
        recommendation: 'Add NSAppTransportSecurity to Info.plist',
        code: '<key>NSAppTransportSecurity</key>',
      ));
    }
  }

  static Future<void> _autoFixIssues(
      List<SecurityIssue> issues, bool verbose) async {
    for (final issue in issues) {
      if (issue.type == IssueType.debugStatement) {
        try {
          await _fixDebugPrint(issue, verbose);
        } catch (_) {
          if (verbose) {
            // Silent catch
          }
        }
      }

      if (issue.type == IssueType.hardcodedCredentials &&
          issue.severity == Severity.critical) {
        await _flagForManualReview(issue, verbose);
      }
    }
  }

  static Future<void> _fixDebugPrint(SecurityIssue issue, bool verbose) async {
    final file = File(issue.file);
    final content = await file.readAsString();
    final lines = content.split('\n');

    if (issue.line <= lines.length) {
      final line = lines[issue.line - 1];

      // Remove print statements but keep the logic if any
      final fixedLine =
          line.replaceAll(RegExp(r'print\(.*\);'), '// Removed debug print');
      lines[issue.line - 1] = fixedLine;

      await file.writeAsString(lines.join('\n'));

      if (verbose) {}
    }
  }

  static Future<void> _flagForManualReview(
      SecurityIssue issue, bool verbose) async {
    final reviewFile = File('reports/manual_review.md');

    if (!await reviewFile.exists()) {
      await reviewFile.create(recursive: true);
      await reviewFile.writeAsString('# Manual Review Required\n\n');
    }

    final content = await reviewFile.readAsString();
    final reviewEntry = '''
## ${issue.file}:${issue.line}
- **Severity**: ${issue.severity.name.toUpperCase()}
- **Type**: ${issue.type.name}
- **Issue**: ${issue.message}
- **Code**: `${issue.code}`
- **Recommendation**: ${issue.recommendation}

---
''';

    await reviewFile.writeAsString(content + reviewEntry);

    if (verbose) {}
  }

  static Future<void> _generateEnhancedReport(
    List<SecurityIssue> issues,
    AuditStats stats,
    DateTime startTime,
    String format,
  ) async {
    // Summary

    // Issues by severity
    final criticalIssues =
        issues.where((i) => i.severity == Severity.critical).toList();

    // Detailed breakdown

    // Risk assessment
    final riskScore = _calculateRiskScore(issues);

    if (riskScore >= 8) {
    } else if (riskScore >= 5) {
    } else {}

    // Recommendations
    if (criticalIssues.isNotEmpty) {}
    if (stats.vulnerableDependencies > 0) {}
    if (stats.securityBestPracticesFound < 10) {}
    if (stats.insecureImportsFound > 0) {}
  }

  static double _calculateRiskScore(List<SecurityIssue> issues) {
    double score = 0;

    for (final issue in issues) {
      switch (issue.severity) {
        case Severity.critical:
          score += 3;
          break;
        case Severity.high:
          score += 2;
          break;
        case Severity.medium:
          score += 1;
          break;
        case Severity.low:
          score += 0.5;
          break;
      }
    }

    // Normalize to 0-10 scale
    return (score / (issues.length * 3)) * 10;
  }

  static Future<void> _exportResults(
    List<SecurityIssue> issues,
    AuditStats stats,
    String format,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final reportsDir = Directory('reports');

    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    if (format == 'json') {
      await _exportJsonReport(issues, stats, timestamp);
    } else if (format == 'html') {
      await _exportHtmlReport(issues, stats, timestamp);
    } else {
      await _exportMarkdownReport(issues, stats, timestamp);
    }
  }

  static Future<void> _exportJsonReport(
    List<SecurityIssue> issues,
    AuditStats stats,
    int timestamp,
  ) async {
    final report = {
      'timestamp': timestamp,
      'issues': issues.map((issue) => issue.toJson()).toList(),
      'summary': {
        'total': issues.length,
        'critical': issues.where((i) => i.severity == Severity.critical).length,
        'high': issues.where((i) => i.severity == Severity.high).length,
        'medium': issues.where((i) => i.severity == Severity.medium).length,
        'low': issues.where((i) => i.severity == Severity.low).length,
      },
    };

    final file = File('reports/security_audit_$timestamp.json');
    await file.writeAsString(json.encode(report, toEncodable: (object) {
      if (object is SecurityIssue) return object.toJson();
      return object.toString();
    }));
  }

  static Future<void> _exportHtmlReport(
    List<SecurityIssue> issues,
    AuditStats stats,
    int timestamp,
  ) async {
    final html = '''
<!DOCTYPE html>
<html>
<head>
    <title>HamiKisan Security Audit Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .critical { color: #d32f2f; font-weight: bold; }
        .high { color: #f57c00; }
        .medium { color: #fbc02d; }
        .low { color: #388e3c; }
        .issue { border: 1px solid #ddd; padding: 15px; margin: 10px 0; }
        .summary { background: #f5f5f5; padding: 20px; }
    </style>
</head>
<body>
    <h1>🔒 HamiKisan Security Audit Report</h1>
    <div class="summary">
        <h2>Summary</h2>
        <p>Total Issues: ${issues.length}</p>
        <p>Critical: <span class="critical">${issues.where((i) => i.severity == Severity.critical).length}</span></p>
        <p>High: <span class="high">${issues.where((i) => i.severity == Severity.high).length}</span></p>
        <p>Medium: <span class="medium">${issues.where((i) => i.severity == Severity.medium).length}</span></p>
        <p>Low: <span class="low">${issues.where((i) => i.severity == Severity.low).length}</span></p>
    </div>
    <h2>Issues</h2>
    ${issues.map((issue) => '''
    <div class="issue">
        <h3 class="${issue.severity.name}">${issue.severity.name.toUpperCase()}: ${issue.file}:${issue.line}</h3>
        <p><strong>Message:</strong> ${issue.message}</p>
        <p><strong>Recommendation:</strong> ${issue.recommendation}</p>
        <p><strong>Code:</strong> <code>${issue.code}</code></p>
    </div>
    ''').join('')}
</body>
</html>
''';

    final file = File('reports/security_audit_$timestamp.html');
    await file.writeAsString(html);
  }

  static Future<void> _exportMarkdownReport(
    List<SecurityIssue> issues,
    AuditStats stats,
    int timestamp,
  ) async {
    final criticalIssues =
        issues.where((i) => i.severity == Severity.critical).toList();
    final highIssues =
        issues.where((i) => i.severity == Severity.high).toList();
    final mediumIssues =
        issues.where((i) => i.severity == Severity.medium).toList();
    final lowIssues = issues.where((i) => i.severity == Severity.low).toList();

    final markdown = '''
# 🔒 HamiKisan Security Audit Report

**Generated:** ${DateTime.now().toIso8601String()}

## 📊 Executive Summary

| Metric | Count |
|--------|-------|
| Total Files Scanned | ${stats.totalFiles} |
| Total Issues | ${issues.length} |
| Critical Issues | ${criticalIssues.length} 🔴 |
| High Issues | ${highIssues.length} ⚠️ |
| Medium Issues | ${mediumIssues.length} 🔍 |
| Low Issues | ${lowIssues.length} 📝 |

## 🚨 Critical Issues (${criticalIssues.length})

${criticalIssues.map((issue) => '''
### 🔴 ${path.basename(issue.file)}:${issue.line}
- **Message:** ${issue.message}
- **Recommendation:** ${issue.recommendation}
- **Code:** `${issue.code}`
''').join('\n')}

## ⚠️ High Issues (${highIssues.length})

${highIssues.map((issue) => '''
### ⚠️ ${path.basename(issue.file)}:${issue.line}
- **Message:** ${issue.message}
- **Recommendation:** ${issue.recommendation}
- **Code:** `${issue.code}`
''').join('\n')}

## 💡 Recommendations

1. **Immediate Action Required:** Fix all critical issues
2. **Security Hardening:** Implement network security config
3. **Dependency Update:** Check for vulnerable packages
4. **Code Review:** Review all flagged insecure patterns

## 📈 Next Steps

1. Review this report with development team
2. Prioritize fixes based on severity
3. Schedule security training
4. Implement CI/CD security scanning

---

*Report generated by HamiKisan Security Audit Tool*
''';

    final file = File('reports/security_audit_$timestamp.md');
    await file.writeAsString(markdown);
  }

  static Future<List<File>> _getDartFiles() async {
    final directory = Directory('lib');
    final files = <File>[];

    await for (final entity in directory.list(recursive: true)) {
      if (entity is File &&
          entity.path.endsWith('.dart') &&
          !_isExcluded(entity.path)) {
        files.add(entity);
      }
    }

    return files;
  }

  static bool _isExcluded(String filePath) {
    final excludedDirs = _config['exclude_directories'] as List<String>;
    final excludedFiles = _config['exclude_files'] as List<String>;

    // Check excluded directories
    for (final dir in excludedDirs) {
      if (filePath.contains('/$dir/')) {
        return true;
      }
    }

    // Check excluded file patterns
    for (final pattern in excludedFiles) {
      if (RegExp(pattern.replaceAll('*', '.*'))
          .hasMatch(path.basename(filePath))) {
        return true;
      }
    }

    return false;
  }

  static int _getColumnNumber(String line, RegExp pattern) {
    final match = pattern.firstMatch(line);
    return match?.start ?? 0;
  }

  static Future<void> _loadConfiguration() async {
    final configFile = File('security_audit_config.yaml');

    if (await configFile.exists()) {
      final content = await configFile.readAsString();
      final yaml = loadYaml(content);

      if (yaml is YamlMap) {
        _config.addAll(yaml.cast<String, dynamic>());
      }
    }
  }
}

class SecurityIssue {
  final String file;
  final int line;
  final int column;
  final Severity severity;
  final IssueType type;
  final String message;
  final String recommendation;
  final String code;

  SecurityIssue({
    required this.file,
    required this.line,
    required this.column,
    required this.severity,
    required this.type,
    required this.message,
    required this.recommendation,
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'line': line,
      'column': column,
      'severity': severity.name,
      'type': type.name,
      'message': message,
      'recommendation': recommendation,
      'code': code,
    };
  }
}

class AuditStats {
  int totalFiles = 0;
  int totalLines = 0;
  int totalDependencies = 0;
  int totalImports = 0;
  int sensitiveDataFound = 0;
  int debugStatementsFound = 0;
  int insecurePatternsFound = 0;
  int performanceIssuesFound = 0;
  int securityBestPracticesFound = 0;
  int insecureImportsFound = 0;
  int vulnerableDependencies = 0;
}

enum Severity {
  critical,
  high,
  medium,
  low,
}

enum IssueType {
  hardcodedCredentials,
  debugStatement,
  insecureStorage,
  insecureDependency,
  vulnerableDependency,
  missingSecurity,
  insecureConfiguration,
  performance,
  other,
}

// Example usage
void main() async {
  // Run with verbose output and auto-fix
  await SecurityAudit.performSecurityAudit(
    autoFix: true,
    verbose: true,
    outputFormat: 'markdown',
  );
}

// Configuration file example (security_audit_config.yaml):
/*
# Security Audit Configuration
exclude_directories:
  - test
  - mock
  - generated
  - .dart_tool
  - build

exclude_files:
  - '*.g.dart'
  - '*.freezed.dart'
  - '*.gr.dart'

max_file_size_mb: 10
auto_fix_enabled: true
generate_report: true
report_format: markdown

# Custom patterns
custom_patterns:
  - pattern: 'TODO.*security'
    severity: medium
    message: 'Security-related TODO found'
    recommendation: 'Address security TODO comments'
    
  - pattern: 'FIXME.*vulnerability'
    severity: high
    message: 'Vulnerability fix needed'
    recommendation: 'Fix vulnerability issues immediately'

# Platform-specific checks
android_checks:
  - check_network_security: true
  - check_backup_enabled: true
  - check_debuggable: true

ios_checks:
  - check_ats: true
  - check_privacy_descriptions: true
*/
