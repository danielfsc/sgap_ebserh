import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference systemCollection =
    FirebaseFirestore.instance.collection('system');

CollectionReference usersCollection =
    FirebaseFirestore.instance.collection('users');

CollectionReference proceduresCollection(String user) =>
    FirebaseFirestore.instance.collection('users/$user/procedures');
