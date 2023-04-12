同步IO和异步IO:同步,等待事件的完成.异步,不等待事件的完成
### 文件读写:接口都是由操作系统提供的

open函数:https://docs.python.org/3/library/functions.html#open

读文件:open->read->close.读是把文件读到内存

with语句:自动调用close()
with open('/path/to/file', 'r') as f:
    print(f.read())

read()会一次把全部读取出来,文件大了内存会爆.
read(size)一次读取size个字节.readline()一次读取一行,readlines()一次读取所有行并返回一个list

file-like Object:有read()的对象
二进制:open('./...','rb')
字符编码:open('./...','r',encoding='UTF-8',error='ignore')
写文件:open('./...','w')或'wb',f.write('...')

### StringIO和BytesIO
```python
#数据写不一定是文件,也可以是在内存,所以StringIO是在内存中写
from io import StringIO/BytesIO
f=StringIO()/BytesIO()
f.write("hello")
f.getvalue()#获得写入后的str
#也可以用string/bytes初始化IO来读
>>> from io import BytesIO
>>> f = BytesIO(b'\xe4\xb8\xad\xe6\x96\x87')
>>> f.read()
```
### 操作文件和目录
`import os`
### 序列化
```python
#把变量从内存中变成可存储或可传输的过程,在python中叫picking
import pickle
d = dict(name='Bob', age=20, score=88)
b=pickle.dumps(d)#还存在内存中
with open('test','wb') as f:#使用二进制的方式写入内存中的数据
    f.write(b)
#或者pickle.dump()直接把对象序列化后写入一个file-like Object
with open('t','wb') as f2:
    pickle.dump(d,f2)

#反序列化:
r = open('test', 'rb')#二进制方式读
rd = pickle.load(r)#反序列化到内存
r.close()#关闭文件
print(rd)#已经反序列化到内存了
#或者使用pickle.load()方法从一个file-like Object中直接反序列化出对象
```
### JSON
```python
'''
如果我们要在不同的编程语言之间传递对象，就必须把对象序列化为标准格式，比如XML，但更好的方法是序列化为JSON，
因为JSON表示出来就是一个字符串，可以被所有语言读取，也可以方便地存储到磁盘或者通过网络传输。JSON不仅是标准格式，
并且比XML更快，而且可以直接在Web页面中读取，非常方便
JSON类型	Python类型
    {}	        dict
    []	        list
    "string"	str
    1234.56	    int或float
    true/false	True/False
    null	    None
dumps()方法返回一个str，内容就是标准的JSON。类似的，dump()方法可以直接把JSON写入一个file-like Object
JSON反序列化为Python对象，用loads()或者对应的load()方法，前者把JSON的字符串反序列化，后者从file-like Object中读取字符串并反序列化
'''
import json
di={'a':b,'c':d}
dictionary=dict(name='ks',age=23)
j = json.dumps(dictionary)
print("j:",j)
#反序列化json为python对象
json_str='{"name": "ks", "age": 23}'
pickle_json = json.loads(json_str)
print(pickle_json

#进阶把实例转化为json对象
```