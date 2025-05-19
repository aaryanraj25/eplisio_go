import 'package:eplisio_go/features/clinic/data/model/clinic_model.dart';
import 'package:eplisio_go/features/clinic/presentation/controller/clinic_controller.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ManualClinicDialog extends StatefulWidget {
  const ManualClinicDialog({Key? key}) : super(key: key);

  @override
  State<ManualClinicDialog> createState() => _ManualClinicDialogState();
}

class _ManualClinicDialogState extends State<ManualClinicDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  var _selectedSpecialties = <String>[];
  String _selectedType = 'hospital';

  LatLng? _selectedLocation;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false; // Added state variable for form submission loading

  // Purple theme colors
  final Color _primaryPurple = const Color(0xFF6A1B9A);
  final Color _lightPurple = const Color(0xFF9C27B0);
  final Color _accentPurple = const Color(0xFFE1BEE7);

  final List<String> _clinicTypes = [
    'hospital',
    'clinic',
    'nursing_home',
    'diagnostic',
    'pharmacy',
    'other'
  ];

  final List<String> _availableSpecialties = [
    'MultiSpeciality',
    'General Medicine',
    'Cardiology',
    'Orthopedics',
    'Pediatrics',
    'Gynecology',
    'Dermatology',
    'Neurology',
    'Ophthalmology',
    'ENT (Otolaryngology)',
    'Gastroenterology',
    'Pulmonology',
    'Nephrology',
    'Urology',
    'Endocrinology',
    'Oncology',
    'Hematology',
    'Psychiatry',
    'Dentistry',
    'Rheumatology',
    'Allergy & Immunology',
    'Physical Therapy',
    'Radiology',
    'Pathology',
    'Surgery - General',
    'Surgery - Cardiac',
    'Surgery - Neuro',
    'Surgery - Plastic',
    'Surgery - Vascular',
    'Anesthesiology',
    'Emergency Medicine',
    'Family Medicine',
    'Internal Medicine',
    'Sports Medicine',
    'Geriatrics',
    'Obstetrics',
    'Neonatology',
    'Infectious Disease',
    'Pain Management',
    'Sleep Medicine',
    'Alternative Medicine',
    'Nutrition & Dietetics',
    'Psychology',
    'Speech Therapy',
    'Occupational Therapy'
  ].map((e) => e.trim()).toList();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get location: $e',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }


  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      Get.snackbar(
        'Error',
        'Please detect or select location',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Set loading state
    setState(() => _isSubmitting = true);

    try {

      final clinic = ClinicManualCreate(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim(),
        pincode: _pincodeController.text.trim(),
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        phone: _phoneController.text.trim(),
        website: _websiteController.text.trim(),
        type: _selectedType.trim(),
      );

      // Print the request body for debugging
      print('Request body: ${clinic.toJson()}');

      // Call the controller and await the result
      await Get.find<HospitalsController>().addClinicManually(clinic);
      
      // Show success message
      Get.snackbar(
        'Success',
        'Facility added successfully',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Close the dialog
      Get.back();
      
    } catch (e) {
      // Show error message if submission fails
      Get.snackbar(
        'Error',
        'Failed to create facility: $e',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      // Reset loading state if dialog is still showing
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  InputDecoration _getInputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _primaryPurple),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _primaryPurple),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _primaryPurple, width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _accentPurple),
      ),
      prefixIcon: icon != null ? Icon(icon, color: _primaryPurple) : null,
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add New Facility',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _primaryPurple,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: _primaryPurple),
                      onPressed: _isSubmitting ? null : () => Get.back(),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _nameController,
                  decoration: _getInputDecoration('Facility Name*',
                      icon: Icons.local_hospital),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Name is required' : null,
                  enabled: !_isSubmitting,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: _getInputDecoration('Facility Type*',
                      icon: Icons.category),
                  items: _clinicTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.capitalizeFirst!),
                    );
                  }).toList(),
                  onChanged: _isSubmitting ? null : (value) {
                    setState(() => _selectedType = value!);
                  },
                  dropdownColor: Colors.white,
                  style: TextStyle(color: _primaryPurple, fontSize: 16),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _addressController,
                  decoration:
                      _getInputDecoration('Address*', icon: Icons.location_on),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Address is required' : null,
                  maxLines: 2,
                  enabled: !_isSubmitting,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: _getInputDecoration('City*',
                            icon: Icons.location_city),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'City is required' : null,
                        enabled: !_isSubmitting,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _stateController,
                        decoration:
                            _getInputDecoration('State*', icon: Icons.map),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'State is required' : null,
                        enabled: !_isSubmitting,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _countryController,
                        decoration:
                            _getInputDecoration('Country*', icon: Icons.public),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Country is required'
                            : null,
                        enabled: !_isSubmitting,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _pincodeController,
                        decoration:
                            _getInputDecoration('Pincode', icon: Icons.pin),
                        keyboardType: TextInputType.number,
                        enabled: !_isSubmitting,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        decoration:
                            _getInputDecoration('Phone', icon: Icons.phone),
                        keyboardType: TextInputType.phone,
                        enabled: !_isSubmitting,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _websiteController,
                        decoration:
                            _getInputDecoration('Website', icon: Icons.web),
                        keyboardType: TextInputType.url,
                        enabled: !_isSubmitting,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Location section with improved UI
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _accentPurple),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_searching,
                                color: _primaryPurple),
                            const SizedBox(width: 8),
                            Text(
                              'Facility Location',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _primaryPurple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_selectedLocation != null)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _accentPurple.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.gps_fixed, color: _primaryPurple),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Latitude: ${_selectedLocation!.latitude.toStringAsFixed(6)}\n'
                                    'Longitude: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.amber),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Location detection required',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: (_isLoadingLocation || _isSubmitting) 
                                ? null 
                                : _getCurrentLocation,
                            icon: _isLoadingLocation
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.my_location,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              _isLoadingLocation
                                  ? 'Detecting...'
                                  : 'Detect Current Location',
                              style: const TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting ? null : () => Get.back(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: _isSubmitting ? Colors.grey : _primaryPurple,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: _primaryPurple.withOpacity(0.6),
                        disabledForegroundColor: Colors.white70,
                      ),
                      child: _isSubmitting
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Adding...',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            )
                          : const Text(
                              'Add Facility',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}