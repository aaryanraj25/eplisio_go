import 'dart:async';
import 'package:eplisio_go/core/utils/location_services.dart';
import 'package:eplisio_go/features/meetings/presentation/controller/meeting_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckInDialog extends StatefulWidget {
  const CheckInDialog({Key? key}) : super(key: key);

  @override
  State<CheckInDialog> createState() => _CheckInDialogState();
}

class _CheckInDialogState extends State<CheckInDialog> {
  final MeetingsController _controller = Get.find();
  final TextEditingController _notesController = TextEditingController();
  final RxString _selectedClinicId = ''.obs;
  final RxString _selectedClientId = ''.obs;

  @override
  void initState() {
    super.initState();
    _fetchNearbyClinics();
  }

  Future<void> _fetchNearbyClinics() async {
    try {
      final hasPermission = await LocationService.checkLocationPermission();
      if (!hasPermission) {
        Get.dialog(
          AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'Location permission is required to check in at clinics. '
              'Please enable location permission in settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Get.back();
                  await openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        return;
      }

      await LocationService.initialize();
      await _controller.fetchNearbyClinics();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch nearby clinics',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  Future<void> _fetchClients(String clinicId) async {
    try {
      await _controller.fetchClients(
        clinicId: clinicId,
        skip: 0,
        limit: 50, // Increased limit since we're showing all clients
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch clients',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  Future<void> _handleCheckIn() async {
    if (_selectedClinicId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a clinic',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    if (_selectedClientId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a client',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      await _controller.checkIn(
        clinicId: _selectedClinicId.value,
        clientId: _selectedClientId.value,
        notes: _notesController.text,
      );
      Get.back(result: true);

      Get.snackbar(
        'Success',
        'Check-in completed successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to check in',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  void _navigateToAddHospital() {
    Get.toNamed('/clinic');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Check In',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: [
                    // Clinics Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Clinic',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _navigateToAddHospital,
                          icon: const Icon(Icons.add, color: Colors.purple),
                          label: const Text('Add Hospital',
                              style: TextStyle(color: Colors.purple)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _controller.nearbyClinics.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'No clinics found nearby',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _fetchNearbyClinics,
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Retry'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      ElevatedButton.icon(
                                        onPressed: _navigateToAddHospital,
                                        icon: const Icon(Icons.add),
                                        label: const Text('Add Hospital'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _controller.nearbyClinics.length,
                              itemBuilder: (context, index) {
                                final clinic = _controller.nearbyClinics[index];
                                return RadioListTile<String>(
                                  title: Text(clinic.name),
                                  subtitle: Text(clinic.address),
                                  value: clinic.id,
                                  groupValue: _selectedClinicId.value,
                                  onChanged: (value) {
                                    _selectedClinicId.value = value ?? '';
                                    _selectedClientId.value =
                                        ''; // Reset client selection
                                    if (value?.isNotEmpty ?? false) {
                                      _fetchClients(value!);
                                    }
                                  },
                                  activeColor: Colors.purple,
                                );
                              },
                            ),
                    ),

                    // Clients Section
                    if (_selectedClinicId.value.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Contact',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              // Navigate to add client screen
                              Get.toNamed('/client', arguments: {
                                'clinic_id': _selectedClinicId.value,
                                'clinic_name': _controller.nearbyClinics
                                    .firstWhere(
                                        (c) => c.id == _selectedClinicId.value)
                                    .name,
                              });
                            },
                            icon: const Icon(Icons.add, color: Colors.purple),
                            label: const Text('Add Contact',
                                style: TextStyle(color: Colors.purple)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _controller.clients.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'No clients found for this clinic',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Get.toNamed('/client', arguments: {
                                          'clinic_id': _selectedClinicId.value,
                                          'clinic_name': _controller
                                              .nearbyClinics
                                              .firstWhere((c) =>
                                                  c.id ==
                                                  _selectedClinicId.value)
                                              .name,
                                        });
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add New Client'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _controller.clients.length,
                                itemBuilder: (context, index) {
                                  final client = _controller.clients[index];
                                  return Obx(() => RadioListTile<String>(
                                        title: Text(client.name),
                                        subtitle: Text(
                                            '${client.designation} • ${client.department}'),
                                        value: client.id,
                                        groupValue: _selectedClientId.value,
                                        onChanged: (value) {
                                          _selectedClientId.value = value ?? '';
                                        },
                                        activeColor: Colors.purple,
                                        selected: _selectedClientId.value ==
                                            client.id,
                                        selectedTileColor:
                                            _selectedClientId.value == client.id
                                                ? Colors.purple.withOpacity(0.1)
                                                : null,
                                      ));
                                },
                              ),
                      ),
                    ],

                    // Notes Section
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'Add notes (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.purple),
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                    onPressed:
                        _controller.isLoading.value ? null : _handleCheckIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Check In'),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
