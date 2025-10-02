import 'package:flutter/material.dart';

class ProofRequirement extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onUpload;
  final VoidCallback? onClear;
  final bool hasProof;

  const ProofRequirement({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onUpload,
    this.onClear,
    this.hasProof = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onUpload,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasProof ? const Color(0xFF3A86FF) : Colors.grey.shade200,
              width: hasProof ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasProof ? Icons.check_circle : icon,
                color: hasProof ? const Color(0xFF3A86FF) : const Color(0xFF1D3557),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1D3557)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              if (hasProof)
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.red),
                  onPressed: onClear,
                ),
            ],
          ),
        ),
      ),
    );
  }
}