import 'package:flutter/material.dart';
import '../models/service_model.dart';

class ServiceSelector extends StatelessWidget {
  final List<ServiceModel> services;
  final ServiceModel? selectedService;
  final Function(ServiceModel) onServiceSelected;

  const ServiceSelector({
    super.key,
    required this.services,
    required this.selectedService,
    required this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sélectionnez un service',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              final isSelected = selectedService?.id == service.id;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(service.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onServiceSelected(service);
                    }
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected 
                        ? Colors.white 
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}