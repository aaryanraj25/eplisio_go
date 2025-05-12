import 'package:eplisio_go/features/clinic/presentation/controller/clinic_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchHospitalDialog extends StatelessWidget {
  const SearchHospitalDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HospitalsController>();

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Search Hospital',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search by hospital name...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: Obx(() => controller.isSearching.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const SizedBox.shrink()),
              ),
              onChanged: controller.searchHospitals,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.searchResults.isEmpty) {
                  return Center(
                    child: Text(
                      controller.searchController.text.isEmpty
                          ? 'Start typing to search hospitals'
                          : 'No hospitals found',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.searchResults.length,
                  itemBuilder: (context, index) {
                    final result = controller.searchResults[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        result.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(result.address),
                          const SizedBox(height: 4),
                          if (result.rating > 0)
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  result.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      trailing: Obx(() {
                        if (controller.isAdding.value) {
                          return const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }
                        return TextButton(
                          onPressed: () => controller.addHospitalFromGoogle(result),
                          child: const Text('Add'),
                        );
                      }),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

