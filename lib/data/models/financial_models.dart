import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

class FinanceTransaction {
  const FinanceTransaction({required this.id, required this.userId, required this.type, required this.amount, required this.categoryId, required this.description, required this.date, required this.paymentMode, this.receiptImageUrl, this.source, this.syncStatus = 'synced'});
  final String id, userId, categoryId, description, paymentMode, syncStatus;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String? receiptImageUrl, source;
  factory FinanceTransaction.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) { final v = d.data()!; return FinanceTransaction(id: d.id, userId: v['userId'] ?? '', type: v['type'] == 'income' ? TransactionType.income : TransactionType.expense, amount: (v['amount'] ?? 0).toDouble(), categoryId: v['categoryId'] ?? 'Miscellaneous', description: v['description'] ?? '', date: (v['date'] as Timestamp?)?.toDate() ?? DateTime.now(), paymentMode: v['paymentMode'] ?? 'Cash', receiptImageUrl: v['receiptImageUrl'], source: v['source'], syncStatus: v['syncStatus'] ?? 'synced'); }
  Map<String, dynamic> toMap() => {'userId': userId, 'type': type.name, 'amount': amount, 'categoryId': categoryId, 'description': description, 'date': Timestamp.fromDate(date), 'paymentMode': paymentMode, 'receiptImageUrl': receiptImageUrl, 'source': source, 'syncStatus': syncStatus, 'updatedAt': FieldValue.serverTimestamp()};
}

class Budget { const Budget({required this.id, required this.userId, required this.month, required this.limitAmount, this.categoryLimits = const {}, this.alertThreshold = .8}); final String id,userId,month; final double limitAmount,alertThreshold; final Map<String,double> categoryLimits; factory Budget.fromDoc(DocumentSnapshot<Map<String,dynamic>> d) { final v=d.data()!; return Budget(id:d.id,userId:v['userId'],month:v['month'],limitAmount:(v['limitAmount']??0).toDouble(),alertThreshold:(v['alertThreshold']??.8).toDouble(),categoryLimits: (v['categoryLimits'] as Map? ?? {}).map((k,x)=>MapEntry('$k',(x as num).toDouble()))); } Map<String,dynamic> toMap()=>{'userId':userId,'month':month,'limitAmount':limitAmount,'categoryLimits':categoryLimits,'alertThreshold':alertThreshold,'updatedAt':FieldValue.serverTimestamp()}; }

class SavingsGoal { const SavingsGoal({required this.id,required this.userId,required this.goalName,required this.targetAmount,required this.currentAmount,required this.targetDate,required this.monthlyContribution,required this.status}); final String id,userId,goalName,status; final double targetAmount,currentAmount,monthlyContribution; final DateTime targetDate; double get progress => targetAmount == 0 ? 0 : (currentAmount / targetAmount).clamp(0,1); factory SavingsGoal.fromDoc(DocumentSnapshot<Map<String,dynamic>> d){final v=d.data()!;return SavingsGoal(id:d.id,userId:v['userId'],goalName:v['goalName'],targetAmount:(v['targetAmount']??0).toDouble(),currentAmount:(v['currentAmount']??0).toDouble(),targetDate:(v['targetDate'] as Timestamp?)?.toDate()??DateTime.now(),monthlyContribution:(v['monthlyContribution']??0).toDouble(),status:v['status']??'active');} Map<String,dynamic> toMap()=>{'userId':userId,'goalName':goalName,'targetAmount':targetAmount,'currentAmount':currentAmount,'targetDate':Timestamp.fromDate(targetDate),'monthlyContribution':monthlyContribution,'status':status,'updatedAt':FieldValue.serverTimestamp()}; }
