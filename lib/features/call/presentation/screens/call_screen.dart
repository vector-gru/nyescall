import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/presentation/widgets/widgets.dart';
import '../providers/call_provider.dart';

class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({super.key});

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  String _selectedLanguage = 'English';
  String _fullPhoneNumber = '';
  bool _phoneValid = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || !_phoneValid) {
      if (!_phoneValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter a valid phone number.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    await ref.read(placeCallProvider.notifier).placeCall(
          recipientName: _nameCtrl.text.trim(),
          phoneNumber: _fullPhoneNumber,
          language: _selectedLanguage,
          reason: _reasonCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(placeCallProvider);

    ref.listen<PlaceCallState>(placeCallProvider, (_, next) {
      if (next is PlaceCallError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(placeCallProvider.notifier).reset();
      } else if (next is PlaceCallSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI call placed successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _nameCtrl.clear();
        _reasonCtrl.clear();
        setState(() {
          _fullPhoneNumber = '';
          _phoneValid = false;
        });
        ref.read(placeCallProvider.notifier).reset();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: NyCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Recipient name ──────────────────────────────────────
                NyTextField(
                  label: AppStrings.recipientName,
                  hint: AppStrings.recipientNameHint,
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.required(v, 'Recipient name'),
                ),

                const SizedBox(height: 20),

                // ── Phone number ────────────────────────────────────────
                Text(AppStrings.phoneNumber, style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                IntlPhoneField(
                  initialCountryCode: 'CM',
                  decoration: const InputDecoration(
                    hintText: '6 70 00 00 00',
                  ),
                  style: AppTextStyles.bodyMedium,
                  onChanged: (phone) {
                    _fullPhoneNumber = phone.completeNumber;
                    try {
                      _phoneValid = phone.isValidNumber();
                    } catch (_) {
                      _phoneValid = false;
                    }
                  },
                  onCountryChanged: (_) {},
                ),

                const SizedBox(height: 20),

                // ── Language ────────────────────────────────────────────
                Text(AppStrings.language, style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  decoration: const InputDecoration(),
                  style: AppTextStyles.bodyMedium,
                  items: AppConstants.supportedLanguages
                      .map((lang) => DropdownMenuItem(
                            value: lang,
                            child: Text(lang),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedLanguage = v ?? 'English'),
                ),

                const SizedBox(height: 20),

                // ── Reason ──────────────────────────────────────────────
                NyTextField(
                  label: AppStrings.reasonForCall,
                  hint: AppStrings.reasonForCallHint,
                  controller: _reasonCtrl,
                  maxLines: 5,
                  maxLength: AppConstants.callReasonMaxLength,
                  showCounter: true,
                  validator: (v) =>
                      Validators.required(v, 'Reason for the call'),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                        AppConstants.callReasonMaxLength),
                  ],
                ),

                const SizedBox(height: 8),

                // ── GPT-4o: Suggest script ──────────────────────────────
                _ScriptSuggestionWidget(
                  recipientName: _nameCtrl,
                  language: _selectedLanguage,
                  onSuggested: (text) =>
                      setState(() => _reasonCtrl.text = text),
                ),

                const SizedBox(height: 24),

                // ── Submit ──────────────────────────────────────────────
                Consumer(
                  builder: (context, ref, _) {
                    final callState = ref.watch(placeCallProvider);
                    final loading = callState is PlaceCallLoading;
                    return NyButton(
                      label: loading ? callState.step : AppStrings.placeAiCall,
                      icon: const Icon(Icons.phone_rounded,
                          color: Colors.white, size: 18),
                      onPressed: _submit,
                      isLoading: loading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── GPT-4o script suggestion widget ────────────────────────────────────────

class _ScriptSuggestionWidget extends ConsumerWidget {
  const _ScriptSuggestionWidget({
    required this.recipientName,
    required this.language,
    required this.onSuggested,
  });

  final TextEditingController recipientName;
  final String language;
  final void Function(String) onSuggested;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scriptSuggestionProvider);

    ref.listen<ScriptSuggestionState>(scriptSuggestionProvider, (_, next) {
      if (next is ScriptReady) {
        onSuggested(next.text);
        ref.read(scriptSuggestionProvider.notifier).clear();
      }
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (state is ScriptLoading)
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        if (state is ScriptError)
          Expanded(
            child: Text(
              'AI suggest failed',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: state is ScriptLoading
              ? null
              : () {
                  final name = recipientName.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Enter a recipient name first.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  ref.read(scriptSuggestionProvider.notifier).suggest(
                        recipientName: name,
                        context: 'Generate a professional call reason',
                        language: language,
                      );
                },
          icon: const Icon(Icons.auto_awesome_rounded, size: 16),
          label: const Text('AI suggest'),
        ),
      ],
    );
  }
}
