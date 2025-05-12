// lib/features/clients/presentation/widgets/add_client_dialog.dart
import 'package:eplisio_go/features/client/presentation/controller/client_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddClientDialog extends StatefulWidget {
  const AddClientDialog({Key? key}) : super(key: key);

  @override
  State<AddClientDialog> createState() => _AddClientDialogState();
}

class _AddClientDialogState extends State<AddClientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<ClientsController>();

  String? selectedClinicId;
  String selectedCapacity = 'end_user';

  final nameController = TextEditingController();
  final designationController = TextEditingController();
  final departmentController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();

  final capacityOptions = [
    {'value': 'end_user', 'label': 'End User'},
    {'value': 'intent_provider', 'label': 'Intent Provider'},
    {'value': 'decision_maker', 'label': 'Decision Maker'},
    {'value': 'influencer', 'label': 'Influencer'},
    {'value': 'purchase', 'label': 'Purchase'},
    {'value': 'store_name', 'label': 'Store Name'},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment
                    .stretch, // Ensure all children stretch horizontally
                children: [
                  Text(
                    'Add New Client',
                    style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: designationController,
                    decoration: const InputDecoration(
                      labelText: 'Designation',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter designation';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter department';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Obx(() => DropdownButtonFormField<String>(
                        isExpanded: true, // Make the dropdown take full width
                        value: selectedClinicId,
                        decoration: const InputDecoration(
                          labelText: 'Clinic',
                          border: OutlineInputBorder(),
                        ),
                        items: _controller.clinics.map((clinic) {
                          return DropdownMenuItem(
                            value: clinic.id,
                            child: Text(
                              clinic.name,
                              overflow:
                                  TextOverflow.ellipsis, // Handle text overflow
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedClinicId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select clinic';
                          }
                          return null;
                        },
                      )),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: mobileController,
                    decoration: const InputDecoration(
                      labelText: 'Mobile',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    isExpanded: true, // Make the dropdown take full width
                    value: selectedCapacity,
                    decoration: const InputDecoration(
                      labelText: 'Capacity',
                      border: OutlineInputBorder(),
                    ),
                    items: capacityOptions.map((option) {
                      return DropdownMenuItem(
                        value: option['value'],
                        child: Text(
                          option['label']!,
                          overflow:
                              TextOverflow.ellipsis, // Handle text overflow
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCapacity = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.purple)),
                      ),
                      const SizedBox(width: 16),
                      Obx(() => ElevatedButton(
                            onPressed: _controller.isCreating.value
                                ? null
                                : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.purple, // Purple background
                              foregroundColor:
                                  Colors.white, // Optional: white text
                            ),
                            child: _controller.isCreating.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text('Create'),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Create base client data map
      final clientData = {
        'name': nameController.text,
        'designation': designationController.text,
        'department': departmentController.text,
        'clinic_id': selectedClinicId,
        'capacity': selectedCapacity,
      };

      // Only add mobile if it's not empty
      if (mobileController.text.isNotEmpty) {
        clientData['mobile'] = mobileController.text;
      }

      // Only add email if it's not empty
      if (emailController.text.isNotEmpty) {
        clientData['email'] = emailController.text;
      }

      // Call the controller to create the client
      _controller.createClient(clientData);
    }
  }
}
