import 'package:ZipBee_Driver/core/common/style/global_text_style.dart';
import 'package:ZipBee_Driver/core/utils/constants/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderPaymentScreen extends StatefulWidget {
  const OrderPaymentScreen({
    super.key,
    required this.isCash,
    required this.fixedFare,
    this.initialErp = 0.0,
    this.initialOthers = 0.0,
    this.initialReason = '',
    this.onOpenScanAndPay,
    this.onConfirmPayment,
  });

  final bool isCash;
  final double fixedFare;
  final double initialErp;
  final double initialOthers;
  final String initialReason;
  final Future<void> Function({
    required double erpFee,
    required double othersFee,
    required String reason,
    required double totalAmount,
  })? onOpenScanAndPay;
  final Future<bool> Function({
    required double erpFee,
    required double othersFee,
    required String reason,
    required double totalAmount,
  })? onConfirmPayment;

  @override
  State<OrderPaymentScreen> createState() => _OrderPaymentScreenState();
}

class _OrderPaymentScreenState extends State<OrderPaymentScreen> {
  late bool _isEditing;
  String _activeField = 'erp'; // 'erp' or 'others'
  late String _erpInput;
  late String _othersInput;
  late TextEditingController _reasonController;
  bool _isSubmitting = false;
  double _dragX = 0.0;

  @override
  void initState() {
    super.initState();
    _isEditing = true;
    _erpInput = widget.initialErp > 0
        ? widget.initialErp.toStringAsFixed(2)
        : '0.00';
    _othersInput = widget.initialOthers != 0
        ? widget.initialOthers.toStringAsFixed(2)
        : '0.00';
    _reasonController = TextEditingController(text: widget.initialReason);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  double get _erpValue => double.tryParse(_erpInput) ?? 0.0;
  double get _othersValue => double.tryParse(_othersInput) ?? 0.0;
  double get _additionalTotal => _erpValue + _othersValue;
  double get _totalAmount =>
      (widget.fixedFare + _erpValue + _othersValue).clamp(0.0, double.infinity);

  void _onKeyTap(String key) {
    setState(() {
      String current = _activeField == 'erp' ? _erpInput : _othersInput;
      if (current == '0.00' || current == '0') {
        current = '';
      }

      if (key == 'BACK') {
        if (current.isNotEmpty) {
          current = current.substring(0, current.length - 1);
        }
        if (current.isEmpty || current == '-') {
          current = '0.00';
        }
      } else if (key == '.') {
        if (!current.contains('.')) {
          current = '${current.isEmpty ? '0' : current}.';
        }
      } else if (key == '-') {
        if (_activeField == 'others') {
          if (current.startsWith('-')) {
            current = current.substring(1);
          } else {
            current = '-${current.isEmpty ? '' : current}';
          }
        }
      } else {
        if (current.contains('.')) {
          final decimals = current.split('.')[1];
          if (decimals.length >= 2) {
            return;
          }
        }
        current = '$current$key';
      }

      if (_activeField == 'erp') {
        _erpInput = current;
      } else {
        _othersInput = current;
      }
    });
  }

  void _finishEditing() {
    setState(() {
      _erpInput = _erpValue.toStringAsFixed(2);
      _othersInput = _othersValue.toStringAsFixed(2);
      _isEditing = false;
    });
  }

  Future<void> _submitPayment() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final reason = _resolveReason();
      if (widget.onConfirmPayment != null) {
        final ok = await widget.onConfirmPayment!(
          erpFee: _erpValue,
          othersFee: _othersValue,
          reason: reason,
          totalAmount: _totalAmount,
        );
        if (ok && mounted) {
          Get.back(
            result: {
              'confirmed': true,
              'erpFee': _erpValue,
              'othersFee': _othersValue,
              'additionalFee': _additionalTotal,
              'reason': reason,
              'totalAmount': _totalAmount,
            },
          );
        }
      } else {
        Get.back(
          result: {
            'confirmed': true,
            'erpFee': _erpValue,
            'othersFee': _othersValue,
            'additionalFee': _additionalTotal,
            'reason': reason,
            'totalAmount': _totalAmount,
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _resolveReason() {
    final custom = _reasonController.text.trim();
    if (custom.isNotEmpty) return custom;
    final parts = <String>[];
    if (_erpValue > 0) {
      parts.add('ERP (\$${_erpValue.toStringAsFixed(2)})');
    }
    if (_othersValue != 0) {
      parts.add('Others (\$${_othersValue.toStringAsFixed(2)})');
    }
    return parts.isEmpty ? 'Additional fee' : parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width - 32;
    final double maxDrag = (width - 80).clamp(60.0, double.infinity);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F232A),
        elevation: 0,
        leadingWidth: 90,
        leading: TextButton.icon(
          onPressed: () => Get.back(result: {'confirmed': false}),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 16,
          ),
          label: Text(
            'Back',
            style: getTextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Payment',
          style: getTextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.isCash) _buildCashTopTabs(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDarkFareCard(width: width, maxDrag: maxDrag),
                    const SizedBox(height: 12),
                    Text(
                      _isEditing
                          ? 'Editing of amount is allowed if there\'s changes'
                          : 'Please check and confirm that all entered amount are correct before tapping on ${widget.isCash ? 'Confirm Payment' : 'SEND'}',
                      style: getTextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isEditing) _buildNumericKeypad(),
          ],
        ),
      ),
    );
  }

  Widget _buildCashTopTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.payments_outlined,
              color: Colors.blue.shade700,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Fee & Payment',
              style: getTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          if (widget.onOpenScanAndPay != null)
            ElevatedButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      await widget.onOpenScanAndPay!(
                        erpFee: _erpValue,
                        othersFee: _othersValue,
                        reason: _resolveReason(),
                        totalAmount: _totalAmount,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButtonColor,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.qr_code_2, size: 16),
              label: Text(
                'Scan & Pay',
                style: getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDarkFareCard({required double width, required double maxDrag}) {
    final badgeText = widget.isCash ? 'Cash' : 'Credit';
    final badgeBg = widget.isCash
        ? const Color(0xFFE5E7EB)
        : AppColors.primaryButtonColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2B2F36),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 0, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fare Details',
                  style: getTextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    badgeText,
                    style: getTextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildFareRow(
                  label: 'Fixed Fare',
                  valueText: widget.fixedFare.toStringAsFixed(2),
                  isEditable: false,
                  isSelected: false,
                ),
                const Divider(color: Colors.white24, height: 18),
                _buildFareRow(
                  label: 'ERP',
                  valueText: _erpInput,
                  isEditable: _isEditing,
                  isSelected: _isEditing && _activeField == 'erp',
                  onTap: () => setState(() {
                    _isEditing = true;
                    _activeField = 'erp';
                  }),
                ),
                const SizedBox(height: 10),
                _buildFareRow(
                  label: 'Others',
                  valueText: _othersInput,
                  isEditable: _isEditing,
                  isSelected: _isEditing && _activeField == 'others',
                  onTap: () => setState(() {
                    _isEditing = true;
                    _activeField = 'others';
                  }),
                ),
                if (!_isEditing) ...[
                  const SizedBox(height: 14),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: getTextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _totalAmount.toStringAsFixed(2),
                        style: getTextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                if (!_isEditing && !widget.isCash) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Do Not Collect Cash.',
                          style: getTextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Payment will be processed automatically upon delivery confirmation. You don\'t need to collect cash.',
                          style: getTextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => setState(() => _isEditing = true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1565C0),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            'EDIT',
                            style: getTextStyle(
                              color: const Color(0xFF1565C0),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryButtonColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : Text(
                                  'SEND',
                                  style: getTextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                if (!_isEditing && widget.isCash) ...[
                  const SizedBox(height: 24),
                  _buildCashConfirmSlider(width: width - 32, maxDrag: maxDrag),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFareRow({
    required String label,
    required String valueText,
    required bool isEditable,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: getTextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isEditable)
            Container(
              width: 110,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1F232A),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryButtonColor
                      : Colors.white38,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              alignment: Alignment.centerRight,
              child: Text(
                valueText,
                style: getTextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Text(
              valueText,
              style: getTextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCashConfirmSlider({
    required double width,
    required double maxDrag,
  }) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primaryButtonColor,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(
              'Confirm Payment',
              style: getTextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Positioned(
          left: _dragX + 6,
          top: 6,
          bottom: 6,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (_isSubmitting) return;
              setState(() {
                _dragX = (_dragX + details.delta.dx).clamp(0.0, maxDrag);
              });
            },
            onHorizontalDragEnd: (_) async {
              if (_isSubmitting) return;
              if (_dragX >= maxDrag - 10) {
                await _submitPayment();
                if (mounted) {
                  setState(() => _dragX = 0.0);
                }
              } else {
                setState(() => _dragX = 0.0);
              }
            },
            child: Container(
              width: 48,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.arrow_forward, color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumericKeypad() {
    return Container(
      color: const Color(0xFFD1D5DB),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: const Color(0xFFE5E7EB),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _finishEditing,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 26),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                TextButton(
                  onPressed: _finishEditing,
                  child: Text(
                    'Done',
                    style: getTextStyle(
                      color: const Color(0xFF1565C0),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                _buildKeypadRow(['1', '2', '3']),
                const SizedBox(height: 6),
                _buildKeypadRow(['4', '5', '6']),
                const SizedBox(height: 6),
                _buildKeypadRow(['7', '8', '9']),
                const SizedBox(height: 6),
                _buildKeypadRow(['.', '0', 'BACK']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Material(
              color: key == 'BACK' ? Colors.transparent : Colors.white,
              borderRadius: BorderRadius.circular(6),
              elevation: key == 'BACK' ? 0 : 1,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => _onKeyTap(key),
                child: SizedBox(
                  height: 46,
                  child: Center(
                    child: key == 'BACK'
                        ? const Icon(Icons.backspace_outlined, size: 22)
                        : Text(
                            key,
                            style: getTextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
