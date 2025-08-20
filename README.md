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





