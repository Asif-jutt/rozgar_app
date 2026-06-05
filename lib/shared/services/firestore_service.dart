import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';

/// Service for Firestore database operations
/// Provides abstraction layer for CRUD operations and query execution
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a new document in the specified collection
  /// Returns the document ID of the newly created document
  Future<String> createDocument({
    required String collection,
    required Map<String, dynamic> data,
    String? docId,
  }) async {
    try {
      DocumentReference ref;
      if (docId != null) {
        ref = _firestore.collection(collection).doc(docId);
        await ref.set(data);
      } else {
        ref = await _firestore.collection(collection).add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      FirestoreReadCounter.increment();
      AppLogger.i('Document created in $collection: ${ref.id}');
      return ref.id;
    } catch (e, st) {
      AppLogger.e('Error creating document in $collection', st);
      rethrow;
    }
  }

  /// Reads a single document from the specified collection
  /// Returns the document data as a map
  Future<Map<String, dynamic>?> readDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      FirestoreReadCounter.increment();
      if (doc.exists) {
        AppLogger.i('Document read from $collection: $docId');
        return doc.data();
      }
      return null;
    } catch (e, st) {
      AppLogger.e('Error reading document from $collection', st);
      rethrow;
    }
  }

  /// Updates a document in the specified collection
  /// Only updates the fields provided in the data map
  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      FirestoreReadCounter.increment();
      AppLogger.i('Document updated in $collection: $docId');
    } catch (e, st) {
      AppLogger.e('Error updating document in $collection', st);
      rethrow;
    }
  }

  /// Deletes a document from the specified collection
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
      FirestoreReadCounter.increment();
      AppLogger.i('Document deleted from $collection: $docId');
    } catch (e, st) {
      AppLogger.e('Error deleting document from $collection', st);
      rethrow;
    }
  }

  /// Queries documents from the specified collection
  /// Supports filtering and ordering
  Future<List<Map<String, dynamic>>> queryDocuments({
    required String collection,
    QueryFilters? filters,
    List<OrderBy>? orderBy,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      // Apply filters
      if (filters != null) {
        query = filters.apply(query);
      }

      // Apply ordering
      if (orderBy != null) {
        for (final order in orderBy) {
          query = query.orderBy(order.field, descending: order.descending);
        }
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      FirestoreReadCounter.increment(snapshot.docs.length);

      AppLogger.i(
        'Query executed on $collection: ${snapshot.docs.length} results',
      );

      return snapshot.docs
          .map((doc) => {
                ...Map<String, dynamic>.from(doc.data() as Map),
                'id': doc.id,
              })
          .toList();
    } catch (e, st) {
      AppLogger.e('Error querying documents from $collection', st);
      rethrow;
    }
  }

  /// Subscribes to real-time updates for a document
  /// Returns a stream of document snapshots
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDocument({
    required String collection,
    required String docId,
  }) {
    AppLogger.i('Watching document in $collection: $docId');
    return _firestore.collection(collection).doc(docId).snapshots().handleError(
      (e, st) {
        AppLogger.e('Error watching document', st);
      },
    );
  }

  /// Subscribes to real-time updates for a collection query
  /// Returns a stream of query snapshots
  Stream<QuerySnapshot<Object?>> watchCollection({
    required String collection,
    QueryFilters? filters,
  }) {
    AppLogger.i('Watching collection: $collection');

    Query query = _firestore.collection(collection);
    if (filters != null) {
      query = filters.apply(query);
    }

    return query.snapshots().handleError((e, st) {
      AppLogger.e('Error watching collection', st);
    });
  }

  /// Performs a batch write operation
  /// Allows multiple writes in a single atomic operation
  Future<void> batchWrite(Future<void> Function(WriteBatch) operation) async {
    try {
      final batch = _firestore.batch();
      await operation(batch);
      await batch.commit();
      FirestoreReadCounter.increment();
      AppLogger.i('Batch write completed successfully');
    } catch (e, st) {
      AppLogger.e('Error executing batch write', st);
      rethrow;
    }
  }

  /// Executes a transaction
  /// Ensures atomicity of multiple operations
  Future<T> transaction<T>(
    Future<T> Function(Transaction) transactionHandler,
  ) async {
    try {
      final result = await _firestore.runTransaction(transactionHandler);
      FirestoreReadCounter.increment();
      AppLogger.i('Transaction completed successfully');
      return result;
    } catch (e, st) {
      AppLogger.e('Error executing transaction', st);
      rethrow;
    }
  }
}

/// Model for filtering documents in a query
class QueryFilters {
  final List<Filter> _filters = [];

  /// Adds an equality filter
  void addEquals(String field, dynamic value) {
    _filters.add(Filter(field, '==', value));
  }

  /// Adds a greater than filter
  void addGreaterThan(String field, dynamic value) {
    _filters.add(Filter(field, '>', value));
  }

  /// Adds a less than filter
  void addLessThan(String field, dynamic value) {
    _filters.add(Filter(field, '<', value));
  }

  /// Adds an array contains filter
  void addArrayContains(String field, dynamic value) {
    _filters.add(Filter(field, 'array-contains', value));
  }

  /// Applies all filters to a query
  Query apply(Query query) {
    for (final filter in _filters) {
      query = filter.apply(query);
    }
    return query;
  }
}

/// Single filter condition
class Filter {
  final String field;
  final String operator;
  final dynamic value;

  Filter(this.field, this.operator, this.value);

  Query apply(Query query) {
    switch (operator) {
      case '==':
        return query.where(field, isEqualTo: value);
      case '>':
        return query.where(field, isGreaterThan: value);
      case '<':
        return query.where(field, isLessThan: value);
      case 'array-contains':
        return query.where(field, arrayContains: value);
      default:
        return query;
    }
  }
}

/// Model for ordering query results
class OrderBy {
  final String field;
  final bool descending;

  OrderBy(this.field, {this.descending = false});
}
