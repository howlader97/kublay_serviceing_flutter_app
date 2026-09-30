import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/chat_model.dart';
import 'package:belwork/models/customer_activity_response.dart';
import 'package:belwork/services/repository/chat_repository.dart';
import 'package:belwork/services/repository/customer_activity_repository.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import 'package:belwork/screens/chat_screen/chat_screen/widgets/stripe_payment_webview.dart';



class ProposalMessageCard extends StatefulWidget {
  final ChatMessageModel message;
  final bool isMe;
  final String? fallbackJobId;
  final String? fallbackProfessionalId;
  final Function(String status)? onStatusChanged;

  const ProposalMessageCard({
    super.key,
    required this.message,
    required this.isMe,
    this.fallbackJobId,
    this.fallbackProfessionalId,
    this.onStatusChanged,
  });

  @override
  State<ProposalMessageCard> createState() => _ProposalMessageCardState();
}

class _ProposalMessageCardState extends State<ProposalMessageCard> {
  String _currentStatus = 'PENDING';
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
    _extractStatus();
  }

  @override
  void didUpdateWidget(covariant ProposalMessageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.status != widget.message.status ||
        oldWidget.message.message != widget.message.message) {
      _extractStatus();
    }
  }

  void _extractStatus() {
    final text = widget.message.message;
    final msgStatus = widget.message.status.toUpperCase();
    if (msgStatus == 'ACCEPTED' || text.contains('Status: ACCEPTED')) {
      _currentStatus = 'ACCEPTED';
    } else if (msgStatus == 'CANCELLED' ||
        msgStatus == 'REJECTED' ||
        text.contains('Status: REJECTED') ||
        text.contains('Status: CANCELLED')) {
      _currentStatus = 'CANCELLED';
    } else {
      _currentStatus = 'PENDING';
    }
  }

  Map<String, String> _parseDetails(String rawMessage) {
    final Map<String, String> details = {};
    final lines = rawMessage.split('\n');
    for (final line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        final key = parts[0].replaceAll(RegExp(r'[^\w\s(%)]'), '').trim();
        final val = parts.sublist(1).join(':').trim();
        details[key] = val;
      }
    }
    return details;
  }

  String _extractProposalId(Map<String, String> details) {
    if (widget.message.proposalId != null &&
        widget.message.proposalId!.isNotEmpty &&
        !widget.message.proposalId!.startsWith('-')) {
      return widget.message.proposalId!;
    }
    for (final key in ['Proposal ID', 'ProposalID', 'proposalId']) {
      if (details.containsKey(key) &&
          details[key]!.isNotEmpty &&
          !details[key]!.startsWith('-')) {
        return details[key]!;
      }
    }
    final regMatch = RegExp(
      r'Proposal ID:[ \t]*([a-zA-Z0-9_-]{8,})',
      caseSensitive: false,
    ).firstMatch(widget.message.message);
    if (regMatch != null && regMatch.group(1) != null) {
      final val = regMatch.group(1)!;
      if (!val.startsWith('-')) {
        return val;
      }
    }
    return '';
  }

  String _extractJobId(Map<String, String> details) {
    if (widget.message.jobId != null &&
        widget.message.jobId!.isNotEmpty &&
        !widget.message.jobId!.startsWith('-')) {
      return widget.message.jobId!;
    }
    if (widget.fallbackJobId != null &&
        widget.fallbackJobId!.isNotEmpty &&
        !widget.fallbackJobId!.startsWith('-')) {
      return widget.fallbackJobId!;
    }
    for (final key in ['Job ID', 'JobID', 'jobId']) {
      if (details.containsKey(key) &&
          details[key]!.isNotEmpty &&
          !details[key]!.startsWith('-')) {
        return details[key]!;
      }
    }
    final regMatch = RegExp(
      r'Job ID:[ \t]*([a-zA-Z0-9_-]{8,})',
      caseSensitive: false,
    ).firstMatch(widget.message.message);
    if (regMatch != null && regMatch.group(1) != null) {
      final val = regMatch.group(1)!;
      if (!val.startsWith('-')) {
        return val;
      }
    }
    return '';
  }

  Future<String> _resolveJobId(Map<String, String> details, String professionalId) async {
    String jobId = _extractJobId(details);
    if (jobId.isNotEmpty) return jobId;

    // Fallback: look up user's active/pending jobs
    try {
      final customerJobs =
          await CustomerActivityRepository.instance.getCustomerAllJobs();
      if (customerJobs?.data != null && customerJobs!.data!.isNotEmpty) {
        final list = customerJobs.data!;
        CustomerJobItem? matched;
        if (professionalId.isNotEmpty) {
          matched = list.where((j) => j.professionalId == professionalId).firstOrNull;
        }
        matched ??= list.where((j) {
          final s = j.status?.toUpperCase() ?? '';
          return s == 'PENDING' || s == 'IN_PROGRESS' || s == 'CREATED';
        }).firstOrNull;
        matched ??= list.first;

        if (matched.id != null && matched.id!.isNotEmpty) {
          return matched.id!;
        }
      }
    } catch (e) {
      errorLog('ProposalMessageCard._resolveJobId', e);
    }
    return '';
  }

  String _extractProfessionalId(Map<String, String> details) {
    if (!widget.isMe && widget.message.senderId.isNotEmpty) {
      return widget.message.senderId;
    }
    if (widget.fallbackProfessionalId != null &&
        widget.fallbackProfessionalId!.isNotEmpty) {
      return widget.fallbackProfessionalId!;
    }
    for (final key in ['Professional ID', 'ProfessionalID', 'professionalId']) {
      if (details.containsKey(key) &&
          details[key]!.isNotEmpty &&
          !details[key]!.startsWith('-')) {
        return details[key]!;
      }
    }
    final regMatch = RegExp(
      r'Professional ID:[ \t]*([a-zA-Z0-9_-]{8,})',
      caseSensitive: false,
    ).firstMatch(widget.message.message);
    if (regMatch != null && regMatch.group(1) != null) {
      final val = regMatch.group(1)!;
      if (!val.startsWith('-')) {
        return val;
      }
    }
    return widget.message.senderId;
  }

  num _extractTotalHours(Map<String, String> details) {
    final hoursStr =
        details['Total Hours'] ?? details['totalHoursToComplete'] ?? '';
    final match = RegExp(r'^([\d.]+)').firstMatch(hoursStr.trim());
    if (match != null && match.group(1) != null) {
      return num.tryParse(match.group(1)!) ?? 0;
    }
    final clean = hoursStr.replaceAll(RegExp(r'[^\d.]'), '');
    return num.tryParse(clean) ?? 0;
  }

  num _extractHourlyRate(Map<String, String> details) {
    final rateStr = details['Hourly Rate'] ?? details['hourlyRate'] ?? '';
    if (rateStr.isNotEmpty) {
      final clean = rateStr.replaceAll(RegExp(r'[^\d.]'), '');
      final parsed = num.tryParse(clean);
      if (parsed != null) return parsed;
    }
    // Try to parse ($50/hr) or similar from Total Hours text
    final hoursStr = details['Total Hours'] ?? '';
    final rateMatch = RegExp(r'\$([\d.]+)').firstMatch(hoursStr);
    if (rateMatch != null && rateMatch.group(1) != null) {
      return num.tryParse(rateMatch.group(1)!) ?? 0;
    }
    return 0;
  }

  num _extractMaterialPrice(Map<String, String> details) {
    final matStr =
        details['Material Price'] ?? details['materialPrice'] ?? '0';
    final clean = matStr.replaceAll(RegExp(r'[^\d.]'), '');
    return num.tryParse(clean) ?? 0;
  }

  num _extractVatPercentage(Map<String, String> details) {
    String vatStr = details['VAT'] ?? details['vatPercentage'] ?? '';
    if (vatStr.isEmpty) {
      for (final entry in details.entries) {
        if (entry.key.toUpperCase().startsWith('VAT')) {
          final match = RegExp(r'(\d+(\.\d+)?)%').firstMatch(entry.key);
          if (match != null && match.group(1) != null) {
            vatStr = match.group(1)!;
            break;
          }
          vatStr = entry.value;
          break;
        }
      }
    }
    final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(vatStr);
    if (match != null && match.group(1) != null) {
      return num.tryParse(match.group(1)!) ?? 0;
    }
    return 0;
  }

  Future<void> _handleAccept() async {
    if (_isAccepting) return;

    final details = _parseDetails(widget.message.message);
    final proposalId = _extractProposalId(details);

    if (proposalId.isEmpty || proposalId.startsWith('-')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text('Proposal ID missing! Please ask the professional to re-send the quotation.'),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final professionalId = _extractProfessionalId(details);
    final jobId = await _resolveJobId(details, professionalId);

    if (jobId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text('Job ID is missing for this quotation! Cannot create payment checkout.'),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final totalHours = _extractTotalHours(details);
    final hourlyRate = _extractHourlyRate(details);
    final materialPrice = _extractMaterialPrice(details);
    final vatPercentage = _extractVatPercentage(details);

    setState(() {
      _isAccepting = true;
    });

    try {
      // ─── 1. CREATE PAYMENT CHECKOUT (STRIPE) ──────────────────────────────
      final checkoutUrl = await ChatRepository.instance.createPaymentCheckout(
        jobId: jobId,
        professionalId: professionalId,
        totalHoursToComplete: totalHours,
        hourlyRate: hourlyRate,
        materialPrice: materialPrice,
        vatPercentage: vatPercentage,
      );

      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isAccepting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Failed to create payment checkout. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      // ─── 2. OPEN STRIPE PAYMENT IN-APP WEBVIEW ───────────────────────────
      final paymentSuccess = await StripePaymentWebViewScreen.show(
        context,
        checkoutUrl: checkoutUrl,
      );

      if (paymentSuccess != true) {
        if (!mounted) return;
        setState(() {
          _isAccepting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Payment was cancelled or not completed.'),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      // ─── 3. ACCEPT PROPOSAL AFTER PAYMENT SUCCESS ─────────────────────────
      final success = await ChatRepository.instance.updateJobProposalStatus(
        proposalId: proposalId,
        status: 'ACCEPTED',
      );

      if (!mounted) return;

      setState(() {
        _isAccepting = false;
      });

      if (success) {
        setState(() {
          _currentStatus = 'ACCEPTED';
        });
        if (widget.onStatusChanged != null) {
          widget.onStatusChanged!('ACCEPTED');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Payment completed & quotation accepted successfully!'),
                ),
              ],
            ),
            backgroundColor: AppColors.instance.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Payment finished, but failed to update status. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      errorLog('ProposalMessageCard._handleAccept', e);
      if (mounted) {
        setState(() {
          _isAccepting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text('An error occurred during payment processing.'),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleCancel() async {
    if (_isAccepting) return;

    final details = _parseDetails(widget.message.message);
    final proposalId = _extractProposalId(details);

    if (proposalId.isNotEmpty && !proposalId.startsWith('-')) {
      setState(() {
        _isAccepting = true;
      });

      await ChatRepository.instance.updateJobProposalStatus(
        proposalId: proposalId,
        status: 'REJECTED',
      );

      if (!mounted) return;

      setState(() {
        _isAccepting = false;
      });
    }

    setState(() {
      _currentStatus = 'CANCELLED';
    });
    if (widget.onStatusChanged != null) {
      widget.onStatusChanged!('CANCELLED');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text('Quotation proposal rejected.'),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final details = _parseDetails(widget.message.message);

    final totalHours =
        (details['Total Hours'] ?? details['totalHoursToComplete'] ?? '-')
            .replaceAll(r'$', '€');
    final materialPrice =
        (details['Material Price'] ?? details['materialPrice'] ?? '-')
            .replaceAll(r'$', '€');
    final subtotal =
        (details['Subtotal'] ?? details['subTotalAmount'] ?? '-')
            .replaceAll(r'$', '€');


    // Extract VAT value: supports 'VAT', 'VAT (10%)', 'VAT 10%', etc.
    String vat = details['VAT'] ?? details['vatPercentage'] ?? '';
    if (vat.isEmpty) {
      for (final entry in details.entries) {
        if (entry.key.toUpperCase().startsWith('VAT')) {
          vat = entry.value;
          break;
        }
      }
    }
    if (vat.isEmpty) vat = '-';
    vat = vat.replaceAll(r'$', '€');

    final total =
        (details['Total Amount'] ?? details['total'] ?? '-')
            .replaceAll(r'$', '€');
    final deposit =
        (details['Deposit Required'] ?? details['depositAmount'] ?? '-')
            .replaceAll(r'$', '€');

    String timeStr = '';
    if (widget.message.createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(widget.message.createdAt).toLocal();
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        timeStr = '$hour:$minute';
      } catch (_) {
        timeStr = widget.message.createdAt.length >= 16
            ? widget.message.createdAt.substring(11, 16)
            : widget.message.createdAt;
      }
    }

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.86,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: const Color(0xFFEBE6E8), width: 1.2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.instance.primary,
                      const Color(0xFF1E2B37),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const Gap(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: 'BELWORK',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            const Gap(height: 2),
                            Text(
                              'OFFICIAL QUOTATION',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.8),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildRow(
                      icon: Icons.timer_outlined,
                      label: 'Total Hours',
                      value: totalHours,
                    ),
                    const Gap(height: 10),
                    _buildRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Material Price',
                      value: materialPrice,
                    ),
                    const Gap(height: 10),
                    _buildRow(
                      icon: Icons.subtitles_outlined,
                      label: 'Subtotal',
                      value: subtotal,
                    ),
                    const Gap(height: 10),
                    _buildRow(
                      icon: Icons.percent_outlined,
                      label: 'VAT',
                      value: vat,
                    ),
                    const Gap(height: 10),
                    _buildRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Deposit Required',
                      value: deposit,
                    ),

                    const Gap(height: 14),

                    // ─── TOTAL PRICE HERO CONTAINER ─────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.instance.primary.withValues(
                          alpha: 0.06,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.instance.primary.withValues(
                            alpha: 0.15,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.payments_rounded,
                                color: AppColors.instance.primary,
                                size: 20,
                              ),
                              const Gap(width: 8),
                              AppText(
                                text: 'Total Amount',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.instance.textColor,
                              ),
                            ],
                          ),
                          AppText(
                            text: total,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.instance.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (!widget.isMe) ...[
                const Divider(height: 1, color: Color(0xFFEBE6E8)),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: _currentStatus == 'PENDING'
                      ? Row(
                          children: [
                            // Cancel Button
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _handleCancel,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFCE8E6),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(
                                          0xD9D93025,
                                        ).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.close_rounded,
                                          color: Color(0xD9D93025),
                                          size: 18,
                                        ),
                                        Gap(width: 6),
                                        Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xD9D93025),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Gap(width: 12),

                            // Accept Button
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _isAccepting ? null : _handleAccept,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.instance.success,
                                          const Color(0xFF15803D),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.instance.success
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: _isAccepting
                                        ? const Center(
                                            child: SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.check_circle_rounded,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              Gap(width: 6),
                                              Text(
                                                'Accept',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _currentStatus == 'ACCEPTED'
                                ? const Color(0xFFE6F4EA)
                                : const Color(0xFFFCE8E6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _currentStatus == 'ACCEPTED'
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  size: 16,
                                  color: _currentStatus == 'ACCEPTED'
                                      ? const Color(0xFF1E8E3E)
                                      : const Color(0xD9D93025),
                                ),
                                const Gap(width: 6),
                                Text(
                                  _currentStatus == 'ACCEPTED'
                                      ? 'You accepted this proposal'
                                      : 'Proposal cancelled',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _currentStatus == 'ACCEPTED'
                                        ? const Color(0xFF1E8E3E)
                                        : const Color(0xD9D93025),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ] else ...[
                // Sender / Technician View note
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  color: _currentStatus == 'ACCEPTED'
                      ? const Color(0xFFE6F4EA)
                      : (_currentStatus == 'CANCELLED'
                            ? const Color(0xFFFCE8E6)
                            : const Color(0xFFFAF9FA)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _currentStatus == 'PENDING'
                                ? Icons.access_time_rounded
                                : (_currentStatus == 'ACCEPTED'
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded),
                            size: 15,
                            color: _currentStatus == 'ACCEPTED'
                                ? const Color(0xFF1E8E3E)
                                : (_currentStatus == 'CANCELLED'
                                      ? const Color(0xD9D93025)
                                      : AppColors.instance.gray500),
                          ),
                          const Gap(width: 6),
                          Text(
                            _currentStatus == 'PENDING'
                                ? 'Proposal sent • Waiting response'
                                : (_currentStatus == 'ACCEPTED'
                                      ? 'Proposal Accepted by Customer'
                                      : 'Proposal Cancelled'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: _currentStatus == 'ACCEPTED'
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: _currentStatus == 'ACCEPTED'
                                  ? const Color(0xFF1E8E3E)
                                  : (_currentStatus == 'CANCELLED'
                                        ? const Color(0xD9D93025)
                                        : AppColors.instance.gray500),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.instance.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.instance.gray500),
            const Gap(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.instance.gray500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.instance.textColor,
          ),
        ),
      ],
    );
  }
}
