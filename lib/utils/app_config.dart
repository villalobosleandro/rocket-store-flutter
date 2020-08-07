class AppConfig {
  static const apiHost = "ws://192.168.0.109:200/websocket";
//  static const apiHost = "ws://fabackend.dev05.codecraftdev.com/websocket";

}

class ApiRoutes {
  static const login = 'user.login';
  static const productsList = 'store_product.listMenu';
  static const storeCampaign = 'store_campaign.getActive';
  static const listCategories = 'store_category.list';
  static const listQuestions = 'store_productQuestion.list';
}