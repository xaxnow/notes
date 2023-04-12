```python
#变量:{{ arg }},字典查找,属性查找,列表索引用点表示:
{{ my_dict.key }}
{{my_objects.attribute }}
{{ my_list.0 }}

#标签:{% str %},内置标签或自定义标签

#过滤器:内置过滤器或自定义过滤器
{{ django|title }}

#注释:
{# 一行注释 #}
{% 多行注释 %}

```