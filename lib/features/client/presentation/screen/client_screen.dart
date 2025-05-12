import 'package:eplisio_go/features/client/presentation/controller/client_controller.dart';
import 'package:eplisio_go/features/client/presentation/widgets/add_client_dialog.dart';
import 'package:eplisio_go/features/client/presentation/widgets/client_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () {
          Get.dialog(
            const AddClientDialog(),
            barrierDismissible: false,
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.clients.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Clients Found',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchClients,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.clients.length,
            itemBuilder: (context, index) {
              final client = controller.clients[index];
              return ClientCard(client: client);
            },
          ),
        );
      }),
    );
  }
}

