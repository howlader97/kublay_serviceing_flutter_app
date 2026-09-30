class JobProposalRequest {
  final String jobId;
  final String professionalId;
  final String totalHoursToComplete;
  final String hourlyRate;
  final String materialPrice;
  final String depositAmount;
  final String depositRequiredPercentage;
  final String vatPercentage;

  const JobProposalRequest({
    required this.jobId,
    required this.professionalId,
    required this.totalHoursToComplete,
    required this.hourlyRate,
    required this.materialPrice,
    required this.depositAmount,
    required this.depositRequiredPercentage,
    required this.vatPercentage,
  });

  Map<String, dynamic> toJson() {
    final hours = num.tryParse(totalHoursToComplete) ?? 0;
    final rate = num.tryParse(hourlyRate) ?? 0;
    final material = num.tryParse(materialPrice) ?? 0;
    final deposit = num.tryParse(depositAmount) ?? 0;
    final depositPct = num.tryParse(depositRequiredPercentage) ?? 0;
    final vat = num.tryParse(vatPercentage) ?? 0;

    return {
      'jobId': jobId,
      'professionalId': professionalId,
      'totalHoursToComplete': hours,
      'hourlyRate': rate,
      'materialPrice': material,
      'depositAmount': deposit,
      'depositRequiredPercentage': depositPct,
      'vatPercentage': vat,
    };
  }
}

class JobProposalResponseData {
  final String id;
  final String jobId;
  final String professionalId;
  final String totalHoursToComplete;
  final String hourlyRate;
  final String materialPrice;
  final String discountAmount;
  final String depositRequiredPercentage;
  final String depositAmount;
  final String vatPercentage;
  final String vatAmountTotal;
  final String subTotalAmount;
  final String total;
  final String status;
  final String createdAt;
  final String updatedAt;

  const JobProposalResponseData({
    required this.id,
    required this.jobId,
    required this.professionalId,
    required this.totalHoursToComplete,
    required this.hourlyRate,
    required this.materialPrice,
    this.discountAmount = '0',
    required this.depositRequiredPercentage,
    required this.depositAmount,
    required this.vatPercentage,
    required this.vatAmountTotal,
    required this.subTotalAmount,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  JobProposalResponseData copyWith({
    String? id,
    String? jobId,
    String? professionalId,
    String? totalHoursToComplete,
    String? hourlyRate,
    String? materialPrice,
    String? discountAmount,
    String? depositRequiredPercentage,
    String? depositAmount,
    String? vatPercentage,
    String? vatAmountTotal,
    String? subTotalAmount,
    String? total,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return JobProposalResponseData(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      professionalId: professionalId ?? this.professionalId,
      totalHoursToComplete: totalHoursToComplete ?? this.totalHoursToComplete,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      materialPrice: materialPrice ?? this.materialPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      depositRequiredPercentage:
          depositRequiredPercentage ?? this.depositRequiredPercentage,
      depositAmount: depositAmount ?? this.depositAmount,
      vatPercentage: vatPercentage ?? this.vatPercentage,
      vatAmountTotal: vatAmountTotal ?? this.vatAmountTotal,
      subTotalAmount: subTotalAmount ?? this.subTotalAmount,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory JobProposalResponseData.fromJson(Map<String, dynamic> json) {
    final map = json.containsKey('proposal') && json['proposal'] is Map<String, dynamic>
        ? json['proposal'] as Map<String, dynamic>
        : (json.containsKey('jobProposal') && json['jobProposal'] is Map<String, dynamic>
            ? json['jobProposal'] as Map<String, dynamic>
            : (json.containsKey('data') && json['data'] is Map<String, dynamic>
                ? json['data'] as Map<String, dynamic>
                : json));

    return JobProposalResponseData(
      id: map['id']?.toString() ??
          map['_id']?.toString() ??
          map['proposalId']?.toString() ??
          map['proposal_id']?.toString() ??
          json['id']?.toString() ??
          '',
      jobId: map['jobId']?.toString() ??
          map['job_id']?.toString() ??
          json['jobId']?.toString() ??
          '',
      professionalId: map['professionalId']?.toString() ??
          map['professional_id']?.toString() ??
          json['professionalId']?.toString() ??
          '',
      totalHoursToComplete: map['totalHoursToComplete']?.toString() ??
          map['total_hours_to_complete']?.toString() ??
          '0',
      hourlyRate: map['hourlyRate']?.toString() ??
          map['hourly_rate']?.toString() ??
          '0',
      materialPrice: map['materialPrice']?.toString() ??
          map['material_price']?.toString() ??
          '0',
      discountAmount: map['discountAmount']?.toString() ??
          map['discount_amount']?.toString() ??
          '0',
      depositRequiredPercentage: map['depositRequiredPercentage']?.toString() ??
          map['deposit_required_percentage']?.toString() ??
          '0',
      depositAmount: map['depositAmount']?.toString() ??
          map['deposit_amount']?.toString() ??
          '0',
      vatPercentage: map['vatPercentage']?.toString() ??
          map['vat_percentage']?.toString() ??
          '0',
      vatAmountTotal: map['vatAmountTotal']?.toString() ??
          map['vat_amount_total']?.toString() ??
          '0',
      subTotalAmount: map['subTotalAmount']?.toString() ??
          map['sub_total_amount']?.toString() ??
          '0',
      total: map['total']?.toString() ?? '0',
      status: map['status']?.toString() ?? 'PENDING',
      createdAt: map['createdAt']?.toString() ??
          map['created_at']?.toString() ??
          '',
      updatedAt: map['updatedAt']?.toString() ??
          map['updated_at']?.toString() ??
          '',
    );
  }

  double get _hours => double.tryParse(totalHoursToComplete) ?? 0;
  double get _rate => double.tryParse(hourlyRate) ?? 0;
  double get _material => double.tryParse(materialPrice) ?? 0;
  double get _vatPct => double.tryParse(vatPercentage) ?? 0;
  double get _depositPct => double.tryParse(depositRequiredPercentage) ?? 0;

  double get subtotal {
    final parsed = double.tryParse(subTotalAmount);
    if (parsed != null && parsed > 0) return parsed;
    return (_hours * _rate) + _material;
  }

  double get vatAmount {
    final parsed = double.tryParse(vatAmountTotal);
    if (parsed != null && parsed > 0) return parsed;
    return subtotal * _vatPct / 100;
  }

  double get grandTotal {
    final parsed = double.tryParse(total);
    if (parsed != null && parsed > 0) return parsed;
    return subtotal + vatAmount;
  }

  double get deposit {
    final parsed = double.tryParse(depositAmount);
    if (parsed != null && parsed > 0) return parsed;
    if (_depositPct > 0) {
      return grandTotal * _depositPct / 100;
    }
    return 0;
  }

  String toFormattedChatMessage() {
    final fmtMaterial = _material > 0
        ? _material.toStringAsFixed(2)
        : materialPrice;
    final fmtSubtotal = subtotal.toStringAsFixed(2);
    final fmtVat = vatAmount.toStringAsFixed(2);
    final fmtTotal = grandTotal.toStringAsFixed(2);
    final fmtDeposit = deposit.toStringAsFixed(2);

    return '''
📋 JOB PROPOSAL QUOTATION
Proposal ID: $id
Job ID: $jobId
Professional ID: $professionalId
----------------------------------------
⏱️ Total Hours: $totalHoursToComplete hrs (\$$hourlyRate/hr)
📦 Material Price: \$$fmtMaterial
💵 Subtotal: \$$fmtSubtotal
📊 VAT ($vatPercentage%): \$$fmtVat
💰 Total Amount: \$$fmtTotal
💳 Deposit Required: \$$fmtDeposit ($depositRequiredPercentage%)
📌 Status: $status
'''
        .trim();
  }
}

typedef ProposalData = JobProposalResponseData;
