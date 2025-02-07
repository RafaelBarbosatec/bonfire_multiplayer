import 'package:http/http.dart' as http;

class NtpRepository {
  final String address;

  NtpRepository({required this.address});

  Future<DateTime> getNtpTime() async {
    final ntpTime = await http.get(Uri.parse('$address/ntp'));
    return DateTime.fromMicrosecondsSinceEpoch(int.parse(ntpTime.body));
  }
}
