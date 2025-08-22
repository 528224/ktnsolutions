import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ktnsolutions/models/case_model.dart';

class CaseInfoTab extends StatelessWidget {
  final LegalCase legalCase;
  
  const CaseInfoTab({super.key, required this.legalCase});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Case Summary Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Case Number', legalCase.caseNumber),
                const Divider(),
                _buildInfoRow('Title', legalCase.title),
                const Divider(),
                _buildInfoRow('Court', legalCase.courtName),
                if (legalCase.nextHearingDate != null) ...[
                  const Divider(),
                  _buildInfoRow('Next Hearing', _formatDate(legalCase.nextHearingDate!)),
                ],
                const Divider(),
                _buildStatusInfo(),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Client Details Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Client Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Name', legalCase.clientName),
                _buildInfoRow('Contact', legalCase.clientContact),
                if (legalCase.advocateName.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Advocate',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Name', legalCase.advocateName),
                  if (legalCase.advocateContact?.isNotEmpty ?? false)
                    _buildInfoRow('Contact', legalCase.advocateContact!),
                ],
              ],
            ),
          ),
        ),
        
        // Notes Section
        if (legalCase.notes?.isNotEmpty ?? false) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(legalCase.notes!),
                ],
              ),
            ),
          ),
        ],
        
        // Dates Section
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dates',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                if(legalCase.createdAt != null)
                _buildDateRow('Created', legalCase.createdAt!),
                const Divider(),
                _buildDateRow('Last Updated', legalCase.updatedAt ?? legalCase.createdAt!),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 32), // Extra padding at bottom
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDateRow(String label, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${_formatDate(date)} • ${_formatTime(date)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusInfo() {
    final statusColor = _getStatusColor(legalCase.status);
    return Row(
      children: [
        const Text('Status', style: TextStyle(color: Colors.grey)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Text(
            legalCase.status.toString().split('.').last,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
  
  String _formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }
  
  Color _getStatusColor(CaseStatus status) {
    switch (status) {
      case CaseStatus.pending:
        return Colors.orange;
      case CaseStatus.inProgress:
        return Colors.blue;
      case CaseStatus.completed:
        return Colors.green;
      case CaseStatus.adjourned:
        return Colors.purple;
      case CaseStatus.dismissed:
        return Colors.red;
    }
  }
}
