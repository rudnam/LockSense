import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:locksense/pages/dashboard_page.dart';
import 'package:locksense/pages/info_page.dart';
import 'package:locksense/pages/notification_page.dart';
import 'package:locksense/services/auth_service.dart';
import 'package:locksense/services/firebase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FirebaseService firebaseService;
  var currentPageIndex = 0;
  User? user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> lockItems = [];
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    firebaseService = FirebaseService();

    if (user != null) {
      firebaseService.getLocks(user!.uid).then((locks) {
        setState(() {
          lockItems = locks;
        });
        for (var lock in locks) {
          addLockStateListener(lock['id']);
        }
      });

      firebaseService.addNotificationListener(user!.uid, (notifs) {
        if (mounted) {
          setState(() {
            notifications = notifs ?? [];
          });
        }
      });
    }
  }

  void addLockStateListener(String lockId) {
    firebaseService.addLockStatusListener(lockId, (lockStatus) {
      if (mounted) {
        setState(() {
          final lockItem = lockItems.firstWhere((lock) => lock['id'] == lockId,
              orElse: () => {});
          if (lockItem['status'] == 'unlocking' && lockStatus == 'locked') {
            _showSnackbar("Unlock attempt failed.");
          } else if (lockItem['status'] == 'locking' &&
              lockStatus == 'unlocked') {
            _showSnackbar("Lock attempt failed.");
          }
          lockItem['status'] = lockStatus;
        });
      }
    });
  }

  void _showSnackbar(String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void handleLockButtonClick(Map<String, dynamic> lockItem) async {
    String newStatus = lockItem['status'] == 'locked' ? 'unlocking' : 'locking';
    setState(() {
      lockItem['status'] = newStatus;
    });
    await firebaseService.writeData(
        "locks/${lockItem['id']}/status", newStatus);
  }

  void clearNotifications() async {
    await firebaseService.clearNotifications(user!.uid);
    setState(() {
      notifications = [];
    });
  }

  Future<void> addNewLock(String lockId, String lockName) async {
    bool lockExists = await firebaseService.checkIfExists("locks/$lockId");
    bool alreadyAdded =
        await firebaseService.checkIfExists("users/${user!.uid}/locks/$lockId");
    if (lockExists) {
      _showSnackbar("Could not add lock. Lock already existing.");
      return;
    } else if (alreadyAdded) {
      _showSnackbar("Could not add lock. Lock is already added.");
      return;
    } else if (lockName == '' || lockId == '') {
      _showSnackbar("Could not add lock. Please fill in all fields.");
    }

    Object newLock = {
      "id": lockId,
      "ownerId": user!.uid,
      "name": lockName,
      "status": "unlocked"
    };
    await firebaseService.writeData("locks/$lockId", newLock);
    await firebaseService
        .updateData("users/${user!.uid}/locks", {lockId: true});
    firebaseService.getLocks(user!.uid).then((locks) {
      setState(() {
        lockItems = locks;
      });
    });
    addLockStateListener(lockId);

    _showSnackbar("Successfully added lock.");
  }

  Future<void> addExistingLock(String lockId) async {
    bool lockExists = await firebaseService.checkIfExists("locks/$lockId");
    bool alreadyAdded =
        await firebaseService.checkIfExists("users/${user!.uid}/locks/$lockId");

    if (alreadyAdded) {
      _showSnackbar("Could not add lock. Lock is already added.");
    } else if (!lockExists) {
      _showSnackbar("Could not add lock. Lock does not exist.");
    } else if (lockId == '') {
      _showSnackbar("Could not add lock. Please fill in all fields.");
    } else {
      await firebaseService
          .updateData("users/${user!.uid}/locks", {lockId: true});
      await firebaseService
          .updateData("locks/$lockId/sharedUserIds", {user!.uid: true});

      firebaseService.getLocks(user!.uid).then((locks) {
        setState(() {
          lockItems = locks;
        });
      });
      addLockStateListener(lockId);

      _showSnackbar("Successfully added lock.");
    }
  }

  void handleAddLockButtonClick() {
    TextEditingController lockNameController = TextEditingController();
    TextEditingController lockIdController = TextEditingController();
    bool isNewLock = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Lock'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ToggleButtons(
                    isSelected: [!isNewLock, isNewLock],
                    onPressed: (int index) {
                      setState(() {
                        isNewLock = index == 1;
                      });
                    },
                    constraints: const BoxConstraints.expand(width: 120),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Existing'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('New'),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: lockIdController,
                    decoration: const InputDecoration(
                      labelText: 'Lock ID',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Visibility(
                    visible: isNewLock,
                    child: TextFormField(
                      controller: lockNameController,
                      decoration: const InputDecoration(
                        labelText: 'Lock Name',
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () async {
                    String lockName = lockNameController.text;
                    String lockId = lockIdController.text;
                    try {
                      if (lockId != '' && isNewLock) {
                        if (lockName != '') {
                          await addNewLock(lockId, lockName);
                        }
                      } else {
                        await addExistingLock(lockId);
                      }
                    } catch (err) {
                      _showSnackbar("Error adding lock: ${err.toString()}");
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void signUserOut() {
    AuthService().signOutWithGoogle();
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (currentPageIndex) {
      case 0:
        page = const InfoPage();
      case 1:
        page = DashboardPage(
            lockItems: lockItems, handleLockButtonClick: handleLockButtonClick);
      case 2:
        page = NotificationPage(
          notifications: notifications,
          clearNotifications: clearNotifications,
        );
      default:
        throw UnimplementedError('no widget for $currentPageIndex');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('LockSense'),
        actions: [
          IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: page,
      ),
      floatingActionButton: currentPageIndex == 1
          ? FloatingActionButton(
              onPressed: handleAddLockButtonClick,
              tooltip: 'Add Lock',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Theme.of(context).colorScheme.inversePrimary,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.dashboard),
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.notifications),
            icon: Icon(Icons.notifications_outlined),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}
