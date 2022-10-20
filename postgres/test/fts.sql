create extension if not exists rum;
create extension if not exists pg_jieba;

alter table xmh_shop.shop_goods add column tsv tsvector;
create index rumidx_shop_goods_tsv on xmh_shop.shop_goods using rum(tsv rum_tsvector_ops);

CREATE OR REPLACE FUNCTION shop_goods_tsv_trigger() RETURNS trigger AS $$
begin
      new.tsv := setweight(to_tsvector('jiebaqry', coalesce(new.goods_name,'')), 'C')
              || setweight(array_to_tsvector(regexp_split_to_array(coalesce(new.keywords,''), '\s+')), 'A')
           -- || setweight(to_tsvector('jiebaqry', coalesce(new.description,'')), 'b')
              ;
      return new;
end
$$ LANGUAGE plpgsql;

CREATE TRIGGER shop_goods_tsv_update BEFORE INSERT OR UPDATE
    ON xmh_shop.shop_goods FOR EACH ROW EXECUTE PROCEDURE shop_goods_tsv_trigger();

update xmh_shop.shop_goods set tsv = null;
-- UPDATE xmh_shop.shop_goods set tsv = setweight(to_tsvector('jiebaqry', coalesce(goods_name,'')), 'B')
--     || setweight(array_to_tsvector(regexp_split_to_array(coalesce(keywords,''), '\s+')), 'A');


-- 同义词
select * from ts_debug('jiebacfg', '当一个词典配置文件第一次在数据库会话中使');
select ts_lexize('jieba_syn', '男式');
create text search dictionary jieba_syn (template = synonym, synonyms='synonym_sample');
-- alter text search dictionary jieba_syn (synonyms='jieba_synonym');
create text search configuration my_qry (copy = jiebaqry);
alter text search configuration my_qry alter mapping for eng,an,nz,n,v,a,i,e,l,x with jieba_syn,jieba_stem;

create extension if not exists dict_xsyn;
-- create text search dictionary jieba_syn (template = xsyn_template, rules='xsyn_sample', keeporig=false, MATCHSYNONYMS=true);
-- 安装dict_xsyn扩展会用默认参数创建一个文本搜索模板xsyn_template以及一个基于它的词典xsyn
ALTER TEXT SEARCH DICTIONARY xsyn (RULES='xsyn_sample', KEEPORIG=true, matchsynonyms=true);
select ts_lexize('xsyn', 'sn');
create text search configuration xqry (copy = jiebaqry);
alter text search configuration xqry alter mapping for eng,an,nz,n,v,a,i,e,l,x with xsyn,jieba_stem;


/*
with ts as ( select to_tsquery('jiebaqry', 'hello') as q) select goods_name, keywords, tsv from ts, xmh_shop.shop_goods where tsv @@ ts.q order by tsv <=> ts.q limit 100 ;


with ts as (
  select to_tsquery('jiebaqry', 'hello') as q
) select
    ts_headline('jiebaqry', goods_name, ts.q, 'StartSel = {{, StopSel = }}') ,
    description, tsv
from ts, xmh_shop.shop_goods where tsv @@ ts.q
order by tsv <=> ts.q
--limit 100
;
*/
