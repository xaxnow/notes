```python
'''
    查询得到的结果称为QuerySet,__双下划线:跨越对象关系(join)或匹配比较等

    创建对象,插入了一条记录: b = Blog(*args)

    提交:b.save()  

    更新:b = Blog.objects.get(*args).update()

    检索所有对象:all = Blog.objects.all()

    过滤:Blog.objects.filter(**kwargs)

    排除:Blog.objects.exclude(**kwargs)

    过滤和排除组合:Blog.filter(**kwargs).exclude(**kwargs)...

    检索一个对象:Blog.objects.get()

    使用切片限制QuerySet结果数量(不支持负索引):Blog.objects.all()[2:5]

    匹配:精确匹配:Blog.objects.get(title__exact='...')
         忽略大小写:Blog.objects.get(title__iexact='...')
         '%字符%':Blog.objects.get(title__[i]contains='...')
         [i]startwith,[i]endwith

    join,如Blog和Entry对象:Blog.objects.filter(entry__title='test'),模型名小写+__+属性+[__isnull=True],多个则加多个模型名

    过滤器引用模型字段运算,F():from django.db.models import F 
                                Blog.objects.filter(n_comments__gt=F('n_pingbacks')*2)
                            可以执行加减乘除模运算,幂运算等
                            F().bitand()等位运算

    主键pk:相当于Blog.objects.get(pk=1)或id=1

    like语句转义%和_:Blog.objects.filter(title__contains='%')

    缓存和QuerySets:
            在新创建的QuerySet中，缓存是空的。当查询集第一次被求值时(因此会发生数据库查询)，Django将查询结果保存在查询集的缓存中，并返回显式请求的结果(例如，如果正在迭代查询集，则返回下一个元素)。QuerySet后续评估重用缓存的结果
'''
>>> print([e.headline for e in Entry.objects.all()])
>>> print([e.pub_date for e in Entry.objects.all()])
'''
这意味着相同的数据库查询将执行两次，有效地使数据库负载加倍。此外，两个列表可能不包含相同的数据库记录，因为Entry可能已在两个请求之间的分秒中添加或删除。
'''
#避免这个问题
>>> queryset = Entry.objects.all()
>>> print([p.headline for p in queryset]) # Evaluate the query set.
>>> print([p.pub_date for p in queryset]) # Re-use the cache from the evaluation.
'''
查询集并不总是缓存其结果。仅评估部分查询集时，将检查缓存，但如果未填充，则不会缓存后续查询返回的项目。
'''
#所以要使用缓存应该:
>>>queryset = Entry.objects.all()
>>>[entry for entry in queryset]
'''
使用Q对象复杂查找:如or,&,|
'''
>>>from django.db.models import Q
>>>Q(...)|Q(...)    #或
'''
比较对象: ==

删除对象: delete()
'''
```
