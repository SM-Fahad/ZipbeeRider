import 'package:ZipBee_Driver/features/google_map/widget/google_map_widget.dart';
import 'package:flutter/material.dart';

class AddressPickerDialog extends StatelessWidget {
  const AddressPickerDialog({
    super.key,
    required this.title,
    this.initialQuery,
  });

  final String title;
  final String? initialQuery;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.82,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: GoogleMapWidget(
                  mode: GoogleMapWidgetMode.addressPicker,
                  initialQuery: initialQuery,
                  onLocationConfirmed: (resolved) {
                    Navigator.of(context).pop(resolved);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
