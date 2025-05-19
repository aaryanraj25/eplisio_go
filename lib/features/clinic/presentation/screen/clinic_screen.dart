import 'package:eplisio_go/features/clinic/presentation/controller/clinic_controller.dart';
import 'package:eplisio_go/features/clinic/presentation/widgets/hospital_card.dart';
import 'package:eplisio_go/features/clinic/presentation/widgets/manual_clinic.dart';
import 'package:eplisio_go/features/clinic/presentation/widgets/search_hospital_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HospitalsScreen extends GetView<HospitalsController> {
  const HospitalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospitals',
            style:
                TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: controller.fetchHospitals,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () {
          Get.bottomSheet(
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add New Facility',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.add_location),
                    title: const Text('Search Google Places'),
                    subtitle: const Text('Add facility from Google Places'),
                    onTap: () {
                      Get.back();
                      Get.dialog(
                        const SearchHospitalDialog(),
                        barrierDismissible: false,
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_business),
                    title: const Text('Add Manually'),
                    subtitle: const Text('Create new facility manually'),
                    onTap: () {
                      Get.back();
                      Get.dialog(
                        const ManualClinicDialog(),
                        barrierDismissible: false,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Hospitals',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.error.value,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.fetchHospitals,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (controller.hospitals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_hospital_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Hospitals Found',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.dialog(
                      const SearchHospitalDialog(),
                      barrierDismissible: false,
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Hospital'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchHospitals,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.hospitals.length,
            itemBuilder: (context, index) {
              return HospitalCard(
                hospital: controller.hospitals[index],
              );
            },
          ),
        );
      }),
    );
  }
}
