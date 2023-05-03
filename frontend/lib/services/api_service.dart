import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/CardModel.dart';
import '../model/DiaryModel.dart';

class ApiService {
  static String baseUrl = dotenv.get('baseUrl');

  static Future<bool> login(String email, String password) async {
    print('loginstart');
    final url = Uri.parse('$baseUrl/member/login');
    final memberLoginRequestDto = {
      'email': email,
      'password': password,
    };
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(memberLoginRequestDto),
    );
    print('loginmiddle');
    if (response.statusCode == 200) {
      print('success');
      final prefs = await SharedPreferences.getInstance();
      final respJson = jsonDecode(utf8.decode(response.bodyBytes));
      print(respJson);
      final parsedTime =
          respJson['autoDiaryTime']?.split(':') ?? ["00", "00", "00"];
      final hour = int.parse(parsedTime[0] ?? '00');
      final minute = int.parse(parsedTime[1] ?? '00');
      final second = int.parse(parsedTime[2] ?? '00');
      await prefs.setInt('hour', hour);
      await prefs.setInt('minute', minute);
      await prefs.setInt('second', second);
      await prefs.setInt('memberId', respJson['memberId']);
      await prefs.setString('nickname', respJson['nickname']);
      await prefs.setString('diaryBaseName', respJson['diaryBaseName'] ?? '');
      print('end');
      return true;
    } else {
      print('failed');
      print(response.body);
      return false;
    }
  }

  static Future<bool> signup(
      String email, String nickname, String password) async {
    final url = Uri.parse('$baseUrl/member/signup');
    final memberSaveRequestDto = {
      'email': email,
      'nickname': nickname,
      'password': password,
    };
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(memberSaveRequestDto),
    );
    if (response.statusCode == 200) {
      print('success');
      return login(email, password);
    } else {
      print('failed');
      print(response.body);
      return false;
    }
  }

  static Future<String> getTranslation_papago(String content) async {
    String clientId = dotenv.get('papagoClientId');
    String clientSecret = dotenv.get('papagoClientSecret');
    String contentType = "application/x-www-form-urlencoded; charset=UTF-8";
    String url = "https://openapi.naver.com/v1/papago/n2mt";

    http.Response trans = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': contentType,
        'X-Naver-Client-Id': clientId,
        'X-Naver-Client-Secret': clientSecret
      },
      body: {
        'source': "en",
        'target': "ko",
        'text': content,
      },
    );
    if (trans.statusCode == 200) {
      var dataJson = jsonDecode(trans.body);
      print(dataJson);
      var resultPapago = dataJson['message']['result']['translatedText'];
      return resultPapago;
    } else {
      print(trans.statusCode);
      return content;
    }
  }

  static Future<List<String>> getCaption(File img) async {
    final apiKey = dotenv.get('visionApiKey');
    final url = Uri.parse(
        'https://vision.googleapis.com/v1/images:annotate?key=$apiKey');

    final requestBody = {
      "requests": [
        {
          "image": {
            "content": base64Encode(await img.readAsBytes()),
          },
          "features": [
            {
              "type": "LABEL_DETECTION",
              "maxResults": 3,
            }
          ],
        },
      ],
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      final responses = jsonResponse['responses'];
      final resp = responses[0];

      // final objectAnnotations = resp['localizedObjectAnnotations'];
      final objectAnnotations = resp['labelAnnotations'];
      print(objectAnnotations);
      List<String> objectNames = [];
      if (objectAnnotations == null) {
        return [];
      }
      for (var objectAnnotation in objectAnnotations) {
        // final ko = await getTranslation_papago(objectAnnotation['name']);
        final ko = await getTranslation_papago(objectAnnotation['description']);
        String trimmedKo =
            ko.endsWith('.') ? ko.substring(0, ko.length - 1) : ko;
        objectNames.add(trimmedKo);
      }

      print(objectNames);
      return objectNames;
    } else {
      return [];
    }
  }

  static Future<Map<String, dynamic>> makeCard(
      int memberId,
      String baseName,
      String basePlace,
      String keyword,
      double latitude,
      double longitude,
      File img) async {
    Map<String, dynamic> cardSaveRequestData = {
      "memberId": memberId,
      "baseName": baseName,
      "basePlace": basePlace,
      "keyword": keyword,
      "latitude": latitude,
      "longitude": longitude,
    };

    String cardSaveRequestDtoString = jsonEncode(cardSaveRequestData);

    final url = Uri.parse(
        '$baseUrl/card?cardSaveRequestDtoString=${Uri.encodeComponent(cardSaveRequestDtoString)}');
    final request = http.MultipartRequest('POST', url);

    request.files.add(
      await http.MultipartFile.fromPath(
        'origImageFile',
        img.path,
        filename: basename(img.path),
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final response = await request.send();
    // if (response.statusCode == 200) {
    print('success');
    final responseData = await response.stream.bytesToString();

    // print(responseData);
    final responseDto = jsonDecode(responseData);
    // print(responseDto['memberId']);
    Map<String, dynamic> card = responseDto;

    return card;
    // } else {
    //   print('fail');
    //   print(response.statusCode);
    // }
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  static Future<String> coordToRegion(Position pos) async {
    final url = Uri.parse(
        'https://dapi.kakao.com/v2/local/geo/coord2regioncode.json?x=${pos.longitude}&y=${pos.latitude}');
    final apiKey = dotenv.get('kakaoApiKey');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'KakaoAK $apiKey',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['documents'][0]['address_name'];
    } else {
      print(response.statusCode);
      print(response.body);
      return '';
    }
  }

  static Future<void> modifyUser(String newNickname, String hour, String minute,
      String second, String newDiaryBaseName) async {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('memberId');
    final url = Uri.parse('$baseUrl/member/$memberId');
    final autoDiaryTime = '$hour:$minute:$second';
    print(autoDiaryTime);
    print(newDiaryBaseName);
    final memberUpdateRequestDto = {
      "autoDiaryTime": autoDiaryTime,
      "diaryBaseName": newDiaryBaseName,
      "nickname": newNickname,
    };
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(memberUpdateRequestDto),
    );
    if (response.statusCode == 200) {
      print('success');
      prefs.setString('nickname', newNickname);
      prefs.setString('diaryBaseName', newDiaryBaseName);

      final parsedTime = autoDiaryTime.split(':');
      final hour = int.parse(parsedTime[0]);
      final minute = int.parse(parsedTime[1]);
      final second = int.parse(parsedTime[2]);
      prefs.setInt('hour', hour);
      prefs.setInt('minute', minute);
      prefs.setInt('second', second);

      print(response.body);
    } else {
      print('fail');
      print(response.statusCode);
      print(response.body);
    }
  }

  Future<List<CardModel>> getCardList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? memberId = prefs.getInt('memberId');

    final response = await http.get(Uri.parse('$baseUrl/card/$memberId'));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      List<CardModel> cards =
          jsonResponse.map((dynamic item) => CardModel.fromJson(item)).toList();

      return cards;
    } else {
      throw Exception('카드 리스트를 불러오는 데 실패했습니다');
    }
  }

  static bool isValidJson(String str) {
    int openBrackets = 0;
    int closeBrackets = 0;
    print(str.length);

    for (int i = 0; i < str.length; i++) {
      if (str[i] == '[') {
        print('open');
        print(i);
        openBrackets++;
      } else if (str[i] == ']') {
        closeBrackets++;
        print('close');
        print(i);
      }
    }

    return openBrackets == closeBrackets;
  }

  static Future<List<Map<String, String>>> makeDiaryContents(
      List<Map<String, String>> messages, String input) async {
    print('start');
    String apiKey = dotenv.get('gptApiKey');
    String apiUrl = 'https://api.openai.com/v1/chat/completions';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    if (messages.isEmpty) {
      messages.add({
        'role': 'system',
        'content':
            '재미있는 이야기를 써줘. 답변은 중괄호를 포함한 json 형식으로 json 외에 다른 문구는 덧붙이지 말아줘. 제목은 title에, 한줄 요약은 desc에, 내용은 contents에 넣어줘. 이야기를 한 장 당 1000자 정도의 3개의 장으로 구성해서 contents를 문자열 배열로 만들어줘.'
      });
    }
    messages.add({'role': 'user', 'content': input});

    Map<String, dynamic> body = {
      'model': 'gpt-3.5-turbo',
      'messages': messages,
      'max_tokens': 500,
      'n': 1,
      'stop': null,
      'temperature': 0.5,
    };

    http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse =
          jsonDecode(utf8.decode(response.bodyBytes));
      String answer = jsonResponse['choices'][0]['message']['content'].trim();
      messages.add({"role": "assistant", "content": answer});
      // print(answer);
      print('encode');
      // print(json.decode(answer)['contents']);
      // print(isValidJson(answer));
      print(answer.endsWith('}'));
      if (!answer.endsWith('}')) {
        print(answer);
        messages = await makeDiaryContents(messages,
            '끊어진 부분부터 이어서 답변해줘. 비슷한 내용을 반복하지 말고 되도록 지정한 json 형식대로 답변을 빨리 마무리해줘.');
        print('이어서 답변');
      }
      return messages;
    } else {
      throw Exception(
          'Failed to get response from GPT: ${response.statusCode}');
    }
  }

  static Future<String> continueGptConversation(String id) async {
    print('끊어짐');
    // Your API key and URL remain the same
    String apiKey = dotenv.get('gptApiKey');
    String apiUrl = 'https://api.openai.com/v1/chat/completions';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    Map<String, dynamic> body = {
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'user',
          'content': '정확히 끊어진 부분부터 이야기를 계속 해줘 계속 해야 할 답변의 id는 "$id"야.',
        },
      ],
      'max_tokens': 3921,
      'n': 1,
      'stop': null,
      'temperature': 0.5,
    };

    http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse =
          jsonDecode(utf8.decode(response.bodyBytes));
      String answer = jsonResponse['choices'][0]['message']['content'].trim();
      print(answer);
      return answer;
    } else {
      throw Exception(
          'Failed to get response from GPT: ${response.statusCode}');
    }
  }

  static Future<String> askGpt(var messages) async {
    print('gpt요청');
    // Replace with your GPT API key
    String apiKey = dotenv.get('gptApiKey');
    // Replace with the chat-based API endpoint
    String apiUrl = 'https://api.openai.com/v1/chat/completions';

    // Set up the headers for the request
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    // Set up the chat-based request payload
    Map<String, dynamic> body = {
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content':
              '재미있는 이야기를 써줘. 답변은 중괄호를 포함한 json 형식으로 json 외에 다른 문구는 덧붙이지 말아줘. 제목은 title에, 한줄 요약은 desc에, 내용은 contents에 넣어줘. 이야기를 한 장 당 1000자 정도의 3개의 장으로 구성해서 contents를 문자열 배열로 만들어줘. 최대한 길게 부탁해.'
        },
        {
          'role': 'user',
          'content': '주인공은 문성현이고 장소는 안드로메다이고 키워드는 커피, 운세, 라벨이야',
        },
      ],
      'max_tokens':
          2500, // Adjust to control the length of the generated response
      'n': 1, // Number of completions to generate
      'stop': null, // Set stopping sequence if needed
      'temperature':
          0.5, // Adjust to control the randomness of the generated response
    };

    // Make the HTTP POST request
    http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: json.encode(body),
    );

    // Check for a successful response
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse =
          jsonDecode(utf8.decode(response.bodyBytes));
      print(jsonResponse);
      String answer = jsonResponse['choices'][0]['message']['content'].trim();
      print(answer);
      print(answer.substring(answer.length - 1, answer.length - 1));
      print('이거위');
      print(answer.endsWith('}'));
      print(answer.endsWith(']'));
      if (!answer.endsWith('}')) {
        continueGptConversation(jsonResponse['id']);
      }
      return answer;
    } else {
      throw Exception(
          'Failed to get response from GPT: ${response.statusCode}');
    }
  }

  Future<List<DiaryModel>> getDiaries() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? memberId = prefs.getInt('memberId');

    final response = await http.get(Uri.parse('$baseUrl/diary/all/$memberId'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      List<DiaryModel> diaries = jsonResponse
          .map((dynamic item) => DiaryModel.fromJson(item))
          .toList();
      print('api: ${diaries.length}');
      return diaries;
    } else {
      throw Exception('일기 리스트 로딩에 실패했습니다');
    }
  }

  // Future<List<FriendModel>>
}
