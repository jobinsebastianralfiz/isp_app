import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import '../../models/pacakge_models.dart';
import '../../utils/ui_helpers.dart';

class PackageCard extends StatelessWidget {
  final Package package;
  final bool isSelected;
  final VoidCallback onSelect;

  const PackageCard({
    Key? key,
    required this.package,
    this.isSelected = false,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPopular = package.isPopular ?? false;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: AppConstants.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular badge
          if (isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: const Text(
                'POPULAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Package content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Provider logo if available
                if (package.provider != null && package.provider!['logo'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Image.network(
                      package.provider!['logo'],
                      height: 40,
                      errorBuilder: (context, error, stackTrace) =>
                          Text(package.provider!['name'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),

                // Package name
                Text(
                  package.name,
                  style: AppConstants.subheadingStyle,
                ),

                const SizedBox(height: 8),

                // Speed
                Text(
                  package.speedDisplay,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 8),

                // Price
                Text(
                  package.formattedPrice ?? 'Rs. ${package.price.toStringAsFixed(0)}/month',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 16),

                // Features heading
                const Text(
                  'Features:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Features list
                ...package.features.take(4).map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),

                // More features indicator
                if (package.features.length > 4)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+ ${package.features.length - 4} more features',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Select button
                UIHelpers.primaryButton(
                  text: isSelected ? 'Selected' : 'Select Plan',
                  onPressed: onSelect,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}