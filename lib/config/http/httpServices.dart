class HttpServices {
  HttpServices._();

  static const base = "demoapi.pickmeservices.com";
  // static const base = "api.pickmeservices.com ";
  static const subbase = "/api/v1";

  static const fullurl = "https://$base$subbase";

  static const auth = "/auth";
  static const noEndPoint = "";

  static const fileUpload = "/getimgurl";
}
