CREATE extension pg_jieba;
select * from to_tsquery('jiebacfg', '小明硕士毕业于中国科学院计算所，后在日本京都大学深造');
select * from to_tsquery('jiebaqry', '小明硕士毕业于中国科学院计算所，后在日本京都大学深造');