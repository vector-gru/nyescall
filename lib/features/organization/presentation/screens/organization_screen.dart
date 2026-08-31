import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/presentation/widgets/widgets.dart';
import '../../data/models/organization_model.dart';
import '../providers/organization_provider.dart';

class OrganizationScreen extends ConsumerWidget {
  const OrganizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgAsync = ref.watch(organizationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
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
      body: orgAsync.when(
        loading: () => const NyLoading(),
        error: (e, _) => NyEmptyState(message: 'Error: $e'),
        data: (org) => _OrgBody(
          initialOrg: org ??
              OrganizationModel(
                id: '',
                ownerId: FirebaseAuth.instance.currentUser?.uid ?? '',
                type: 'Company / Business',
                name: '',
                code: '',
                phone: '',
                email: FirebaseAuth.instance.currentUser?.email ?? '',
              ),
        ),
      ),
    );
  }
}

class _OrgBody extends ConsumerStatefulWidget {
  const _OrgBody({required this.initialOrg});
  final OrganizationModel initialOrg;

  @override
  ConsumerState<_OrgBody> createState() => _OrgBodyState();
}

class _OrgBodyState extends ConsumerState<_OrgBody> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _hoursCtrl;
  late final TextEditingController _servicesCtrl;
  late String _orgType;

  // Department add fields
  final _deptNameCtrl = TextEditingController();
  final _deptCodeCtrl = TextEditingController();

  // Team member add fields
  final _memberEmailCtrl = TextEditingController();
  String _memberRole = AppConstants.roleAgent;

  late List<DepartmentModel> _departments;
  late List<TeamMemberModel> _teamMembers;

  static const _orgTypes = [
    'Company / Business',
    'Hospital / Clinic',
    'School / University',
    'NGO',
    'Government',
    'Other',
  ];

  static const _roles = [
    AppConstants.roleAdmin,
    AppConstants.roleManager,
    AppConstants.roleAgent,
  ];

  static const _suggestedDepts = [
    'Sales',
    'Customer Service',
    'Technical Support'
  ];

  @override
  void initState() {
    super.initState();
    final o = widget.initialOrg;
    _nameCtrl = TextEditingController(text: o.name);
    _codeCtrl = TextEditingController(text: o.code);
    _phoneCtrl = TextEditingController(text: o.phone);
    _emailCtrl = TextEditingController(text: o.email);
    _addressCtrl = TextEditingController(text: o.address);
    _hoursCtrl = TextEditingController(text: o.workingHours);
    _servicesCtrl = TextEditingController(text: o.servicesOffered);
    _orgType = o.type;
    _departments = List.from(o.departments);
    _teamMembers = List.from(o.teamMembers);
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _codeCtrl,
      _phoneCtrl,
      _emailCtrl,
      _addressCtrl,
      _hoursCtrl,
      _servicesCtrl,
      _deptNameCtrl,
      _deptCodeCtrl,
      _memberEmailCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final updated = widget.initialOrg.copyWith(
      type: _orgType,
      name: _nameCtrl.text.trim(),
      code: _codeCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      workingHours: _hoursCtrl.text.trim(),
      servicesOffered: _servicesCtrl.text.trim(),
      departments: _departments,
      teamMembers: _teamMembers,
    );
    await ref.read(saveOrgProvider.notifier).save(updated);
  }

  void _addDepartment(String name, String code) {
    if (name.isEmpty || code.isEmpty) return;
    setState(() {
      _departments.add(DepartmentModel(name: name, code: code.toUpperCase()));
    });
    _deptNameCtrl.clear();
    _deptCodeCtrl.clear();
  }

  void _addMember() {
    final email = _memberEmailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) return;
    setState(() {
      _teamMembers.add(TeamMemberModel(email: email, role: _memberRole));
    });
    _memberEmailCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(saveOrgProvider);
    final isSaving = saveState is SaveOrgLoading;

    ref.listen<SaveOrgState>(saveOrgProvider, (_, next) {
      if (next is SaveOrgSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(AppStrings.successSaved),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
        ref.read(saveOrgProvider.notifier).reset();
      } else if (next is SaveOrgError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
        ref.read(saveOrgProvider.notifier).reset();
      }
    });

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(AppStrings.institution, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 4),
          Text(AppStrings.institutionSubtitle, style: AppTextStyles.bodySmall),
          const SizedBox(height: 16),

          NyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Logo ───────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLighter,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.primary,
                            style: BorderStyle.solid,
                            width: 1.5),
                      ),
                      child: const Icon(Icons.business_rounded,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    NyButton(
                      label: AppStrings.uploadLogo,
                      icon: const Icon(Icons.upload_rounded,
                          size: 16, color: AppColors.textPrimary),
                      onPressed: () {/* TODO: image picker */},
                      variant: NyButtonVariant.outlined,
                      height: 40,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Org type ────────────────────────────────────────────
                Text(AppStrings.organisationType,
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _orgType,
                  decoration: const InputDecoration(),
                  style: AppTextStyles.bodyMedium,
                  items: _orgTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _orgType = v ?? _orgType),
                ),

                const SizedBox(height: 16),

                NyTextField(
                  label: AppStrings.institutionName,
                  hint: 'Nyescall Center',
                  controller: _nameCtrl,
                  validator: (v) => Validators.required(v, 'Institution name'),
                ),

                const SizedBox(height: 16),

                NyTextField(
                  label: AppStrings.institutionCode,
                  hint: 'NC',
                  controller: _codeCtrl,
                  validator: (v) => Validators.required(v, 'Institution code'),
                ),
                Text(AppStrings.institutionCodeHint,
                    style: AppTextStyles.bodySmall),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: NyTextField(
                        label: AppStrings.phone,
                        hint: '+237678509520',
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NyTextField(
                        label: AppStrings.email,
                        hint: AppStrings.emailHint,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                NyTextField(
                  label: AppStrings.address,
                  controller: _addressCtrl,
                ),

                const SizedBox(height: 16),

                NyTextField(
                  label: AppStrings.workingHours,
                  hint: AppStrings.workingHoursHint,
                  controller: _hoursCtrl,
                ),

                const SizedBox(height: 16),

                NyTextField(
                  label: AppStrings.servicesOffered,
                  hint: AppStrings.servicesOfferedHint,
                  controller: _servicesCtrl,
                  maxLines: 3,
                ),

                const SizedBox(height: 20),

                NyButton(
                  label: AppStrings.saveChanges,
                  onPressed: _save,
                  isLoading: isSaving,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Departments ─────────────────────────────────────────────
          NyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.departments,
                    style: AppTextStyles.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  _departments.isEmpty
                      ? AppStrings.noDepartmentsYet
                      : '${_departments.length} department(s)',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 12),

                // Suggestion chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _suggestedDepts
                      .map((d) => ActionChip(
                            label: Text('+ $d'),
                            onPressed: () => _addDepartment(
                                d, d.substring(0, 2).toUpperCase()),
                          ))
                      .toList(),
                ),

                const SizedBox(height: 12),

                // Add dept row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _deptNameCtrl,
                        decoration: const InputDecoration(
                            hintText: AppStrings.departmentName),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _deptCodeCtrl,
                        decoration: const InputDecoration(hintText: 'CODE'),
                        style: AppTextStyles.bodyMedium,
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _addDepartment(
                          _deptNameCtrl.text, _deptCodeCtrl.text),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                if (_departments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ..._departments.map((d) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.business_center_outlined,
                            color: AppColors.primary),
                        title: Text(d.name, style: AppTextStyles.bodyMedium),
                        trailing:
                            Text(d.code, style: AppTextStyles.labelMedium),
                        dense: true,
                      )),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Team & roles ────────────────────────────────────────────
          NyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.teamAndRoles,
                    style: AppTextStyles.headlineSmall),
                const SizedBox(height: 4),
                Text(AppStrings.teamAndRolesDesc,
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: 16),

                // Owner row
                _MemberRow(
                  email: FirebaseAuth.instance.currentUser?.email ?? '',
                  displayName: FirebaseAuth.instance.currentUser?.displayName,
                  role: 'OWNER',
                  subtitle: 'Organization admin',
                  isOwner: true,
                ),

                const Divider(height: 24),

                Text(AppStrings.addATeamMember,
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _memberEmailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      hintText: AppStrings.teammateEmailHint),
                  style: AppTextStyles.bodyMedium,
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: _memberRole,
                  decoration: const InputDecoration(),
                  style: AppTextStyles.bodyMedium,
                  items: _roles
                      .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(
                              '${r[0].toUpperCase()}${r.substring(1)} / Staff')))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _memberRole = v ?? _memberRole),
                ),

                const SizedBox(height: 6),
                Text('View-only access to permitted organization data.',
                    style: AppTextStyles.bodySmall),

                const SizedBox(height: 14),

                NyButton(
                  label: AppStrings.addMember,
                  icon: const Icon(Icons.person_add_rounded,
                      color: Colors.white, size: 18),
                  onPressed: _addMember,
                  height: 44,
                ),

                if (_teamMembers.isNotEmpty) ...[
                  const Divider(height: 24),
                  ..._teamMembers.map((m) => _MemberRow(
                        email: m.email,
                        role: m.role.toUpperCase(),
                        subtitle:
                            '${m.role[0].toUpperCase()}${m.role.substring(1)}',
                      )),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.email,
    required this.role,
    required this.subtitle,
    this.displayName,
    this.isOwner = false,
  });

  final String email;
  final String? displayName;
  final String role;
  final String subtitle;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(displayName ?? email, style: AppTextStyles.titleMedium),
                  const SizedBox(width: 8),
                  NyBadge(
                    label: role,
                    variant: isOwner
                        ? NyBadgeVariant.success
                        : NyBadgeVariant.neutral,
                  ),
                ],
              ),
              if (displayName != null)
                Text(email, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        Text(subtitle, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
