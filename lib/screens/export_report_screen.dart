import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/report_service.dart';
import 'package:share_plus/share_plus.dart';

class ExportReportScreen extends StatefulWidget {
  const ExportReportScreen({super.key});

  @override
  State<ExportReportScreen> createState() => _ExportReportScreenState();
}

class _ExportReportScreenState extends State<ExportReportScreen> {
  final ReportService _reportService = ReportService();
  DateTime _semesterStart = DateTime.now().subtract(const Duration(days: 180)); // 6 months ago
  DateTime _semesterEnd = DateTime.now();
  bool _isGenerating = false;
  String? _generatedFilePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Semester Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Semester Period',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDatePicker(
              'Semester Start',
              _semesterStart,
              (date) => setState(() => _semesterStart = date),
            ),
            const SizedBox(height: 16),
            _buildDatePicker(
              'Semester End',
              _semesterEnd,
              (date) => setState(() => _semesterEnd = date),
            ),
            const SizedBox(height: 32),
            if (_generatedFilePath != null) ...[
              _buildGeneratedReportSection(),
              const SizedBox(height: 32),
            ],
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime selectedDate, Function(DateTime) onDateSelected) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) {
                  onDateSelected(picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedReportSection() {
    return Card(
      elevation: 4,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Report Generated Successfully!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'File saved at: $_generatedFilePath',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareReport,
                    icon: const Icon(Icons.share),
                    label: const Text('Share Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _generateNewReport,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Generate New'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _isGenerating ? null : _generateReport,
          icon: _isGenerating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.picture_as_pdf),
          label: Text(_isGenerating ? 'Generating Report...' : 'Generate PDF Report'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'The report will include:\n'
          '• Student progress and statistics\n'
          '• Grade trends and performance\n'
          '• Attendance records\n'
          '• Quiz results and achievements\n'
          '• Study hours by subject\n'
          '• Gamification progress',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Future<void> _generateReport() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final studentId = authProvider.user?.id;

    if (studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    if (_semesterStart.isAfter(_semesterEnd)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start date must be before end date')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final filePath = await _reportService.generateSemesterReport(
        studentId,
        _semesterStart,
        _semesterEnd,
      );

      setState(() {
        _generatedFilePath = filePath;
        _isGenerating = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isGenerating = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating report: $e')),
      );
    }
  }

  Future<void> _shareReport() async {
    if (_generatedFilePath == null) return;

    try {
      final file = XFile(_generatedFilePath!);
      await Share.shareXFiles([file], text: 'Semester Report PDF');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing report: $e')),
      );
    }
  }

  void _generateNewReport() {
    setState(() => _generatedFilePath = null);
  }
}