# video_flow
video flow


## some command

### add package

```
flutter pub add
flutter pub add --dev
```

### update package

```
flutter pub get -v
```

### run

```
flutter run -d windows
```

### generate typeadapter code
```
 flutter packages pub run build_runner build

```

## 功能描述

windows桌面程序
1.账号分页：
    账号字段有： 账号id,nickname,xiaodian_cookie,kuaishou_cookie

    功能：
        显示账号列表
        添加账号:
            添加账号逻辑：
            通过puppeteer打开浏览器，
            首先打开：https://login.kwaixiaodian.com/?biz=zone 让用户扫码登录，登录成功后， 保存xiaodian_cookie
            再打开：https://www.kuaishou.com/new-reco  点开登录按键 登录成功后，保存kuaishou_cookie,同时获取nickname和账号信息
        修改账号信息

1. 任务分页：
    任务字段有：任务id，名字，封面图片，原视频链接，标题，副标题
    1. 展示任务列表
    1. 新建任务
    1. 运行任务

GitHub: https://github.com/hm21/pro_image_editor
https://pub.dev/packages/flutter_painter_v2
1. 封面设计
https://www.gaoding.com/editor/design?mode=user&category_id=370&type=poster&width=1242&height=2208&unit=px&dpi=72&id=33610099700772948
1.全屏页面
1.分四列
    第一列是工具箱：文字，图片，背景
    第二列是，预选page
        点文字，显示几种大小的文字给用户选择，点击后，在封面中添加文字
        选图片，弹出图片选择框，选择后添加对应图片在封面中
        选背景，会展示几个默认的背景，选择后会修改封面中的背景
    第三列是封面效果预览，展示当前的封面效果
        同时用户可以选择封面中的元素，被选择的元素需要有选中效果
        同时如果元素是文字或者图片，可以拖去元素，旋转元素等
    第四列是元素属性
        当用户选择了封面中某个元素，可以在此修改元素的属性

任务流程：
1.根据分享url,获取视频真实地址，
2.下载视频
3.在封面上增加标题和副标题，并生成新的封面
1.修改视频封面
1.保存最终视频
1.打开快手小店，上传视频
1.发布




可选（自动化下载本地化）
新建目录 packages/，一条命令拉下来：
git clone https://github.com/hm21/pro_image_editor.git -b stable packages/pro_image_editor
pubspec.yaml 写：path: packages/pro_image_editor
这样就完成了本地路径集成，后续在 CoverStyleEditorPage 里直接用 package:pro_image_editor/pro_image_editor.dart 即可。