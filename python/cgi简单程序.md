1.html文件
```html
<html>
<head>
<title>hello</title>
<body>
<form action='/cgi-bin/hello.py'>
<b>输入你的名字</b>
<input type='text'name='person' value='new person' size=15>
<input type='submit' value='提交'>
</form>
</body>
</head>
</html>
```
2.python脚本
```py
#!/usr/bin/env python3.7
# -*- coding:utf-8 -*-
'''
CGI(Comman Gateway Interface):通用网关接口.
WSGI(Web Server Gateway Interface):web服务器网关接口

本地构建CGI应用服务器：python -m http.server --cgi 8080
'''
import cgi,cgitb

cgitb.enable()  #从浏览器中看到web应用程序的回溯信息
fs = cgi.FieldStorage()#实例化会产生一个类似字典的对象,键就是表单中的名称,值是表单中的值,可能是一个FieldStorage,MiniFieldStorage,list
name = fs.getvalue('person')

print ("Content-type:text/html\r\n\r\n")
print ("<html>")
print ("<head>")
print ("<title>Hello - Second CGI Program</title>")
print ("</head>")
print ("<body>")
print ("<h2>Hello %s %s</h2>" % name)
print ("</body>")
print ("</html>")
```
3.修改http.conf
```
    把ServerName改为IP地址加端口号
```
