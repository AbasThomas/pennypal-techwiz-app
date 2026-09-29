import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon.dart';
import '../../auth/providers/auth_providers.dart';
import 'admin_analytics_tab.dart';
import 'admin_learning_tab.dart';
import 'admin_students_tab.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});
  @override ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _tab = 0;
  static const _tabs = [('Dashboard', AppIcons.grid), ('Students', AppIcons.users), ('Learning', AppIcons.book), ('Support', AppIcons.support), ('Feedback', AppIcons.bulb), ('Analytics', AppIcons.chartBar), ('Settings', AppIcons.settings)];
  
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: PennyPalColors.black,
    appBar: AppBar(
      backgroundColor: PennyPalColors.black,
      title: const Text('PennyPal Admin', style: TextStyle(color: PennyPalColors.white, fontWeight: FontWeight.w800)),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const AppIcon(AppIcons.menu, color: PennyPalColors.white, size: 20),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          icon: const AppIcon(AppIcons.logout, color: PennyPalColors.white, size: 18)
        )
      ],
    ),
    drawer: Drawer(
      backgroundColor: PennyPalColors.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: PennyPalColors.surface),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/app-logo.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                const Text('PennyPal Admin', style: TextStyle(color: PennyPalColors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Dashboard Navigation', style: TextStyle(color: PennyPalColors.gray, fontSize: 12)),
              ],
            ),
          ),
          ...List.generate(_tabs.length, (i) => ListTile(
            leading: AppIcon(_tabs[i].$2, color: _tab == i ? PennyPalColors.white : PennyPalColors.gray, size: 20),
            title: Text(_tabs[i].$1, style: TextStyle(color: _tab == i ? PennyPalColors.white : PennyPalColors.gray, fontWeight: _tab == i ? FontWeight.w600 : FontWeight.normal)),
            selected: _tab == i,
            selectedTileColor: PennyPalColors.white.withOpacity(0.1),
            onTap: () {
              setState(() => _tab = i);
              Navigator.pop(context);
            },
          )),
        ],
      ),
    ),
    body: _page(),
  );
  Widget _page() => switch (_tab) {0 => const _Overview(), 1 => const AdminStudentsTab(), 2 => const AdminLearningTab(), 3 => const _Records('supportQueries', 'Support Queries', 'subject', 'status', statusable: true), 4 => const _Records('feedback', 'Feedback', 'type', 'comment'), 5 => const AdminAnalyticsTab(), _ => const _Settings()};
}

class _Overview extends StatelessWidget { const _Overview(); @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [const Text('Application overview', style: TextStyle(color: PennyPalColors.white, fontSize: 25, fontWeight: FontWeight.w800)), const SizedBox(height: 16), const Wrap(spacing: 12, runSpacing: 12, children: [_Count('Total Students', 'userProfiles'), _Count('Active Students', 'userProfiles'), _Count('Transactions', 'transactions'), _Count('Support Queries', 'supportQueries'), _Count('Feedback Received', 'feedback'), _Count('Learning Content', 'learningContent')]), const SizedBox(height: 28), const Text('Recent activity', style: TextStyle(color: PennyPalColors.white, fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 8), const Text('Monitor registrations, support and feedback below. Student financial records are only displayed as app-wide totals.', style: TextStyle(color: PennyPalColors.gray, height: 1.5))]); }
class _Count extends StatelessWidget { const _Count(this.label, this.collection); final String label, collection; @override Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream: FirebaseFirestore.instance.collection(collection).snapshots(), builder: (_, s) => Container(width: 160, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: PennyPalColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: PennyPalColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.hasData ? '${s.data!.size}' : '—', style: const TextStyle(color: PennyPalColors.white, fontSize: 25, fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(label, style: const TextStyle(color: PennyPalColors.gray, fontSize: 12))]))); }
class _Settings extends StatelessWidget { const _Settings(); @override Widget build(BuildContext context) => const Padding(padding: EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Admin settings',style:TextStyle(color:PennyPalColors.white,fontSize:25,fontWeight:FontWeight.w800)),SizedBox(height:14),Text('Administrators manage learning categories, notification preferences and access using Firebase. Only accounts with role = admin can open this dashboard.',style:TextStyle(color:PennyPalColors.gray,height:1.5))])); }
class _Records extends StatelessWidget { const _Records(this.collection,this.title,this.primary,this.secondary,{this.statusable=false}); final String collection,title,primary,secondary; final bool statusable; @override Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream:FirebaseFirestore.instance.collection(collection).snapshots(),builder:(_,s){if(s.hasError)return Center(child:Text('Could not load $title: ${s.error}',style:const TextStyle(color:PennyPalColors.gray)));if(!s.hasData)return const Center(child:CircularProgressIndicator());final docs=s.data!.docs;return ListView(padding:const EdgeInsets.all(20),children:[Text(title,style:const TextStyle(color:PennyPalColors.white,fontSize:25,fontWeight:FontWeight.w800)),const SizedBox(height:12),if(docs.isEmpty)const Text('No records yet.',style:TextStyle(color:PennyPalColors.gray)),for(final d in docs)Card(color:PennyPalColors.surface,child:ListTile(title:Text('${d.data()[primary]??'Untitled'}',style:const TextStyle(color:PennyPalColors.white)),subtitle:Text('${d.data()[secondary]??''}',style:const TextStyle(color:PennyPalColors.gray)),trailing:statusable?_statusMenu(d):null))]);});Widget _statusMenu(QueryDocumentSnapshot<Map<String,dynamic>> doc){final raw='${doc.data()['status']??'open'}'.toLowerCase();final status=['open','pending','resolved'].contains(raw)?raw:'open';return DropdownButton<String>(value:status,items:const[DropdownMenuItem(value:'open',child:Text('Open')),DropdownMenuItem(value:'pending',child:Text('Pending')),DropdownMenuItem(value:'resolved',child:Text('Resolved'))],onChanged:(v){if(v!=null)doc.reference.update({'status':v,'updatedAt':FieldValue.serverTimestamp()});});}}
