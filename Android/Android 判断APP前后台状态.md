# Android 判断APP前后台状态

## 六种方法
-----

| 方法  | 原理                       | 权限 | 是否可判断其它APP前后台状态      | 特点                                                         |
| ----- | -------------------------- | ---- | -------------------------------- | ------------------------------------------------------------ |
| 方法1 | RunningTask                | 否   | Android 5.0以上不行              | 5.0此方法被废弃                                              |
| 方法2 | RunningProcess             | 否   | 当APP存在后台常驻的Service时失效 | 无                                                           |
| 方法3 | ActivityLifecycleCallbacks | 否   | 否                               | 简单有效，代码最少                                           |
| 方法4 | 读取/proc目录下的信息      | 否   | Android 7.0以上不行              | 7.0谷歌限制了/proc目录的访问<br />当proc目录下文件夹过多时，过多的IO操作会引起耗时 |
| 方法5 | UsageStatsManager          | 是   | 是                               | 仅首次需要用户授权权限，最符合Google规范的判断方法           |
| 方法6 | AccessibilityService       | 否   | 是                               | 需要用户授权辅助功能，会伴随应用被“强行停止”而剥夺辅助功能，导致需要用户重新授权辅助功能 |

具体各个方法的优缺点可以参考[AndroidProcess](https://github.com/wenmingvs/AndroidProcess)，这里不予展开详述。

