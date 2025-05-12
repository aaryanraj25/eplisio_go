import 'package:eplisio_go/features/meetings/data/model/meeting_model.dart';
import 'package:eplisio_go/features/meetings/presentation/controller/meeting_controller.dart';
import 'package:eplisio_go/features/product/data/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckoutDialog extends StatefulWidget {
  final String meetingId;

  const CheckoutDialog({
    Key? key,
    required this.meetingId,
  }) : super(key: key);

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  final controller = Get.find<MeetingsController>();
  final meetingTypes = [
    'first_meeting',
    'follow_up',
    'demo',
    'negotiation',
    'training'
  ];

  // Color scheme
  final primaryPurple = const Color(0xFF7B68EE);
  final lightPurple = const Color(0xFFEDE7FF);
  final darkPurple = const Color(0xFF5D4FB7);

  String selectedMeetingType = 'first_meeting';
  final notesController = TextEditingController();
  final selectedProducts = <SelectedProduct>[].obs;
  ProductModel? selectedProduct;

  final priceController = TextEditingController();
  final quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.fetchProducts();
  }

  @override
  void dispose() {
    notesController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  void _addProduct() {
    if (selectedProduct == null) return;
    if (priceController.text.isEmpty || quantityController.text.isEmpty) return;

    final price = double.tryParse(priceController.text) ?? 0;
    final quantity = int.tryParse(quantityController.text) ?? 0;

    if (price <= 0 || quantity <= 0) {
      Get.snackbar(
        'Error',
        'Price and quantity must be greater than 0',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    if (quantity > selectedProduct!.quantity) {
      Get.snackbar(
        'Error',
        'Quantity cannot exceed available stock (${selectedProduct!.quantity})',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    selectedProducts.add(SelectedProduct(
      productId: selectedProduct!.id,
      name: selectedProduct!.name,
      price: price,
      quantity: quantity,
    ));

    // Reset form
    selectedProduct = null;
    priceController.clear();
    quantityController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Checkout',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: darkPurple,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close, color: darkPurple),
                      style: IconButton.styleFrom(
                        backgroundColor: lightPurple,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Meeting Type Dropdown
                Text(
                  'Meeting Type',
                  style: textTheme.titleSmall?.copyWith(color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedMeetingType,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.purple),
                    items: meetingTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedMeetingType = value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 28),

                // Products Section
                Text(
                  'Add Products',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 16),

                // Product Selection Form
                Obx(() {
                  if (controller.isProductsLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(color: primaryPurple),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Dropdown
                      Text(
                        'Select Product',
                        style: textTheme.titleSmall
                            ?.copyWith(color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonFormField<ProductModel>(
                          value: selectedProduct,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          icon:
                              Icon(Icons.arrow_drop_down, color: Colors.purple),
                          items: controller.products.map((product) {
                            return DropdownMenuItem(
                              value: product,
                              child: Text(
                                '${product.name} (${product.quantity} available)',
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (product) {
                            setState(() {
                              selectedProduct = product;
                              if (product != null) {
                                priceController.text = product.price.toString();
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Price and Quantity Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price',
                                  style: textTheme.titleSmall
                                      ?.copyWith(color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: TextField(
                                    controller: priceController,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14),
                                      border: InputBorder.none,
                                      prefixText: '₹ ',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quantity',
                                  style: textTheme.titleSmall
                                      ?.copyWith(color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: TextField(
                                    controller: quantityController,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14),
                                      border: InputBorder.none,
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Add Product Button
                      ElevatedButton.icon(
                        onPressed: _addProduct,
                        icon: const Icon(Icons.add, size: 18, color: Colors.white),
                        label: const Text('Add Product'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 28),

                // Selected Products List
                Obx(() {
                  if (selectedProducts.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_cart_outlined,
                              size: 32, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'No products added yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Products',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.purple.withOpacity(0.1),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: selectedProducts.length,
                          padding: const EdgeInsets.all(0),
                          separatorBuilder: (_, __) => Divider(
                            color: Colors.grey.shade300,
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final product = selectedProducts[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₹${product.price} × ${product.quantity}',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${product.total}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 20),
                                    onPressed: () =>
                                        selectedProducts.removeAt(index),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.red.shade50,
                                      foregroundColor: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.purple.withOpacity(0.1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '₹${selectedProducts.fold(0.0, (sum, product) => sum + product.total)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 28),

                // Notes
                Text(
                  'Notes',
                  style: textTheme.titleSmall?.copyWith(color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: InputBorder.none,
                      hintText: 'Add notes about this checkout...',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 28),

                // Submit Button
                Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.checkOut(
                                meetingId: widget.meetingId,
                                meetingType: selectedMeetingType,
                                products: selectedProducts.isNotEmpty
                                    ? selectedProducts
                                        .map((p) => p.toCheckoutProduct())
                                        .toList()
                                    : null,
                                notes: notesController.text.isNotEmpty
                                    ? notesController.text
                                    : null,
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.purple,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Complete Checkout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
