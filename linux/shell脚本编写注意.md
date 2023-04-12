## shell脚本注意点
```shell
#!/bin/bash

#1.输入重定向标准输入'结束符'注意,结束符必须顶格
#2.变量名统一用{}包含,以区分'$VARNAME','${VAR}NAME'
#3.SQL语句引用变量注意是否有单引号或双引号

sqlplus -s LS/LS <<EOF
INSERT INTO TEST VAULE('${ID}');
COMMIT;
EOF
#这里末尾EOF必须顶格写

```