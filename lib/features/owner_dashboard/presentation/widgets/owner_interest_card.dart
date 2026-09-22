import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:property_listing/features/interests/domain/entities/interest_status.dart';
import 'package:property_listing/features/interests/domain/entities/property_interest.dart';

class OwnerInterestCard extends StatelessWidget {
  const OwnerInterestCard({
    required this.interest,
    required this.onStatusChanged,
    super.key,
  });

  static final DateFormat _dateFormat = DateFormat.yMMMd().add_jm();

  final PropertyInterest interest;
  final ValueChanged<InterestStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: colors.secondaryContainer,
                  child: Icon(
                    Icons.person_outline,
                    color: colors.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        interest.fullName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        interest.propertyName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _dateFormat.format(interest.createdAt.toLocal()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: <Widget>[
                _ContactItem(
                  icon: Icons.phone_outlined,
                  value: interest.mobileNumber,
                ),
                _ContactItem(icon: Icons.email_outlined, value: interest.email),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<InterestStatus>(
              initialValue: interest.status,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Enquiry status',
                isDense: true,
              ),
              items: InterestStatus.values
                  .map(
                    (InterestStatus status) =>
                        DropdownMenuItem<InterestStatus>(
                          value: status,
                          child: Text(status.label),
                        ),
                  )
                  .toList(growable: false),
              onChanged: (InterestStatus? status) {
                if (status != null && status != interest.status) {
                  onStatusChanged(status);
                }
              },
            ),
            const SizedBox(height: 14),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(interest.message),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  const _ContactItem({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 17),
        const SizedBox(width: 5),
        Text(value),
      ],
    );
  }
}
