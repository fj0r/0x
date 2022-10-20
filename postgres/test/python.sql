CREATE extension plpython3u;

CREATE or REPLACE FUNCTION py_ver() RETURNS setof text as $$
import sys
import httpx
import yaml
import functools
import more_itertools as mi
import pyparsing
import numpy as np
import pandas as pd
import cachetools
import subprocess as subp
m = sys.modules
yield sys.version
yield '--------'
for i in m.keys():
    yield i
$$ LANGUAGE plpython3u;

SELECT py_ver();

-- pg_test httpx
CREATE or REPLACE FUNCTION py_requests_get(url TEXT) RETURNS setof text as $$
import httpx
yield httpx.get(url).text
$$ LANGUAGE plpython3u;

SELECT py_requests_get('http://www.baidu.com');
