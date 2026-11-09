import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const EarthlinkApp());
}

class EarthlinkApp extends StatelessWidget {
  const EarthlinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Earthlink',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? data;

  Duration remaining = Duration.zero;

  Timer? timer;

  Future<void> loadData() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://ubapi.earthlink.iq/api/user/GetUserDataAr',
        ),
      );

      if (response.statusCode == 200) {
        data = jsonDecode(response.body);

        startCountdown(
          parseArabicDate(
            data!["accountExpirationDate"]["value"],
          ),
        );

        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  DateTime parseArabicDate(String dateString) {
    final cleanDate =
        dateString.split(' ').first;

    final parts = cleanDate.split('/');

    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  void startCountdown(DateTime expiry) {
    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        setState(() {
          remaining =
              expiry.difference(DateTime.now());

          if (remaining.isNegative) {
            remaining = Duration.zero;
          }
        });
      },
    );
  }

  Color getStatusColor() {
    if (data == null) {
      return Colors.grey;
    }

    int days = int.tryParse(
          data!["activeDaysLeft"]["value"]
              .toString(),
        ) ??
        0;

    if (days <= 2) {
      return Colors.red;
    }

    if (days <= 5) {
      return Colors.orange;
    }

    return Colors.green;
  }

  Widget infoCard(
      IconData icon,
      String title,
      String value) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(
          0xFFF5F7FA,
        ),
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "معلومات الاشتراك",
          ),
        ),
        body: data == null
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: loadData,
                child: ListView(
                  padding:
                      const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.all(24),
                      decoration:
                          BoxDecoration(
                        gradient:
                            LinearGradient(
                          colors: [
                            color,
                            color.withOpacity(
                                0.7),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(
                                24),
                      ),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 35,
                            child:
                                Icon(Icons.person),
                          ),
                          const SizedBox(
                              height: 12),
                          Text(
                            data!["fullName"]
                                    ["value"] ??
                                "",
                            style:
                                const TextStyle(
                              fontSize: 24,
                              color:
                                  Colors.white,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                              height: 6),
                          Text(
                            data!["accountName"]
                                    ["value"] ??
                                "",
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                            ),
                          ),
                          const SizedBox(
                              height: 10),
                          Chip(
                            backgroundColor:
                                Colors.white,
                            label: Text(
                              data!["accountStatus"]
                                      ["value"] ??
                                  "",
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(
                        height: 24),

                    Center(
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration:
                            BoxDecoration(
                          color: color
                              .withOpacity(
                                  .15),
                          shape:
                              BoxShape.circle,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              Text(
                                data![
                                    "activeDaysLeft"]["value"],
                                style:
                                    TextStyle(
                                  fontSize:
                                      48,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  color:
                                      color,
                                ),
                              ),
                              const Text(
                                  "يوم متبقي")
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 24),

                    const Center(
                      child: Text(
                        "العداد التنازلي",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 12),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceEvenly,
                      children: [
                        timeBox(
                            remaining.inDays
                                .toString(),
                            "يوم"),

                        timeBox(
                            (remaining.inHours %
                                    24)
                                .toString(),
                            "ساعة"),

                        timeBox(
                            (remaining.inMinutes %
                                    60)
                                .toString(),
                            "دقيقة"),

                        timeBox(
                            (remaining.inSeconds %
                                    60)
                                .toString(),
                            "ثانية"),
                      ],
                    ),

                    const SizedBox(
                        height: 24),

                    infoCard(
                      Icons.person,
                      "اسم المستخدم",
                      data!["userID"]
                              ["value"] ??
                          "",
                    ),

                    infoCard(
                      Icons.router,
                      "عنوان IP",
                      data!["userIP"]
                              ["value"] ??
                          "",
                    ),

                    infoCard(
                      Icons.store,
                      "الوكيل",
                      data!["agentName"]
                              ["value"] ??
                          "",
                    ),

                    infoCard(
                      Icons.calendar_today,
                      "تاريخ الانتهاء",
                      data![
                                  "accountExpirationDate"]
                              ["value"] ??
                          "",
                    ),

                    infoCard(
                      Icons.attach_money,
                      "سعر الاشتراك",
                      data![
                                  "accountPrice"]
                              ["value"] ??
                          "",
                    ),

                    const SizedBox(
                        height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  Widget timeBox(
      String value,
      String title) {
    return Container(
      width: 75,
      padding:
          const EdgeInsets.symmetric(
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          Text(title)
        ],
      ),
    );
  }
}
