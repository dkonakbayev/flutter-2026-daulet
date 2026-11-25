enum TripStatus {
  upcoming('Upcoming'),
  ongoing('Ongoing'),
  past('Past');

  const TripStatus(this.label);

  final String label;
}
