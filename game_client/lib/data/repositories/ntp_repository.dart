import 'package:http/http.dart' as http;

class NtpRepository {
  final String address;

  NtpRepository({required this.address});

  Future<DateTime> getNtpTime() async {
    final ntpTime = await http.get(Uri.parse('http://$address:8080/ntp'));
    return DateTime.fromMicrosecondsSinceEpoch(int.parse(ntpTime.body));
  }
}
