import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/widgets.dart';
import '../../../organization/presentation/providers/organization_provider.dart';
import '../providers/staff_provider.dart';

class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgAsync = ref.watch(organizationProvider);

    return orgAsync.when(
      loading: () => const NyLoading(fullScreen: true),
      error: (e, _) => NyEmptyState(message: 'Error loading org: $e'),
      data: (org) =>
          _StaffBody(orgId: org?.id ?? '', orgCode: org?.code ?? 'ORG'),
    );
  }
}

class _StaffBody extends ConsumerStatefulWidget {
  const _StaffBody({required this.orgId, required this.orgCode});
  final String orgId;
  final String orgCode;

  @override
  ConsumerState<_StaffBody> createState() => _StaffBodyState();
}

class _StaffBodyState extends ConsumerState<_StaffBody> {
  final _nameCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _empNoCtrl = TextEditingController();
  final _branchCtrl = TextEditingController();

  String _selectedDept = AppStrings.generalNoDepartment;
  String _deptCode = 'GEN';
  DateTime? _dob;
  DateTime? _dateEmployed;
  DateTime? _cardValidUntil;

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _positionCtrl,
      _phoneCtrl,
      _emailCtrl,
      _empNoCtrl,
      _branchCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(
    BuildContext context, {
    required void Function(DateTime) onPicked,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1940),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _register() async {
    await ref.read(registerStaffProvider.notifier).register(
          orgId: widget.orgId,
          orgCode: widget.orgCode,
          fullName: _nameCtrl.text,
          department: _selectedDept,
          deptCode: _deptCode,
          position: _positionCtrl.text,
          phone: _phoneCtrl.text,
          email: _emailCtrl.text,
          employeeNo: _empNoCtrl.text,
          branch: _branchCtrl.text,
          dateOfBirth: _dob,
          dateEmployed: _dateEmployed,
          cardValidUntil: _cardValidUntil,
        );
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffListProvider(widget.orgId));
    final regState = ref.watch(registerStaffProvider);
    final isLoading = regState is RegisterStaffLoading;

    ref.listen<RegisterStaffState>(registerStaffProvider, (_, next) {
      if (next is RegisterStaffSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Staff registered. Code: ${next.staffCode}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
        _nameCtrl.clear();
        _positionCtrl.clear();
        _phoneCtrl.clear();
        _emailCtrl.clear();
        _empNoCtrl.clear();
        _branchCtrl.clear();
        setState(() {
          _dob = null;
          _dateEmployed = null;
          _cardValidUntil = null;
        });
        ref.read(registerStaffProvider.notifier).reset();
      } else if (next is RegisterStaffError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
        ref.read(registerStaffProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogo(size: 36),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppConstants.appName, style: AppTextStyles.titleLarge),
                Text('Nyescall Center', style: AppTextStyles.bodySmall),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.staff, style: AppTextStyles.headlineMedium),
                  staffAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (list) => Text(
                      '${list.length} ${AppStrings.registered} · ${AppStrings.staffSubtitle}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
              NyButton(
                label: '+ ${AppStrings.add}',
                height: 38,
                onPressed: () {},
                variant: NyButtonVariant.filled,
                backgroundColor: AppColors.primary,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Register form ─────────────────────────────────────────────
          NyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NyTextField(
                  label: AppStrings.fullName,
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                // Department
                Text(AppStrings.department, style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedDept,
                  decoration: const InputDecoration(),
                  style: AppTextStyles.bodyMedium,
                  items: [AppStrings.generalNoDepartment]
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _selectedDept = v ?? _selectedDept;
                    _deptCode = 'GEN';
                  }),
                ),

                const SizedBox(height: 16),

                NyTextField(
                  label: AppStrings.position,
                  controller: _positionCtrl,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                // Passport photo
                NyButton(
                  label: AppStrings.passportPhoto,
                  icon: const Icon(Icons.upload_rounded,
                      size: 16, color: AppColors.textPrimary),
                  onPressed: () {/* TODO: image picker */},
                  variant: NyButtonVariant.outlined,
                  height: 44,
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: NyTextField(
                        label: AppStrings.phone,
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NyTextField(
                        label: AppStrings.email,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: NyTextField(
                        label: AppStrings.employeeNo,
                        controller: _empNoCtrl,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NyTextField(
                        label: AppStrings.branch,
                        controller: _branchCtrl,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Date pickers
                Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: AppStrings.dateOfBirth,
                        value: _dob,
                        onTap: () => _pickDate(context,
                            onPicked: (d) => setState(() => _dob = d)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateField(
                        label: AppStrings.dateEmployed,
                        value: _dateEmployed,
                        onTap: () => _pickDate(context,
                            onPicked: (d) => setState(() => _dateEmployed = d)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _DateField(
                  label: AppStrings.cardValidUntil,
                  value: _cardValidUntil,
                  onTap: () => _pickDate(context,
                      onPicked: (d) => setState(() => _cardValidUntil = d)),
                ),

                const SizedBox(height: 20),

                NyButton(
                  label: AppStrings.registerStaffIssueCode,
                  onPressed: _register,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Staff list ────────────────────────────────────────────────
          staffAsync.when(
            loading: () => const NyLoading(),
            error: (e, _) => NyEmptyState(message: 'Could not load staff: $e'),
            data: (list) => list.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    children: list
                        .map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: NyCard(
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.primaryLighter,
                                      child: Text(
                                        s.fullName.isNotEmpty
                                            ? s.fullName[0].toUpperCase()
                                            : '?',
                                        style: AppTextStyles.titleMedium
                                            .copyWith(color: AppColors.primary),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(s.fullName,
                                              style: AppTextStyles.titleMedium),
                                          Text(
                                              '${s.department} · ${s.position}',
                                              style: AppTextStyles.bodySmall),
                                        ],
                                      ),
                                    ),
                                    NyBadge(
                                      label: s.staffCode,
                                      variant: NyBadgeVariant.neutral,
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Date field widget ──────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.titleMedium),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null
                      ? DateFormat('dd/MM/yyyy').format(value!)
                      : 'dd/mm/yyyy',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: value != null
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
