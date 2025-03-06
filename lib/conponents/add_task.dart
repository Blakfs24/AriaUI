import 'package:aria_ui/funcs/services.dart';
import 'package:aria_ui/variables/setting_var.dart';
import 'package:clipboard/clipboard.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddTask{
  final SettingVar s=Get.put(SettingVar());
  TextEditingController controller=TextEditingController();
  TextEditingController dir=TextEditingController();
  TextEditingController userAgent=TextEditingController();
  int downloadLimit=0;

  bool validLink(String url){
    if(url.startsWith("http://") || url.startsWith("https://") || url.startsWith("magnet:?xt=urn:btih:")){
      return true;
    }
    return false;
  }

  void addHandler(BuildContext context, bool manual){
    if(!validLink(controller.text)){
      showDialog(
        context: context, 
        builder: (context)=>ContentDialog(
          title: const Text('添加失败'),
          content: const Text('任务链接不合法'),
          actions: [
            FilledButton(
              child: const Text("好的"), 
              onPressed: ()=>Navigator.pop(context)
            )
          ],
        )
      );
      return;
    }
    manual ? Services().addManualTask(controller.text, dir.text, userAgent.text, downloadLimit) : Services().addTask(controller.text);
    Navigator.pop(context);
  }

  void addTask(BuildContext context, dynamic setState){

    FocusNode node=FocusNode();

    FlutterClipboard.paste().then((value) {
      if(validLink(value)){
        setState((){
          controller.text=value;
        });
      }
    });
    bool manual=false;
    try {
      dir.text=s.settings['dir'];
    } catch (_) {}
    try {
      userAgent.text=s.settings['user-agent'];
    } catch (_) {}
    try {
      downloadLimit=int.parse(s.settings['max-overall-download-limit']);
    } catch (_) {}
    showDialog(
      context: context, 
      builder: (content)=>ContentDialog(
        title: Text('添加任务', style: GoogleFonts.notoSansSc(),),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {

            // ignore: use_build_context_synchronously
            Future.microtask(() => FocusScope.of(context).requestFocus(node));

            return KeyboardListener(
              focusNode: node,
              onKeyEvent: (event){
                if(event is KeyDownEvent && event.logicalKey==LogicalKeyboardKey.enter){
                  addHandler(context, manual);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 100,
                    child: TextBox(
                      maxLines: null,
                      controller: controller,
                      placeholder: 'http(s)://\nmagnet:',
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Checkbox(
                      checked: manual, 
                      onChanged: (val){
                        setState((){
                          manual=val??false;
                        });
                      },
                      content: Text('使用自定义配置', style: GoogleFonts.notoSansSc(),),
                    ),
                  ),
                  manual ? SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5,),
                        Text('下载地址', style: GoogleFonts.notoSansSc(),),
                        const SizedBox(height: 5,),
                        TextBox(
                          controller: dir,
                        ),
                        const SizedBox(height: 10,),
                        Text('用户代理', style: GoogleFonts.notoSansSc(),),
                        const SizedBox(height: 5,),
                        TextBox(
                          controller: userAgent,
                        ),
                        const SizedBox(height: 10,),
                        Text('下载速度限制', style: GoogleFonts.notoSansSc(),),
                        const SizedBox(height: 5,),
                        NumberBox(
                          value: downloadLimit,
                          mode: SpinButtonPlacementMode.inline,
                          onChanged: (val){
                            if(val!=null){
                              setState(() {
                                downloadLimit=val;
                              });
                            }
                          }
                        )
                      ],
                    ),
                  ) : Container()
                ],
              ),
            );
          }
        ),
        actions: [
          Button(
            child: Text('取消', style: GoogleFonts.notoSansSc(),), 
            onPressed: (){
              Navigator.pop(context);
            }
          ),
          FilledButton(
            child: Text('添加', style: GoogleFonts.notoSansSc(),), 
            onPressed: ()=>addHandler(context, manual)
          )
        ],
      )
    );
  }
}