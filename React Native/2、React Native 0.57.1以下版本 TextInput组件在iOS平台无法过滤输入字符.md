# React Native 0.57.1以下版本 TextInput 组件在iOS平台无法过滤输入字符

# 1.问题现象
下面代码的作用是：输入框仅允许输入数字。在Android平台上可以正常工作，但在iOS平台上所有字符都会显示（直到输入另一个合法字符才会过滤掉其它非合法字符）。
```javascript
import React, { Component } from 'react';
import {Platform, Text, TextInput, SafeAreaView} from 'react-native';

export default class App extends Component {
  constructor(props) {
    super(props);
    
    this.state = { text: '' };
  }

  _onChangeText = (text) => {
    const newText = text.replace(/\D/g, ''); // 过滤掉非数字
    this.setState({ text: newText });
  };

  render() {
    return (
      <SafeAreaView style={{flex: 1, alignItems: 'center', justifyContent: 'center'}}>
        <TextInput
          ref={ref => this._textInput = ref}
          style={{ width: 250, height: 40, borderColor: 'gray', borderWidth: 1 }}
          onChangeText={this._onChangeText}
          value={this.state.text}
        />
       <Text style={{ marginTop: 20, width: 250, height: 40}}>{`过滤后：${this.state.text}`}</Text>
      </SafeAreaView>
    );
  }
}
```

|   图1  |  图2  |
|  ----  | ----  |
| ![textInput_bug1](https://github.com/cp110/Docs/blob/master/React%20Native/Screenshots/textInput_bug1.png) | ![textInput_bug2](https://github.com/cp110/Docs/blob/master/React%20Native/Screenshots/textInput_bug2.png) |

# 2.分析问题

如图1、图2所示，我们可以发现过滤掉非数字后**this.state.text**的值确实改变了，但**TextInput**显示的内容并没有改变。分析Objective-C源码可知**RCTBaseTextInputShadowView**的**_previousAttributedText**属性没有正确地比对值，造成**isAttributedTextChanged**过滤输入字符时永远是**NO**。

``` objective-c
BOOL isAttributedTextChanged = NO; // 过滤输入字符时永远 = NO
if (![_previousAttributedText isEqualToAttributedString:attributedText]) {// ←有问题
  isAttributedTextChanged = YES;
  _previousAttributedText = [attributedText copy];
}

NSNumber *tag = self.reactTag;

[_bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    RCTBaseTextInputView *baseTextInputView = (RCTBaseTextInputView *)viewRegistry[tag];
    if (!baseTextInputView) {
      return;
    }

    baseTextInputView.textAttributes = textAttributes;
    baseTextInputView.reactBorderInsets = borderInsets;
    baseTextInputView.reactPaddingInsets = paddingInsets;

    if (isAttributedTextChanged) {
      baseTextInputView.attributedText = attributedText;
    }
  }];
```

# 3.解决方案
## 3.1.运用双定时器（推荐）
clearTimer先清空输入框，setTimer再将输入框重新赋值
```javascript
_onChangeText = (text) => {
  const newText = text.replace(/\D/g, ''); // 过滤掉非数字
  
  if (Platform.OS === 'ios' && newText === this.state.text) {
    // ''解决图1输入不合法字符问题，' '解决图2首次输入不合法字符问题
    const clearText = newText === '' ? ' ' : '';
    this.clearTimer = setTimeout(() => { this._textInput.setNativeProps({text: clearText}); }, 10);
    this.setTimer = setTimeout(() => { this.setState({ text: newText }); }, 50);
  } else {
    this.setState({ text: newText });
  }
};

componentWillUnmount() {
  // 务必在卸载组件前清除定时器
  this.clearTimer && clearTimeout(this.clearTimer);
  this.setTimer && clearTimeout(this.setTimer);
}
```

* 优点：仅涉及项目本身代码，无需修改React Native源码，代码修改范围可控，版本稳定性可保证。
* 缺点：定时器对性能有一定影响。

## 3.2.修改RCTText组件的RCTBaseTextInputShadowView源码
可参考React Native 0.57.1版本RCTBaseTextInputShadowView源码

* 优点：修改底层源码可从根源解决输入字符过滤问题，性能可以自己把控。
* 缺点：每次 yarn 或 npm 操作都需要重新修改底层源码。

## 3.3.升级React Native到0.57.1及以上版本

* 优点：升级简单，官方出品。
* 缺点：版本升级涉及整个工程，涉及范围不可控，可能影响其它组件、模块的功能，风险太高，版本稳定性无法保证。
