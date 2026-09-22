import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:property_listing/app/router/app_routes.dart';
import 'package:property_listing/core/utils/validators.dart';
import 'package:property_listing/features/interests/presentation/bloc/submit_interest_bloc.dart';
import 'package:property_listing/features/interests/presentation/bloc/submit_interest_event.dart';
import 'package:property_listing/features/interests/presentation/bloc/submit_interest_state.dart';

class SubmitInterestPage extends StatefulWidget {
  const SubmitInterestPage({required this.propertyId, super.key});

  final String propertyId;

  @override
  State<SubmitInterestPage> createState() => _SubmitInterestPageState();
}

class _SubmitInterestPageState extends State<SubmitInterestPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit interest')),
      body: SafeArea(
        child: BlocConsumer<SubmitInterestBloc, SubmitInterestState>(
          listenWhen:
              (SubmitInterestState previous, SubmitInterestState current) =>
                  previous.status != current.status &&
                  current.status == SubmitInterestStatus.success,
          listener: (BuildContext context, SubmitInterestState state) {
            _formKey.currentState?.reset();
            _fullNameController.clear();
            _mobileController.clear();
            _emailController.clear();
            _messageController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your interest has been submitted.'),
              ),
            );
          },
          builder: (BuildContext context, SubmitInterestState state) {
            if (state.status == SubmitInterestStatus.success) {
              return _SuccessView(
                propertyName: state.interest!.propertyName,
                onBackToProperty: context.pop,
                onBrowseProperties: () =>
                    context.goNamed(AppRoutes.userDashboardName),
                onSubmitAnother: () => context.read<SubmitInterestBloc>().add(
                  const SubmitInterestReset(),
                ),
              );
            }

            return _InterestForm(
              formKey: _formKey,
              propertyId: widget.propertyId,
              fullNameController: _fullNameController,
              mobileController: _mobileController,
              emailController: _emailController,
              messageController: _messageController,
              state: state,
              onSubmit: () => _submit(context),
            );
          },
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    context.read<SubmitInterestBloc>().add(
      SubmitInterestSubmitted(
        propertyId: widget.propertyId,
        fullName: _fullNameController.text,
        mobileNumber: _mobileController.text,
        email: _emailController.text,
        message: _messageController.text,
      ),
    );
  }
}

class _InterestForm extends StatelessWidget {
  const _InterestForm({
    required this.formKey,
    required this.propertyId,
    required this.fullNameController,
    required this.mobileController,
    required this.emailController,
    required this.messageController,
    required this.state,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final String propertyId;
  final TextEditingController fullNameController;
  final TextEditingController mobileController;
  final TextEditingController emailController;
  final TextEditingController messageController;
  final SubmitInterestState state;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final bool isSubmitting = state.status == SubmitInterestStatus.submitting;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(
                    Icons.mark_email_unread_outlined,
                    color: colors.primary,
                    size: 56,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Contact the property owner',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Property reference: $propertyId',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    key: const Key('interest_full_name_field'),
                    controller: fullNameController,
                    autofillHints: const <String>[AutofillHints.name],
                    enabled: !isSubmitting,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: Validators.fullName,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('interest_mobile_field'),
                    controller: mobileController,
                    autofillHints: const <String>[
                      AutofillHints.telephoneNumber,
                    ],
                    enabled: !isSubmitting,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Mobile number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: Validators.mobile,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('interest_email_field'),
                    controller: emailController,
                    autofillHints: const <String>[AutofillHints.email],
                    enabled: !isSubmitting,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('interest_message_field'),
                    controller: messageController,
                    enabled: !isSubmitting,
                    keyboardType: TextInputType.multiline,
                    minLines: 4,
                    maxLines: 7,
                    maxLength: 500,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      alignLabelWithHint: true,
                      labelText: 'Message',
                      hintText: 'Tell the owner what you would like to know.',
                      prefixIcon: Icon(Icons.chat_bubble_outline),
                    ),
                    validator: Validators.interestMessage,
                  ),
                  if (state.status == SubmitInterestStatus.failure) ...<Widget>[
                    const SizedBox(height: 4),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        state.errorMessage ?? 'Unable to submit interest.',
                        key: const Key('interest_error'),
                        style: TextStyle(color: colors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    key: const Key('interest_submit_button'),
                    onPressed: isSubmitting ? null : onSubmit,
                    icon: isSubmitting
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        isSubmitting ? 'Submitting…' : 'Submit interest',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({
    required this.propertyName,
    required this.onBackToProperty,
    required this.onBrowseProperties,
    required this.onSubmitAnother,
  });

  final String propertyName;
  final VoidCallback onBackToProperty;
  final VoidCallback onBrowseProperties;
  final VoidCallback onSubmitAnother;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(Icons.check_circle_outline, color: colors.primary, size: 72),
              const SizedBox(height: 16),
              Text(
                'Interest submitted',
                key: const Key('interest_success_title'),
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your enquiry for $propertyName was saved. The owner can now '
                'review your contact details and message.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('interest_back_button'),
                onPressed: onBackToProperty,
                child: const Text('Back to property'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: onBrowseProperties,
                child: const Text('Browse properties'),
              ),
              TextButton(
                onPressed: onSubmitAnother,
                child: const Text('Submit another enquiry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
