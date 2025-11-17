import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modelos/veiculos.dart';
import '../modelos/abastecimento.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Future<void> addVeiculo(Veiculo v) async {
    await _db
        .collection("users")
        .doc(uid)
        .collection("veiculos")
        .add(v.toMap());
  }

  Future<List<Veiculo>> getVeiculos() async {
    final snap =
        await _db.collection("users").doc(uid).collection("veiculos").get();

    return snap.docs.map((d) => Veiculo.fromMap(d.id, d.data())).toList();
  }

  Future<void> updateVeiculo(Veiculo v) async {
    await _db
        .collection("users")
        .doc(uid)
        .collection("veiculos")
        .doc(v.id)
        .update(v.toMap());
  }

  Future<void> deleteVeiculo(String id) async {
    await _db
        .collection("users")
        .doc(uid)
        .collection("veiculos")
        .doc(id)
        .delete();
  }

  Future<void> addAbastecimento(Abastecimento a) async {
    await _db
        .collection("users")
        .doc(uid)
        .collection("abastecimentos")
        .add(a.toMap());
  }

  Future<List<Abastecimento>> getAbastecimentos() async {
    final snap = await _db
        .collection("users")
        .doc(uid)
        .collection("abastecimentos")
        .orderBy("data", descending: true)
        .get();

    return snap.docs.map((doc) => Abastecimento.fromFirestore(doc)).toList();
  }

  Future<void> updateAbastecimento(Abastecimento a) async {
    await _db
        .collection("users")
        .doc(uid)
        .collection("abastecimentos")
        .doc(a.id)
        .update(a.toMap());
  }

  Future<void> deleteAbastecimento(String id) async {
    await _db
        .collection("users")
        .doc(uid)
        .collection("abastecimentos")
        .doc(id)
        .delete();
  }
}
