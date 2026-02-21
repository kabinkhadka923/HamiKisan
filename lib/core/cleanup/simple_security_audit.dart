import 'dart:io';

class SimpleSecurityAudit {
  static final List<String> _sensitivePatterns = [
    'password',
    'token',
    'api_key',
    'secret',
    'private_key',
    'firebase',
  ];

  static final List<String> _debugPatterns = [






  ];

  static final List<String> _insecurePatterns = [
    'SharedPreferences',
    'File.writeAsString',
    'LocalStorage',
  ];

  static Future<void> performSecurityAudit() async {

    
    final issues = <SecurityIssue>[];
    
    // Check for hardcoded credentials
    await _checkHardcodedCredentials(issues);
    
    // Check for debug prints
    await _checkDebugPrints(issues);
    
    // Check for insecure storage
    await _checkInsecureStorage(issues);
    
    // Generate report
    _generateReport(issues);
    
    // Auto-fix simple issues
    await _autoFixIssues(issues);
  }

  static Future<void> _checkHardcodedCredentials(List<SecurityIssue> issues) async {
    final dartFiles = await _getDartFiles();
    
    for (final file in dartFiles) {
      final content = await file.readAsString();
      final lines = content.split('\n');
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].toLowerCase();
        for (final pattern in _sensitivePatterns) {
          if (line.contains(pattern)) {
            issues.add(SecurityIssue(
              file: file.path,
              line: i + 1,
              column: 0,
              severity: Severity.critical,
              type: IssueType.hardcodedCredentials,
              message: 'Potential hardcoded credential found',
              recommendation: 'Move to environment variables or secure storage',
              code: lines[i].trim(),
            ));
            break; // Only add one issue per line
          }
        }
      }
    }
  }

  static Future<void> _checkDebugPrints(List<SecurityIssue> issues) async {
    final dartFiles = await _getDartFiles();
    
    for (final file in dartFiles) {
      final content = await file.readAsString();
      final lines = content.split('\n');
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final pattern in _debugPatterns) {
          if (line.contains(pattern)) {
            issues.add(SecurityIssue(
              file: file.path,
              line: i + 1,
              column: 0,
              severity: Severity.medium,
              type: IssueType.other,
              message: 'Debug statement found',
              recommendation: 'Remove debug statements in production',
              code: line.trim(),
            ));
            break; // Only add one issue per line
          }
        }
      }
    }
  }

  static Future<void> _checkInsecureStorage(List<SecurityIssue> issues) async {
    final dartFiles = await _getDartFiles();
    
    for (final file in dartFiles) {
      final content = await file.readAsString();
      final lines = content.split('\n');
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final pattern in _insecurePatterns) {
          if (line.contains(pattern)) {
            issues.add(SecurityIssue(
              file: file.path,
              line: i + 1,
              column: 0,
              severity: Severity.high,
              type: IssueType.insecureStorage,
              message: 'Insecure storage usage found',
              recommendation: 'Use secure storage for sensitive data',
              code: line.trim(),
            ));
            break; // Only add one issue per line
          }
        }
      }
    }
  }

  static Future<void> _autoFixIssues(List<SecurityIssue> issues) async {
    // Filter debug issues (those with IssueType.other from debug prints)
    final debugIssues = issues.where((issue) => issue.type == IssueType.other).toList();
    
    for (final issue in debugIssues) {
      await _removeDebugPrint(issue);
    }
  }

  static Future<void> _removeDebugPrint(SecurityIssue issue) async {
    try {
      final file = File(issue.file);
      final content = await file.readAsString();
      final lines = content.split('\n');
      
      // Remove the debug print line
      if (issue.line <= lines.length) {
        lines[issue.line - 1] = ''; // Clear the line
      }
      
      await file.writeAsString(lines.join('\n'));

    } catch (e) {

    }
  }

  static void _generateReport(List<SecurityIssue> issues) {


    
    if (issues.isEmpty) {

      return;
    }
    
    // Group by severity
    final criticalIssues = issues.where((issue) => issue.severity == Severity.critical).toList();
    final highIssues = issues.where((issue) => issue.severity == Severity.high).toList();
    final mediumIssues = issues.where((issue) => issue.severity == Severity.medium).toList();
    final lowIssues = issues.where((issue) => issue.severity == Severity.low).toList();
    

    for (final issue in criticalIssues) {
      _printIssue(issue);
    }
    

    for (final issue in highIssues) {
      _printIssue(issue);
    }
    

    for (final issue in mediumIssues) {
      _printIssue(issue);
    }
    

    for (final issue in lowIssues) {
      _printIssue(issue);
    }
    






    
    if (criticalIssues.isNotEmpty || highIssues.isNotEmpty) {


    }
  }

  static void _printIssue(SecurityIssue issue) {





  }

  static Future<List<File>> _getDartFiles() async {
    final directory = Directory('lib');
    final files = <File>[];
    
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        files.add(entity);
      }
    }
    
    return files;
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
}

enum Severity {
  critical,
  high,
  medium,
  low,
}

enum IssueType {
  hardcodedCredentials,

  insecureStorage,
  other,
}