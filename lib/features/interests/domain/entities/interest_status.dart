enum InterestStatus {
  newRequest,
  contacted,
  interested,
  closed,
}

extension InterestStatusLabel on InterestStatus {
  String get label => switch (this) {
    InterestStatus.newRequest => 'New',
    InterestStatus.contacted => 'Contacted',
    InterestStatus.interested => 'Interested',
    InterestStatus.closed => 'Closed',
  };
}
