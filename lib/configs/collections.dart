import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference get systemCollection {
  return FirebaseFirestore.instance.collection('system');
}

CollectionReference get usersCollection {
  return FirebaseFirestore.instance.collection('users');
}

CollectionReference proceduresCollection(String user) {
  return FirebaseFirestore.instance.collection('users/$user/procedures');
}
