# VSCode直接调试React Native iOS应用

## 1.（旧）调试

* 原来，调试React Native应用，你需要打开Chrome 开发者工具、Safari Developer Tools 或 React Developer Tools等第三方应用。然后在Webstorm等编辑器和调试工具之间来回切换。

## 2.（新）调试

* 现在，你仅需要一个VSCode就可以开发、调试React Native应用。

 ![vscode_debugging](https://github.com/cp110/Docs/blob/master/React%20Native/Screenshots/vscode_debugging.png)

### 2.1. 具体步骤：

1. 安装有效的iOS开发证书
2. 安装 [ios-deploy](https://www.npmjs.com/package/ios-deploy) `npm install -g ios-deploy`
3. launch.json 配置 target 为 设备名称，并添加 "runArguments": [ "--device"] 配置，或者直接添加 "runArguments": [ "--device", "设备名称" ] 配置
4. 摇晃设备，启动Debug JS Remotely
5. 如果iOS工程的 scheme 和 React Native 工程名称不一致，可以在 launch.json 添加 "scheme": "指定scheme" 配置

* ps：模拟器调试，仅需步骤4、5即可，具体配置如下。

* 完整 launch.json 配置文件：

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug iOS Simulator",
            "cwd": "${workspaceFolder}",
            "type": "reactnative",
            "request": "launch",
            "platform": "ios",
            "target": "模拟器名称",
            // "scheme": "指定scheme"
        },
        {
            "name": "Debug iOS Device1",
            "cwd": "${workspaceFolder}",
            "type": "reactnative",
            "request": "launch",
            "platform": "ios",
            "target": "设备名称",
            "runArguments": [ "--device"],
            // "scheme": "指定scheme"
        },
        {
            "name": "Debug iOS Device2",
            "cwd": "${workspaceFolder}",
            "type": "reactnative",
            "request": "launch",
            "platform": "ios",
            "runArguments": [ "--device", "设备名称" ],
            // "scheme": "指定scheme"
        }
    ]
}
```
