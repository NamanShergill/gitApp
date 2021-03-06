import 'package:dio/dio.dart';
import 'package:dio_hub/app/Dio/cache.dart';
import 'package:dio_hub/app/Dio/dio.dart';
import 'package:dio_hub/graphql/graphql.dart';
import 'package:dio_hub/models/issues/issue_comments_model.dart';
import 'package:dio_hub/models/issues/issue_event_model.dart' hide Label;
import 'package:dio_hub/models/issues/issue_model.dart';
import 'package:dio_hub/models/users/user_info_model.dart';

class IssuesService {
  // Ref: https://docs.github.com/en/rest/reference/issues#get-an-issue
  static Future<IssueModel> getIssueInfo({required String fullUrl}) async {
    final response = await API
        .request(
            applyBaseURL: false,
            cacheOptions: CacheManager.defaultCache(),
            acceptHeader: 'application/vnd.github.VERSION.full+json')
        .get(fullUrl);
    return IssueModel.fromJson(response.data);
  }

  // Ref: https://docs.github.com/en/rest/reference/issues#get-an-issue-comment
  static Future<IssueCommentsModel> getLatestComment(
      {required String fullUrl}) async {
    final response = await API
        .request(applyBaseURL: false, cacheOptions: CacheManager.defaultCache())
        .get(fullUrl);
    return IssueCommentsModel.fromJson(response.data);
  }

  // // Ref: https://docs.github.com/en/rest/reference/issues#list-issue-comments
  // static Future<List<IssueCommentsModel>> getIssueComments(
  //     String issueURL, int page, int perPage, bool refresh,
  //     {String? since}) async {
  //   Response response = await GetDio.getDio(
  //           applyBaseURL: false,
  //           cacheOptions: CacheManager.defaultCache(refresh: refresh))
  //       .get(issueURL + '/comments', queryParameters: {
  //     'since': since,
  //     'page': page,
  //     'per_page': perPage
  //   });
  //   List unParsedComments = response.data;
  //   return unParsedComments.map((e) => IssueCommentsModel.fromJson(e)).toList();
  // }

  // Ref: https://docs.github.com/en/rest/reference/issues#list-issue-events
  static Future<List<IssueEventModel>> getIssueEvents(
      {required String fullUrl, String? since}) async {
    final response = await API
        .request(applyBaseURL: false, cacheOptions: CacheManager.defaultCache())
        .get('$fullUrl/events', queryParameters: {'since': since});
    final List unParsedEvents = response.data;
    final parsedEvents = <IssueEventModel>[];
    for (final event in unParsedEvents) {
      parsedEvents.add(IssueEventModel.fromJson(event));
    }
    return parsedEvents;
  }

  // Ref: https://docs.github.com/en/rest/reference/issues#list-issues-assigned-to-the-authenticated-user
  static Future<List<IssueModel>> getUserIssues({
    int? perPage,
    int? pageNumber,
    required bool refresh,
    bool? ascending = false,
    String? sort,
  }) async {
    final response = await API
        .request(cacheOptions: CacheManager.defaultCache(refresh: refresh))
        .get(
      '/issues',
      queryParameters: {
        'per_page': perPage,
        'page': pageNumber,
        if (sort != null) 'sort': sort,
        if (ascending != null) 'direction': ascending ? 'asc' : 'desc',
      },
    );
    final List unParsedData = response.data;
    final parsedData = unParsedData.map((e) => IssueModel.fromJson(e)).toList();
    return parsedData;
  }

  // Ref: https://docs.github.com/en/rest/reference/issues#list-repository-issues
  static Future<List<IssueModel>> getRepoIssues(
    String? repoURL, {
    int? perPage,
    int? pageNumber,
    String? sort,
    bool? ascending = false,
    required bool refresh,
  }) async {
    final response = await API
        .request(cacheOptions: CacheManager.defaultCache(refresh: refresh))
        .get(
      '$repoURL/issues',
      queryParameters: {
        'per_page': perPage,
        'page': pageNumber,
        if (sort != null) 'sort': sort,
        if (ascending != null) 'direction': ascending ? 'asc' : 'desc',
      },
    );
    final List unParsedData = response.data;
    final parsedData = unParsedData.map((e) => IssueModel.fromJson(e)).toList();
    return parsedData;
  }

  // Ref: https://docs.github.com/en/rest/reference/issues#list-timeline-events-for-an-issue
  static Future<List<dynamic>> getTimeline(
      {required String repo,
      required String owner,
      required int number,
      required bool refresh,
      String? after,
      DateTime? since}) async {
    final response = await API.gqlRequest(
        GetTimelineQuery(
            variables: GetTimelineArguments(
                after: after,
                owner: owner,
                number: number,
                repoName: repo,
                since: since)),
        cacheOptions: CacheManager.defaultGQLCache(refresh: refresh),
        acceptHeader: 'application/vnd.github.starfox-preview+json');
    return (GetTimeline$Query.fromJson(response.data!) as dynamic)
        .repository!
        .issueOrPullRequest
        .timelineItems
        .edges!;
  }

  // Ref: https://docs.github.com/en/rest/reference/issues#check-if-a-user-can-be-assigned
  static Future<bool> checkIfUserCanBeAssigned(
      String login, String repoURL) async {
    final response = await API
        .request(
            applyBaseURL: false,
            showPopup: false,
            cacheOptions: CacheManager.defaultCache())
        .get('$repoURL/assignees/$login',
            options: Options(validateStatus: (status) {
      return status! < 500;
    }));
    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  // Ref: https://docs.github.com/en/rest/reference/issues#list-assignees
  static Future<List<UserInfoModel>> listAssignees(
      String? repoURL, int page, int perPage) async {
    final response = await API
        .request(applyBaseURL: false, cacheOptions: CacheManager.defaultCache())
        .get('$repoURL/assignees', queryParameters: {
      'per_page': perPage,
      'page': page,
    });
    final List data = response.data;
    return data.map((e) => UserInfoModel.fromJson(e)).toList();
  }

  // Ref: https://docs.github.com/en/rest/reference/issues#add-assignees-to-an-issue
  static Future<IssueModel> addAssignees(
      String? issueURL, List<String?> users) async {
    final response = await API
        .request(applyBaseURL: false)
        .post('$issueURL/assignees', data: {'assignees': users});
    return IssueModel.fromJson(response.data);
  }

  // Ref: https://docs.github.com/en/rest/reference/issues#remove-assignees-from-an-issue
  static Future<IssueModel> removeAssignees(
      String? issueURL, List<String?> users) async {
    final response = await API
        .request(applyBaseURL: false)
        .delete('$issueURL/assignees', data: {'assignees': users});
    return IssueModel.fromJson(response.data);
  }

  // Ref: https://docs.github.com/en/rest/reference/issues#list-labels-for-an-issue
  static Future<List<Label>> listLabels(String issueURL) async {
    final response = await API
        .request(applyBaseURL: false, cacheOptions: CacheManager.defaultCache())
        .get('$issueURL/labels');
    final List data = response.data;
    return data.map((e) => Label.fromJson(e)).toList();
  }

  // Ref: https://docs.github.com/en/rest/reference/issues#list-labels-for-a-repository
  static Future<List<Label>> listAvailableLabels(
      String? repoURL, int page, int perPage) async {
    final response = await API
        .request(applyBaseURL: false, cacheOptions: CacheManager.defaultCache())
        .get('$repoURL/labels', queryParameters: {
      'per_page': perPage,
      'page': page,
    });
    final List data = response.data;
    return data.map((e) => Label.fromJson(e)).toList();
  }

  // Ref: https://docs.github.com/en/rest/reference/issues#set-labels-for-an-issue
  static Future<List<Label>> setLabels(
      String? issueURL, List<String?>? labels) async {
    final response = await API
        .request(applyBaseURL: false)
        .put('$issueURL/labels', data: {'labels': labels});
    final List data = response.data;
    return data.map((e) => Label.fromJson(e)).toList();
  }

  // Ref: https://docs.github.com/en/rest/reference/issues#update-an-issue
  static Future<IssueModel> updateIssue(String issueURL, Map data) async {
    final response = await API
        .request(
            applyBaseURL: false,
            acceptHeader: 'application/vnd.github.VERSION.full+json')
        .patch(issueURL, data: data);
    return IssueModel.fromJson(response.data);
  }

  // Ref: https://docs.github.com/en/rest/reference/issues#create-an-issue-comment
  static Future<bool> addComment(String issueURL, String body) async {
    final response = await API
        .request(applyBaseURL: false)
        .post('$issueURL/comments', data: {'body': body});
    if (response.statusCode == 201) {
      return true;
    }
    return false;
  }

  // // Ref: https://docs.github.com/en/rest/reference/issues#lock-an-issue
  // static Future<bool> lockIssue(String issueURL,)

  // Ref: https://docs.github.com/en/rest/reference/issues#create-an-issue
  static Future<IssueModel> createIssue(
      {required String title,
      required String body,
      required String owner,
      required String repo}) async {
    final res = await API.request().post('/repos/$owner/$repo/issues',
        data: {'title': title, if (body.isNotEmpty) 'body': body});
    return IssueModel.fromJson(res.data);
  }
}
