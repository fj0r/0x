```
api:
    PathSubTree("/api") -> modPath("/api", "/") -> "http://frontend";
static:
    PathSubTree("/") -> static("/", "/srv") -> <shunt>;
```
