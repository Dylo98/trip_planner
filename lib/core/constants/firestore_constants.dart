/// Stałe dla Firestore - nazwy kolekcji, pól i wartości
class FirestoreCollections {
  static const String users = 'users';
  static const String trips = 'trips';
  static const String sharedTrips = 'shared_trips';
  static const String dayPlans = 'dayPlans';
  static const String friends = 'friends';
  static const String friendRequests = 'friend_requests';
  static const String markers = 'markers';
  static const String expenses = 'expenses';
  static const String generalExpenses = 'general_expenses';
}

class FirestoreFields {
  // User fields
  static const String email = 'email';
  static const String name = 'name';
  static const String avatar = 'avatar';
  static const String uid = 'uid';

  // Trip fields
  static const String tripPhotoUrl = 'tripPhotoUrl';
  static const String startDate = 'startDate';
  static const String endDate = 'endDate';
  static const String ownerId = 'ownerId';
  static const String tripType = 'tripType';

  // Status fields
  static const String status = 'status';

  // Marker fields
  static const String description = 'description';
  static const String transportMode = 'transportMode';
  static const String markerExpenses = 'expenses';

  // Friend request fields
  static const String senderId = 'senderId';
  static const String receiverId = 'receiverId';
  static const String createdAt = 'createdAt';
}

class FirestoreValues {
  // Friend request statuses
  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String rejected = 'rejected';

  // Trip types
  static const String planned = 'planned';
  static const String ongoing = 'ongoing';
  static const String past = 'past';
}
