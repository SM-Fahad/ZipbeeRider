import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/common/widgets/custom_button.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:ZipBee_Driver/features/support/user_support/help_center/controller/create_dispute_appeal_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateDisputeAppealScreen extends StatelessWidget {
  const CreateDisputeAppealScreen({
    super.key,
    required this.orderDisputeId,
    required this.orderId,
  });

  final int orderDisputeId;
  final int orderId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      CreateDisputeAppealController(
        orderDisputeId: orderDisputeId,
        orderId: orderId,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroungColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroungColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'File an Appeal',
          style: getTextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(
          () => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4C2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.gavel_outlined,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Appeal Order #$orderId',
                              style: getTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Explain what happened and add one proof image for review.',
                              style: getTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormGroup(
                        title: 'What Happened?',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: controller.reasonController,
                              minLines: 5,
                              maxLines: 7,
                              decoration: _inputDecoration(
                                'Describe why this decision should be reviewed',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Example Explanations (Tap to fill):',
                              style: getTextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _TemplateChip(
                                  label: 'Handed directly to customer',
                                  text:
                                      "The customer selected 'Hand to me' for the delivery. I arrived at the correct address, knocked on the door, and personally handed the package directly to a resident at the door who confirmed the name on the order. I completed the delivery process immediately while at the location. Please check my GPS ping history to verify that I was at the customer's exact coordinates at the timestamp of completion.",
                                  onSelected: (text) =>
                                      controller.reasonController.text = text,
                                ),
                                _TemplateChip(
                                  label: 'Merchant packaging issue',
                                  text:
                                      "The merchant packed the items poorly in a flimsy bag that was already structurally compromised upon pickup. I handled the order with extreme care and placed it securely in my thermal delivery bag throughout the trip. The photo taken at drop-off shows the package completely intact at the doorstep. Any damage inside the package was an issue with merchant packaging, not driver handling.",
                                  onSelected: (text) =>
                                      controller.reasonController.text = text,
                                ),
                                _TemplateChip(
                                  label: 'Sealed bag missing items',
                                  text:
                                      "The restaurant handed me a stapled and taped-sealed bag, which I am strictly prohibited from opening due to food safety and hygiene regulations. I verified the receipt attached to the outside of the bag with the order checklist on my screen, and everything matched. If items were missing from inside the sealed bag, it is a merchant error, not a driver error.",
                                  onSelected: (text) =>
                                      controller.reasonController.text = text,
                                ),
                                _TemplateChip(
                                  label: 'Traffic / Route delay',
                                  text:
                                      "I picked up the order immediately and proceeded directly to the delivery address. However, I encountered an unannounced road closure and emergency construction detour on Main Street, which added unavoidable time to the route. I messaged the customer through the app to inform them of the traffic delay as soon as it happened. The delay was entirely due to external traffic conditions beyond my control.",
                                  onSelected: (text) =>
                                      controller.reasonController.text = text,
                                ),
                                _TemplateChip(
                                  label: 'Delivered to specified unit',
                                  text:
                                      "I arrived at the location specified in the app and verified the unit number before leaving the delivery. I took a clear photo showing the item placed safely at the correct doorstep as requested by the customer's delivery notes. The customer may have entered the wrong unit number in their address profile.",
                                  onSelected: (text) =>
                                      controller.reasonController.text = text,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF0E2A2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: _SectionLabel(title: 'Add Proof (Optional)'),
                                ),
                                TextButton.icon(
                                  onPressed: controller.isUploadingImage.value
                                      ? null
                                      : controller.pickAndUploadImage,
                                  icon: controller.isUploadingImage.value
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.add_photo_alternate_outlined,
                                          color: Colors.black,
                                          size: 18,
                                        ),
                                  label: Text(
                                    controller.isUploadingImage.value
                                        ? 'Uploading...'
                                        : controller.fileUrl.value == null
                                            ? 'Add Proof (Optional)'
                                            : 'Replace',
                                    style: getTextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Attach delivery photograph or screenshot to support your case (Optional).',
                              style: getTextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (controller.pickedImage.value == null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE9E0BC),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.image_outlined,
                                      size: 32,
                                      color: Colors.black45,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No proof added yet',
                                      style: getTextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE9E0BC),
                                      ),
                                      image: DecorationImage(
                                        image: FileImage(
                                          controller.pickedImage.value!,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: controller.removeProof,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black87,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  label: controller.isSubmitting.value
                      ? 'Submitting...'
                      : 'Submit Appeal',
                  onPressed: controller.isSubmitting.value
                      ? () {}
                      : controller.submitAppeal,
                  color: AppColors.primaryButtonColor,
                  textColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: getTextStyle(fontSize: 13, color: Colors.black45),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE4E4E4)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE4E4E4)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryButtonColor),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: getTextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryFontColor,
      ),
    );
  }
}

class _FormGroup extends StatelessWidget {
  const _FormGroup({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(title: title),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _TemplateChip extends StatelessWidget {
  const _TemplateChip({
    required this.label,
    required this.text,
    required this.onSelected,
  });

  final String label;
  final String text;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: () => onSelected(text),
      backgroundColor: const Color(0xFFFFF4C2),
      side: const BorderSide(color: Color(0xFFE9E0BC)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      label: Text(
        label,
        style: getTextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }
}
