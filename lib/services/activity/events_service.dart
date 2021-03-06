import 'package:dio_hub/app/Dio/cache.dart';
import 'package:dio_hub/app/Dio/dio.dart';
import 'package:dio_hub/models/events/events_model.dart';

class EventsService {
  // Ref: https://docs.github.com/en/rest/reference/activity#list-events-for-the-authenticated-user
  static Future<List<EventsModel>> getUserEvents(String? user,
      {int? page, int? perPage, required bool refresh}) async {
    final response = await API
        .request(cacheOptions: CacheManager.defaultCache(refresh: refresh))
        .get('/users/$user/events',
            queryParameters: {'per_page': perPage, 'page': page});
    final List unParsedEvents = response.data;
    final parsedEvents = <EventsModel>[];
    for (final event in unParsedEvents) {
      parsedEvents.add(EventsModel.fromJson(event));
    }
    return parsedEvents;
  }

  // Ref: https://docs.github.com/en/rest/reference/activity#list-events-received-by-the-authenticated-user
  static Future<List<EventsModel>> getReceivedEvents(String? user,
      {bool refresh = false, int? perPage, int? page}) async {
    final parameters = <String, dynamic>{'per_page': perPage, 'page': page};
    final response = await API
        .request(cacheOptions: CacheManager.events(refresh: refresh))
        .get('/users/$user/received_events', queryParameters: parameters);
    final List unParsedEvents = response.data;
    final parsedEvents = <EventsModel>[];
    for (final event in unParsedEvents) {
      parsedEvents.add(EventsModel.fromJson(event));
    }

    return parsedEvents;
  }

  // Ref: https://docs.github.com/en/rest/reference/activity#list-public-events
  static Future<List<EventsModel>> getPublicEvents(
      {bool refresh = false, int? perPage, int? page}) async {
    final parameters = <String, dynamic>{'per_page': perPage, 'page': page};
    final response = await API
        .request(cacheOptions: CacheManager.events(refresh: refresh))
        .get(
          '/events',
          queryParameters: parameters,
        );
    final List unParsedEvents = response.data;
    final parsedEvents = <EventsModel>[];
    for (final event in unParsedEvents) {
      parsedEvents.add(EventsModel.fromJson(event));
    }
    return parsedEvents;
  }
}
