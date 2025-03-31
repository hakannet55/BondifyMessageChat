enum UrlTypes { login, register, message, chatList }
class Conf{
  static String baseUrl = "https://node-js-backend-chat-api.vercel.app/";

  //function url +base + url
  String url(UrlTypes url){
    return baseUrl+url.name;
  }

}