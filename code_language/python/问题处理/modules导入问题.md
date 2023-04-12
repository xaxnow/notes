# 问题处理
## modules安装问题
### 原因
1. 墙的原因:需使用镜像
2. 代理原因:关闭代理或使用全局模式
## modules导入问题
[https://docs.python.org/zh-cn/3/tutorial/modules.html](https://docs.python.org/zh-cn/3/tutorial/modules.html)

### 导入modules原理
Python 在导入模块时，会从一下路径进行查询：
1. 程序的主目录（或未指定文件时的当前目录）
2. PTYHONPATH目录（如果已经进行了设置）
3. 标准连接库目录The installation-dependent default (by convention including a `site-packages` directory, handled by the site module).
   
以上三个目录组成了一个list，可通过sys.path来查看
在导包时就会从sys.path中进行搜索，如果搜索不到，则报ImportError

### 解决办法
思路：
1. 将需要导入的包或者模块添加到PTYHONPATH目录(不推荐)
2. 将需要导入的包或者模块添加到sys.path中

```python
import os.path
import sys
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))    
sys.path.append(BASE_DIR)
```