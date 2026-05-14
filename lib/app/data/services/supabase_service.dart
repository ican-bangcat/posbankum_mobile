import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebSupabaseService {
  static final SupabaseClient client = SupabaseClient(
    dotenv.env['WEB_SUPABASE_URL']!,
    dotenv.env['WEB_SUPABASE_KEY']!,
  );
}