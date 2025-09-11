import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../theme.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;
  final bool isSelected;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8.0 : 2.0,
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(AppTheme.borderRadiusMd),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppTheme.spacingMd),
        title: Text(
          service.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppTheme.spacingSm),
          child: Text(service.description),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Icon(Icons.timer_outlined, size: 20),
            const SizedBox(height: AppTheme.spacingXs),
            Text('${service.defaultDuration} min'),
          ],
        ),
        onTap: onTap,
        selected: isSelected,
        selectedTileColor:
            Theme.of(context).primaryColor.withOpacity(0.08),
      ),
    );
  }
}