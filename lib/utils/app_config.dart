class AppConfig {
  static const apiHost = "ws://192.168.0.181:200/websocket";
//  static const apiHost = "ws://ee699a207275.ngrok.io/websocket";

}

class ApiRoutes {
  static const login = 'user.login';
  static const productsList = 'store_product.listMenu';
  static const storeCampaign = 'store_campaign.getActive';
  static const listCategories = 'store_category.list';
  static const listQuestions = 'store_productQuestion.list';
  static const upSertRatingComment = 'store_product.upsertRatingOrComment';
  static const storeProductGet = 'store_product.get';
  static const storeRemoveComment = 'store_product.removeComment';
  static const storeProductQuestionInsert = 'store_productQuestion.insert';
  static const profileGet = 'profile.get';
  static const storeInsert = 'store_invoice.insert';
  static const listInvoicesByUserId = 'store_invoice.listByUserId';
}