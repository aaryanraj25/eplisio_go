import 'dart:math';
import 'package:eplisio_go/core/utils/number_format.dart';
import 'package:eplisio_go/features/clinic/data/model/clinic_model.dart';
import 'package:eplisio_go/features/orders/data/model/orders_model.dart';
import 'package:eplisio_go/features/product/data/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/orders_controller.dart';

class OrdersScreen extends GetView<OrdersController> {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Orders',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.purple,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabAlignment: TabAlignment.start,
            padding: EdgeInsets.zero,
            indicatorPadding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: const [
              Tab(text: 'All Orders'),
              Tab(text: 'Pending'),
              Tab(text: 'Completed'),
              Tab(text: 'Prospective'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrdersList(null),
            _buildOrdersList(OrderStatus.pending),
            _buildOrdersList(OrderStatus.completed),
            _buildOrdersList(OrderStatus.prospective),
            _buildOrdersList(OrderStatus.rejected),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddOrderDialog(context),
          backgroundColor: Colors.purple,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'New Order',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(OrderStatus? status) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
        );
      }

      if (controller.error.value != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Error: ${controller.error.value}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: controller.fetchOrders,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      final filteredOrders = status == null
          ? controller.orders
          : controller.orders.where((order) => order.status == status).toList();

      if (filteredOrders.isEmpty) {
        return _buildEmptyState(status);
      }

      return RefreshIndicator(
        onRefresh: controller.fetchOrders,
        color: Colors.purple,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            return OrderCard(
              order: order,
              onTap: () => Get.toNamed('/orders/details', arguments: order),
              onConvertToOrder: order.status == OrderStatus.prospective
                  ? () => _showConvertDialog(order)
                  : null,
            );
          },
        ),
      );
    });
  }

  Widget _buildEmptyState(OrderStatus? status) {
    String message;
    IconData icon;
    String buttonText;

    switch (status) {
      case OrderStatus.pending:
        message = 'No pending orders yet';
        icon = Icons.pending_actions;
        buttonText = 'Create New Order';
        break;
      case OrderStatus.completed:
        message = 'No completed orders';
        icon = Icons.check_circle_outline;
        buttonText = 'View All Orders';
        break;
      case OrderStatus.prospective:
        message = 'No prospective orders';
        icon = Icons.trending_up;
        buttonText = 'Add Prospective Order';
        break;
      case OrderStatus.rejected:
        message = 'No rejected orders';
        icon = Icons.cancel_outlined;
        buttonText = 'View All Orders';
        break;
      default:
        message = 'No orders found';
        icon = Icons.shopping_bag_outlined;
        buttonText = 'Create First Order';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create a new order',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddOrderDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white,),
            label: Text(buttonText),
          ),
        ],
      ),
    );
  }

  void _showConvertDialog(OrderModel order) {
    final totalAmountController = TextEditingController(
      text: order.totalAmount.toStringAsFixed(2),
    );
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: const [
            Text('Convert to Regular Order'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined,
                        color: Colors.purple),
                    const SizedBox(width: 8),
                    Text(
                      'Order #${order.orderId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Items List
              const Text(
                'Order Items',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Column(
                    children: order.items
                        .map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity}x',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '₹${NumberFormatter.formatAmount(item.price)}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '₹${NumberFormatter.formatAmount(item.totalAmount)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),

              const Divider(height: 32),

              // Subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '₹${NumberFormatter.formatAmount(
                      order.items.fold<double>(
                        0,
                        (sum, item) => sum + item.totalAmount,
                      ),
                    )}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Final Amount Input
              TextFormField(
                controller: totalAmountController,
                decoration: InputDecoration(
                  labelText: 'Final Amount (₹)',
                  border: const OutlineInputBorder(),
                  helperText: 'Adjust final amount if needed',
                  prefixIcon: const Icon(Icons.currency_rupee),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.restore),
                    onPressed: () {
                      totalAmountController.text =
                          order.totalAmount.toStringAsFixed(2);
                    },
                    tooltip: 'Reset to original amount',
                  ),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.purple)),
          ),
          Obx(() => ElevatedButton.icon(
                onPressed: controller.isActionLoading.value
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;

                        final totalAmount = double.parse(
                          totalAmountController.text,
                        );
                        await controller.convertToRegularOrder(
                          order,
                          totalAmount,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.purple.withOpacity(0.6),
                ),
                icon: controller.isActionLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                label: const Text('Convert'),
              )),
        ],
      ),
    );
  }

  void _showAddOrderDialog(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final formKey = GlobalKey<FormState>();
    final notesController = TextEditingController();
    final totalAmountController = TextEditingController();
    final quantityController = TextEditingController();

    // Reactive variables
    final selectedClinic = Rx<ClinicModel?>(null);
    final selectedProduct = Rx<ProductModel?>(null);
    final isPending = true.obs;
    final selectedItems = <OrderItemModel>[].obs;

    // Calculate subtotal
    double calculateSubtotal() =>
        selectedItems.fold(0, (sum, item) => sum + item.totalAmount);

    // Function to add new item
    void addItem() {
      if (selectedProduct.value == null) return;

      final quantity = int.tryParse(quantityController.text) ?? 0;
      final product = selectedProduct.value!;

      if (quantity <= 0) {
        Get.snackbar('Invalid Quantity', 'Please enter a valid quantity',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            icon: const Icon(Icons.error_outline, color: Colors.red));
        return;
      }

      if (quantity > product.quantity) {
        Get.snackbar(
            'Insufficient Stock', 'Only ${product.quantity} items available',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            icon: const Icon(Icons.inventory_2, color: Colors.red));
        return;
      }

      selectedItems.add(OrderItemModel(
        productId: product.id,
        name: product.name,
        quantity: quantity,
        price: product.price,
        totalAmount: quantity * product.price,
      ));

      // Update total amount and clear selection
      totalAmountController.text = calculateSubtotal().toStringAsFixed(2);
      selectedProduct.value = null;
      quantityController.clear();
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Obx(() {
          if (controller.isClinicsLoading.value ||
              controller.isProductsLoading.value) {
            return const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
              ),
            );
          }

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
              maxWidth: min(MediaQuery.of(context).size.width * 0.9, 600),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  _buildDialogHeader(context),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order Type
                          _buildOrderTypeSelector(isPending),
                          const SizedBox(height: 16),

                          // Clinic Selection
                          _buildClinicDropdown(
                              context, controller.clinics, selectedClinic),
                          const SizedBox(height: 24),

                          // Items Section Header
                          Text(
                            'Order Items',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),

                          // Selected Items List
                          if (selectedItems.isNotEmpty)
                            _buildSelectedItemsList(context, selectedItems,
                                totalAmountController, calculateSubtotal),

                          // Add New Item Card
                          _buildAddItemCard(
                            context,
                            controller.products,
                            selectedProduct,
                            quantityController,
                            addItem,
                          ),
                          const SizedBox(height: 24),

                          // Total Amount & Notes
                          _buildTotalAndNotes(
                            context,
                            totalAmountController,
                            notesController,
                            calculateSubtotal,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Action Buttons
                  _buildActionButtons(
                    context,
                    controller,
                    formKey,
                    selectedItems,
                    selectedClinic,
                    notesController,
                    totalAmountController,
                    isPending,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDialogHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.add_shopping_cart, color: Colors.white),
          const SizedBox(width: 8),
          const Text(
            'Create New Order',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeSelector(RxBool isPending) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Pending'),
                value: true,
                groupValue: isPending.value,
                onChanged: (value) => isPending.value = value!,
                activeColor: Colors.purple,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Prospective'),
                value: false,
                groupValue: isPending.value,
                onChanged: (value) => isPending.value = value!,
                activeColor: Colors.purple,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                dense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicDropdown(BuildContext context, List<ClinicModel> clinics,
      Rx<ClinicModel?> selectedClinic) {
    return DropdownButtonFormField<ClinicModel>(
      value: selectedClinic.value,
      decoration: InputDecoration(
        labelText: 'Select Clinic',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.local_hospital, size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        isDense: true,
      ),
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down, size: 20),
      items: clinics.map((clinic) {
        return DropdownMenuItem(
          value: clinic,
          child: Text(
            clinic.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (value) => selectedClinic.value = value,
      validator: (value) => value == null ? 'Please select a clinic' : null,
      menuMaxHeight: 300,
    );
  }

  Widget _buildSelectedItemsList(
      BuildContext context,
      RxList<OrderItemModel> selectedItems,
      TextEditingController totalAmountController,
      Function calculateSubtotal) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: selectedItems.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = selectedItems[index];
          return ListTile(
            dense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            leading: CircleAvatar(
              backgroundColor: Colors.purple[100],
              radius: 16,
              child: Text(
                '${item.quantity}',
                style: const TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '₹${NumberFormatter.formatAmount(item.price)} × ${item.quantity} = ₹${NumberFormatter.formatAmount(item.totalAmount)}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.red,
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              onPressed: () {
                selectedItems.removeAt(index);
                totalAmountController.text =
                    calculateSubtotal().toStringAsFixed(2);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddItemCard(
    BuildContext context,
    List<ProductModel> products,
    Rx<ProductModel?> selectedProduct,
    TextEditingController quantityController,
    Function addItem,
  ) {
    return Card(
      elevation: 0,
      color: Colors.purple[50],
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Item',
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ProductModel>(
              value: selectedProduct.value,
              decoration: const InputDecoration(
                labelText: 'Select Product',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                isDense: true,
              ),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              items: products.map((product) {
                return DropdownMenuItem(
                  value: product,
                  child: Text(
                    '${product.name} - ₹${NumberFormatter.formatAmount(product.price)} (${product.quantity})',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (value) => selectedProduct.value = value,
              menuMaxHeight: 300,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => addItem(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.add, size: 20, color: Colors.white),
                  label:
                      const Text('Add', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAndNotes(
    BuildContext context,
    TextEditingController totalAmountController,
    TextEditingController notesController,
    Function calculateSubtotal,
  ) {
    return Column(
      children: [
        TextFormField(
          controller: totalAmountController,
          decoration: InputDecoration(
            labelText: 'Total Amount (₹)',
            border: const OutlineInputBorder(),
            helperText: 'Adjust amount for discounts if needed',
            helperStyle: const TextStyle(fontSize: 12),
            prefixIcon: const Icon(Icons.currency_rupee),
            suffixIcon: IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: () {
                totalAmountController.text =
                    calculateSubtotal().toStringAsFixed(2);
              },
              tooltip: 'Reset to calculated total',
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter total amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'Notes (Optional)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.note),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    OrdersController controller,
    GlobalKey<FormState> formKey,
    RxList<OrderItemModel> selectedItems,
    Rx<ClinicModel?> selectedClinic,
    TextEditingController notesController,
    TextEditingController totalAmountController,
    RxBool isPending,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Cancel', style: TextStyle(color: Colors.purple)),
          ),
          const SizedBox(width: 8),
          Obx(() => ElevatedButton.icon(
                onPressed: controller.isActionLoading.value
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        if (selectedItems.isEmpty) {
                          Get.snackbar(
                            'Missing Items',
                            'Please add at least one item',
                            backgroundColor: Colors.red.withOpacity(0.1),
                            colorText: Colors.red,
                            icon: const Icon(Icons.error_outline,
                                color: Colors.red),
                          );
                          return;
                        }

                        try {
                          final orderData = {
                            'clinic_id': selectedClinic.value!.id,
                            'items': selectedItems
                                .map((item) => {
                                      'product_id': item.productId,
                                      'name': item.name,
                                      'quantity': item.quantity,
                                      'price': item.price,
                                      'total': item.totalAmount,
                                    })
                                .toList(),
                            'notes': notesController.text,
                            'total_amount':
                                double.parse(totalAmountController.text),
                            'status':
                                isPending.value ? 'pending' : 'prospective',
                          };

                          await controller.createOrder(orderData);
                          Get.back();
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Failed to create order: $e',
                            backgroundColor: Colors.red.withOpacity(0.1),
                            colorText: Colors.red,
                            icon: const Icon(Icons.error_outline,
                                color: Colors.red),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                icon: controller.isActionLoading.value
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check, size: 18, color: Colors.white),
                label: const Text('Create Order',
                    style: TextStyle(color: Colors.white)),
              )),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final VoidCallback? onConvertToOrder;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onTap,
    this.onConvertToOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            _buildHeader(),
            _buildBody(),
            if (order.status == OrderStatus.prospective)
              _buildProspectiveActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 16,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Order #${order.orderId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusChip(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.orderId,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          _buildOrderItems(),
          const SizedBox(height: 16),
          _buildTotalAmount(),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${order.items.length} Items',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            Text(
              '${order.items.fold<int>(0, (sum, item) => sum + item.quantity)} Units',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...order.items.take(3).map((item) => _buildOrderItem(item)),
        if (order.items.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '+ ${order.items.length - 3} more items',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOrderItem(OrderItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              item.name,
              style: const TextStyle(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${item.quantity}x',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '₹${NumberFormatter.formatAmount(item.totalAmount)}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAmount() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Amount',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          Text(
            '₹${NumberFormatter.formatAmount(order.totalAmount)}',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    final statusConfig = _getStatusConfig(order.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusConfig.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusConfig.color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusConfig.icon,
            size: 16,
            color: statusConfig.color,
          ),
          const SizedBox(width: 4),
          Text(
            statusConfig.label,
            style: TextStyle(
              color: statusConfig.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProspectiveActions() {
    final controller = Get.find<OrdersController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Obx(() => ElevatedButton.icon(
            onPressed:
                controller.isActionLoading.value ? null : onConvertToOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: controller.isActionLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.sync, color: Colors.white),
            label: const Text('Convert to Order'),
          )),
    );
  }

  StatusConfig _getStatusConfig(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const StatusConfig(
          color: Colors.orange,
          label: 'Pending',
          icon: Icons.pending,
        );
      case OrderStatus.completed:
        return const StatusConfig(
          color: Colors.green,
          label: 'Completed',
          icon: Icons.check_circle,
        );
      case OrderStatus.prospective:
        return const StatusConfig(
          color: Colors.blue,
          label: 'Prospective',
          icon: Icons.trending_up,
        );
      case OrderStatus.rejected:
        return const StatusConfig(
          color: Colors.red,
          label: 'Rejected',
          icon: Icons.cancel,
        );
    }
  }
}

class StatusConfig {
  final Color color;
  final String label;
  final IconData icon;

  const StatusConfig({
    required this.color,
    required this.label,
    required this.icon,
  });

  static StatusConfig fromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const StatusConfig(
          color: Colors.orange,
          label: 'Pending',
          icon: Icons.pending_actions,
        );
      case 'completed':
        return const StatusConfig(
          color: Colors.green,
          label: 'Completed',
          icon: Icons.check_circle,
        );
      case 'prospective':
        return const StatusConfig(
          color: Colors.blue,
          label: 'Prospective',
          icon: Icons.trending_up,
        );
      case 'rejected':
        return const StatusConfig(
          color: Colors.red,
          label: 'Rejected',
          icon: Icons.cancel_outlined,
        );
      default:
        return const StatusConfig(
          color: Colors.grey,
          label: 'Unknown',
          icon: Icons.help_outline,
        );
    }
  }

  Widget buildChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
