import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:property_listing/core/utils/validators.dart';
import 'package:property_listing/core/widgets/app_error_view.dart';
import 'package:property_listing/core/widgets/app_loading_view.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/entities/property_enums.dart';
import 'package:property_listing/features/properties/domain/entities/property_input.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_form_bloc.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_form_event.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_form_state.dart';
import 'package:property_listing/features/properties/presentation/utils/property_labels.dart';

class PropertyFormPage extends StatefulWidget {
  const PropertyFormPage({this.propertyId, super.key});

  final String? propertyId;

  @override
  State<PropertyFormPage> createState() => _PropertyFormPageState();
}

class _PropertyFormPageState extends State<PropertyFormPage> {
  static const List<String> _imageOptions = <String>[
    'assets/images/property_placeholder.png',
    'assets/images/property_apartment.png',
    'assets/images/property_villa.png',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  PropertyType _type = PropertyType.apartment;
  PropertyStatus _status = PropertyStatus.available;
  String _imageUrl = _imageOptions.first;
  bool _didPopulate = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.propertyId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit property' : 'Add property')),
      body: SafeArea(
        child: BlocConsumer<PropertyFormBloc, PropertyFormState>(
          listener: (BuildContext context, PropertyFormState state) {
            if (!_didPopulate && state.property != null) {
              _populate(state.property!);
            }
            if (state.status == PropertyFormStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEditing ? 'Property updated.' : 'Property added.',
                  ),
                ),
              );
              context.pop(true);
            }
          },
          builder: (BuildContext context, PropertyFormState state) {
            if (state.status == PropertyFormStatus.initial ||
                state.status == PropertyFormStatus.loading) {
              return const AppLoadingView(label: 'Loading property form…');
            }
            if (state.status == PropertyFormStatus.failure &&
                state.property == null &&
                isEditing) {
              return AppErrorView(
                message: state.errorMessage ?? 'Unable to load property.',
                onRetry: () => context.read<PropertyFormBloc>().add(
                  PropertyFormRequested(widget.propertyId),
                ),
              );
            }
            return _buildForm(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, PropertyFormState state) {
    final bool isSubmitting = state.status == PropertyFormStatus.submitting;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Property image',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(_imageUrl, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const <ButtonSegment<String>>[
                    ButtonSegment<String>(
                      value: 'assets/images/property_placeholder.png',
                      label: Text('Classic'),
                    ),
                    ButtonSegment<String>(
                      value: 'assets/images/property_apartment.png',
                      label: Text('Apartment'),
                    ),
                    ButtonSegment<String>(
                      value: 'assets/images/property_villa.png',
                      label: Text('Villa'),
                    ),
                  ],
                  selected: <String>{_imageUrl},
                  onSelectionChanged: isSubmitting
                      ? null
                      : (Set<String> value) => setState(() {
                          _imageUrl = value.first;
                        }),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  key: const Key('property_name_field'),
                  controller: _nameController,
                  enabled: !isSubmitting,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Property name'),
                  validator: (String? value) =>
                      Validators.required(value, fieldName: 'Property name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('property_location_field'),
                  controller: _locationController,
                  enabled: !isSubmitting,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (String? value) =>
                      Validators.required(value, fieldName: 'Location'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonFormField<PropertyType>(
                        initialValue: _type,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: PropertyType.values
                            .map(
                              (PropertyType type) =>
                                  DropdownMenuItem<PropertyType>(
                                    value: type,
                                    child: Text(
                                      type.label,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                            )
                            .toList(growable: false),
                        onChanged: isSubmitting
                            ? null
                            : (PropertyType? value) => setState(() {
                                _type = value!;
                              }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<PropertyStatus>(
                        initialValue: _status,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: PropertyStatus.values
                            .map(
                              (PropertyStatus status) =>
                                  DropdownMenuItem<PropertyStatus>(
                                    value: status,
                                    child: Text(
                                      status.label,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                            )
                            .toList(growable: false),
                        onChanged: isSubmitting
                            ? null
                            : (PropertyStatus? value) => setState(() {
                                _status = value!;
                              }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _NumberFields(
                  priceController: _priceController,
                  areaController: _areaController,
                  bedroomsController: _bedroomsController,
                  bathroomsController: _bathroomsController,
                  enabled: !isSubmitting,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('property_description_field'),
                  controller: _descriptionController,
                  enabled: !isSubmitting,
                  minLines: 4,
                  maxLines: 7,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                  validator: (String? value) {
                    final String? requiredMessage = Validators.required(
                      value,
                      fieldName: 'Description',
                    );
                    if (requiredMessage != null) {
                      return requiredMessage;
                    }
                    return value!.trim().length < 10
                        ? 'Description must contain at least 10 characters.'
                        : null;
                  },
                ),
                if (state.status == PropertyFormStatus.failure) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    state.errorMessage ?? 'Unable to save property.',
                    key: const Key('property_form_error'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  key: const Key('property_form_submit'),
                  onPressed: isSubmitting ? null : () => _submit(context),
                  icon: isSubmitting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(isSubmitting ? 'Saving…' : 'Save property'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _populate(Property property) {
    _didPopulate = true;
    _nameController.text = property.name;
    _locationController.text = property.location;
    _priceController.text = property.price.toStringAsFixed(0);
    _areaController.text = property.areaSqFt.toStringAsFixed(0);
    _bedroomsController.text = '${property.bedrooms}';
    _bathroomsController.text = '${property.bathrooms}';
    _descriptionController.text = property.description;
    _type = property.type;
    _status = property.status;
    _imageUrl = _imageOptions.contains(property.imageUrl)
        ? property.imageUrl
        : _imageOptions.first;
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    context.read<PropertyFormBloc>().add(
      PropertyFormSubmitted(
        propertyId: widget.propertyId,
        input: PropertyInput(
          name: _nameController.text,
          type: _type,
          location: _locationController.text,
          price: double.parse(_priceController.text),
          areaSqFt: double.parse(_areaController.text),
          bedrooms: int.parse(_bedroomsController.text),
          bathrooms: int.parse(_bathroomsController.text),
          status: _status,
          description: _descriptionController.text,
          imageUrl: _imageUrl,
        ),
      ),
    );
  }
}

class _NumberFields extends StatelessWidget {
  const _NumberFields({
    required this.priceController,
    required this.areaController,
    required this.bedroomsController,
    required this.bathroomsController,
    required this.enabled,
  });

  final TextEditingController priceController;
  final TextEditingController areaController;
  final TextEditingController bedroomsController;
  final TextEditingController bathroomsController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useRows = constraints.maxWidth >= 520;
        final List<Widget> fields = <Widget>[
          _numberField(
            key: 'property_price_field',
            controller: priceController,
            label: 'Price (INR)',
            integer: false,
          ),
          _numberField(
            key: 'property_area_field',
            controller: areaController,
            label: 'Area (sq ft)',
            integer: false,
          ),
          _numberField(
            key: 'property_bedrooms_field',
            controller: bedroomsController,
            label: 'Bedrooms',
            integer: true,
          ),
          _numberField(
            key: 'property_bathrooms_field',
            controller: bathroomsController,
            label: 'Bathrooms',
            integer: true,
          ),
        ];
        if (!useRows) {
          return Column(
            children:
                fields
                    .expand(
                      (Widget field) => <Widget>[
                        field,
                        const SizedBox(height: 16),
                      ],
                    )
                    .toList()
                  ..removeLast(),
          );
        }
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: fields[0]),
                const SizedBox(width: 12),
                Expanded(child: fields[1]),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(child: fields[2]),
                const SizedBox(width: 12),
                Expanded(child: fields[3]),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _numberField({
    required String key,
    required TextEditingController controller,
    required String label,
    required bool integer,
  }) {
    return TextFormField(
      key: Key(key),
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.numberWithOptions(decimal: !integer),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label),
      validator: (String? value) {
        final num? parsed = integer
            ? int.tryParse(value ?? '')
            : double.tryParse(value ?? '');
        return parsed == null || parsed <= 0
            ? '$label must be greater than zero.'
            : null;
      },
    );
  }
}
