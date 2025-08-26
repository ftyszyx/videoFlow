import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:videoflow/utils/logger.dart';

class BaseControl extends GetxController {
  var pageloadding = false.obs;


  void handlerError(Object exception,{bool showPageError=false}){
     logger.e("err",error: exception);
     if(showPageError){
      SmartDialog.showToast(exception.toString());
     }
  }

}
