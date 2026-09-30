import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/job_proposal_model.dart';
import 'package:belwork/models/technician_job_response.dart';
import 'package:belwork/services/repository/chat_repository.dart';
import 'package:belwork/services/repository/technician_opportunity_repository.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class QuotationDialog extends StatefulWidget {
  final String? jobId;
  final String? partnerUserId;
  final String professionalId;
  final Function(JobProposalResponseData proposal, String effectiveJobId)
  onProposalCreated;

  const QuotationDialog({
    super.key,
    this.jobId,
    this.partnerUserId,
    required this.professionalId,
    required this.onProposalCreated,
  });

  @override
  State<QuotationDialog> createState() => _QuotationDialogState();
}

class _QuotationDialogState extends State<QuotationDialog> {
  final _formKey = GlobalKey<FormState>();

  // Numerical controllers initialized empty
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _materialPriceController =
      TextEditingController();
  final TextEditingController _depositAmountController =
      TextEditingController();
  final TextEditingController _depositPctController = TextEditingController();
  final TextEditingController _vatPctController = TextEditingController();

  final TextEditingController _searchController = TextEditingController();

  List<TechnicianJobItem> _allJobs = [];
  List<TechnicianJobItem> _filteredJobs = [];
  TechnicianJobItem? _selectedJob;
  String? _selectedJobId;

  bool _isLoadingJobs = true;
  bool _isLoading = false;
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _selectedJobId = widget.jobId;
    _fetchJobs();
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _hourlyRateController.dispose();
    _materialPriceController.dispose();
    _depositAmountController.dispose();
    _depositPctController.dispose();
    _vatPctController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchJobs() async {
    try {
      final response = await TechnicianOpportunityRepository.instance
          .getTechnicianJobs();
      if (mounted) {
        final jobs = response?.data ?? [];
        TechnicianJobItem? initialMatch;

        if (widget.jobId != null && widget.jobId!.isNotEmpty) {
          initialMatch = jobs.where((j) => j.id == widget.jobId).firstOrNull;
        }

        if (initialMatch == null &&
            widget.partnerUserId != null &&
            widget.partnerUserId!.isNotEmpty) {
          initialMatch = jobs
              .where((j) => j.userId == widget.partnerUserId)
              .firstOrNull;
        }

        setState(() {
          _allJobs = jobs;
          _filteredJobs = jobs;
          _selectedJob = initialMatch ?? (jobs.isNotEmpty ? jobs.first : null);
          if (_selectedJob != null) {
            _selectedJobId = _selectedJob!.id;
          }
          _isLoadingJobs = false;
        });
      }
    } catch (e) {
      errorLog('QuotationDialog._fetchJobs', e);
      if (mounted) setState(() => _isLoadingJobs = false);
    }
  }

  void _filterJobs(String query) {
    if (query.trim().isEmpty) {
      setState(() => _filteredJobs = _allJobs);
      return;
    }
    final q = query.toLowerCase();
    setState(() {
      _filteredJobs = _allJobs.where((j) {
        final title = (j.title ?? '').toLowerCase();
        final desc = (j.description ?? '').toLowerCase();
        final userName = (j.user?.name ?? '').toLowerCase();
        final region = (j.region ?? '').toLowerCase();
        return title.contains(q) ||
            desc.contains(q) ||
            userName.contains(q) ||
            region.contains(q);
      }).toList();
    });
  }

  double get _calcHours => double.tryParse(_hoursController.text.trim()) ?? 0;
  double get _calcRate =>
      double.tryParse(_hourlyRateController.text.trim()) ?? 0;
  double get _calcMaterial =>
      double.tryParse(_materialPriceController.text.trim()) ?? 0;
  double get _calcVatPct => double.tryParse(_vatPctController.text.trim()) ?? 0;
  double get _calcDepositPct =>
      double.tryParse(_depositPctController.text.trim()) ?? 0;

  double get _calcSubtotal => (_calcHours * _calcRate) + _calcMaterial;
  double get _calcVatAmount => _calcSubtotal * _calcVatPct / 100;
  double get _calcTotal => _calcSubtotal + _calcVatAmount;

  Future<void> _submitProposal() async {
    if (!_formKey.currentState!.validate()) return;

    final effectiveJobId =
        _selectedJob?.id ?? _selectedJobId ?? widget.jobId ?? '';

    if (effectiveJobId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a job for this quotation.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final request = JobProposalRequest(
      jobId: effectiveJobId,
      professionalId: widget.professionalId,
      totalHoursToComplete: _hoursController.text.trim().isEmpty
          ? '0'
          : _hoursController.text.trim(),
      hourlyRate: _hourlyRateController.text.trim().isEmpty
          ? '0'
          : _hourlyRateController.text.trim(),
      materialPrice: _materialPriceController.text.trim().isEmpty
          ? '0'
          : _materialPriceController.text.trim(),
      depositAmount: _depositAmountController.text.trim().isEmpty
          ? '0'
          : _depositAmountController.text.trim(),
      depositRequiredPercentage: _depositPctController.text.trim().isEmpty
          ? '0'
          : _depositPctController.text.trim(),
      vatPercentage: _vatPctController.text.trim().isEmpty
          ? '0'
          : _vatPctController.text.trim(),
    );

    try {
      final result = await ChatRepository.instance.createJobProposal(request);
      if (mounted) {
        setState(() => _isLoading = false);
        if (result != null) {
          final effectiveProposal = result.copyWith(
            totalHoursToComplete:
                (result.totalHoursToComplete.isNotEmpty &&
                    result.totalHoursToComplete != '0')
                ? result.totalHoursToComplete
                : request.totalHoursToComplete,
            hourlyRate:
                (result.hourlyRate.isNotEmpty && result.hourlyRate != '0')
                ? result.hourlyRate
                : request.hourlyRate,
            materialPrice:
                (result.materialPrice.isNotEmpty && result.materialPrice != '0')
                ? result.materialPrice
                : request.materialPrice,
            depositAmount:
                (result.depositAmount.isNotEmpty && result.depositAmount != '0')
                ? result.depositAmount
                : request.depositAmount,
            depositRequiredPercentage:
                (result.depositRequiredPercentage.isNotEmpty &&
                    result.depositRequiredPercentage != '0')
                ? result.depositRequiredPercentage
                : request.depositRequiredPercentage,
            vatPercentage:
                (result.vatPercentage.isNotEmpty && result.vatPercentage != '0')
                ? result.vatPercentage
                : request.vatPercentage,
          );
          Navigator.of(context).pop();
          widget.onProposalCreated(effectiveProposal, effectiveJobId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create job proposal. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      errorLog('QuotationDialog._submitProposal', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while submitting proposal.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.instance.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title & Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      text: 'Send Job Proposal',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.instance.textColor,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: AppColors.instance.gray500,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Gap(height: 4),
                AppText(
                  text: 'Enter price quotation details below',
                  fontSize: 13,
                  color: AppColors.instance.gray500,
                ),
                const Gap(height: 14),

                _buildJobDropdownField(),
                const Gap(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _hoursController,
                        label: 'Total Hours',
                        hint: '3',
                        isRequired: true,
                      ),
                    ),
                    const Gap(width: 12),
                    Expanded(
                      child: _buildInputField(
                        controller: _hourlyRateController,
                        label: 'Hourly Rate (€)',
                        hint: '25',
                        isRequired: true,
                      ),
                    ),
                  ],
                ),
                const Gap(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _materialPriceController,
                        label: 'Material Price (€)',
                        hint: '50',
                        isRequired: true,
                      ),
                    ),
                    const Gap(width: 12),
                    Expanded(
                      child: _buildInputField(
                        controller: _depositAmountController,
                        label: 'Deposit Amount (€)',
                        hint: '20',
                        isRequired: true,
                      ),
                    ),
                  ],
                ),
                const Gap(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _depositPctController,
                        label: 'Deposit',
                        hint: '10',
                        isRequired: true,
                      ),
                    ),
                    const Gap(width: 12),
                    Expanded(
                      child: _buildInputField(
                        controller: _vatPctController,
                        label: 'VAT (%)',
                        hint: '21',
                        isRequired: true,
                      ),
                    ),
                  ],
                ),
                const Gap(height: 16),

                // Live Summary Calculation Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.instance.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.instance.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text:
                                'Subtotal: €${_calcSubtotal.toStringAsFixed(2)}',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.instance.gray500,
                          ),
                          AppText(
                            text:
                                'VAT (${_calcVatPct.toStringAsFixed(0)}%): €${_calcVatAmount.toStringAsFixed(2)}',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.instance.gray500,
                          ),
                          if (_calcDepositPct > 0)
                            AppText(
                              text:
                                  'Deposit (${_calcDepositPct.toStringAsFixed(0)}%): €${(_calcTotal * _calcDepositPct / 100).toStringAsFixed(2)}',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.instance.gray500,
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppText(
                            text: 'Total Amount',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.instance.gray500,
                          ),
                          AppText(
                            text: '€${_calcTotal.toStringAsFixed(2)}',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.instance.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(height: 16),

                // Send Proposal Button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton(
                        onTap: _submitProposal,
                        title: 'Send Proposal',
                        backgroundColor: AppColors.instance.primary,
                        titleColor: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        borderRadius: BorderRadius.circular(12),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Select Job',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.instance.textColor,
        ),
        const Gap(height: 6),

        // Dropdown Header Box
        GestureDetector(
          onTap: () {
            setState(() {
              _isDropdownOpen = !_isDropdownOpen;
              if (_isDropdownOpen) {
                _searchController.clear();
                _filteredJobs = _allJobs;
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFF4EFF1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isDropdownOpen
                    ? AppColors.instance.primary
                    : Colors.black.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.work_outline_rounded,
                  size: 18,
                  color: AppColors.instance.primary,
                ),
                const Gap(width: 8),
                Expanded(
                  child: _isLoadingJobs
                      ? AppText(
                          text: 'Loading jobs...',
                          fontSize: 13,
                          color: AppColors.instance.gray500,
                        )
                      : AppText(
                          text:
                              _selectedJob?.title ??
                              (_allJobs.isEmpty
                                  ? 'No jobs available'
                                  : 'Select a job...'),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: _selectedJob != null
                              ? AppColors.instance.textColor
                              : AppColors.instance.gray500,
                          maxLines: 1,
                        ),
                ),
                if (_selectedJob != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedJob = null;
                        _selectedJobId = null;
                        _isDropdownOpen = true;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.instance.gray500,
                      ),
                    ),
                  ),
                Icon(
                  _isDropdownOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.instance.gray500,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Dropdown Search & Item List
        if (_isDropdownOpen)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE8E2E4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search Input inside dropdown
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterJobs,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search job title...',
                      hintStyle: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.instance.gray500,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 16),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 30,
                        minHeight: 30,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7F5F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEFEBEF)),

                // Jobs List
                Expanded(
                  child: _isLoadingJobs
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : _filteredJobs.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: AppText(
                              text: 'No jobs found',
                              fontSize: 12.5,
                              color: AppColors.instance.gray500,
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _filteredJobs.length,
                          separatorBuilder: (_, _) => const Divider(
                            height: 1,
                            color: Color(0xFFF7F4F5),
                          ),
                          itemBuilder: (context, index) {
                            final job = _filteredJobs[index];
                            final isSelected = _selectedJob?.id == job.id;
                            return ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              tileColor: isSelected
                                  ? AppColors.instance.primary.withValues(
                                      alpha: 0.08,
                                    )
                                  : null,
                              title: AppText(
                                text: job.title ?? 'Untitled Job',
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.instance.primary
                                    : AppColors.instance.textColor,
                                maxLines: 1,
                              ),
                              subtitle: AppText(
                                text:
                                    '${job.user?.name ?? 'Customer'} • ${job.region ?? 'BRUSSELS'}',
                                fontSize: 11,
                                color: AppColors.instance.gray4B,
                                maxLines: 1,
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle_rounded,
                                      size: 16,
                                      color: AppColors.instance.primary,
                                    )
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedJob = job;
                                  _selectedJobId = job.id;
                                  _isDropdownOpen = false;
                                });
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.instance.textColor,
        ),
        const Gap(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
          style: TextStyle(fontSize: 14, color: AppColors.instance.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: AppColors.instance.gray500,
            ),
            filled: true,
            fillColor: const Color(0xFFF4EFF1),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.black.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.black.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.instance.primary),
            ),
            isDense: true,
          ),
          validator: (val) {
            if (isRequired && (val == null || val.trim().isEmpty)) {
              return 'Required';
            }
            return null;
          },
        ),
      ],
    );
  }
}
