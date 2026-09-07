import 'package:flutter_dotenv/flutter_dotenv.dart';

String get googleMapApiKey =>
    dotenv.env['GOOGLE_MAPS_API_KEY'] ??
    'AIzaSyA2_J7HSn0DmOrrTzBN5FJVJ23CeeUtmN4';
