import './globals.dart' as globals;

class AppConfig {
//  static var apiHost = globals.url;
//  static const apiHost = "ws://333ad25e2291.ngrok.io/websocket";
  static const debugMode = true;

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
  static const invoiceGet = 'store_invoice.get';
  static const notificationsList = 'store_notification.list';
  static const notificationSetUnread = 'store_notification.setUnread';
}