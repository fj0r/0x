#let project(
  title: "",
  authors: (),
  abstract: none,
  keywords: (),
  body
) = {
  let zh_shusong = ("FZShuSong-Z01", "FZShuSong-Z01S", "SimSun", "Noto Serif CJK SC")
  let zh_xiaobiansong = ("FZXiaoBiaoSong-B05", "FZXiaoBiaoSong-B05S", "SimSun", "Noto Serif CJK SC")
  let zh_kai = ("FZKai-Z03", "FZKai-Z03S", "KaiTi", "Noto Sans CJK SC")
  let zh_hei = ("FZHei-B01", "FZHei-B01S", "SimHei", "Noto Sans CJK SC")
  let zh_fangsong = ("FZFangSong-Z02", "FZFangSong-Z02S", "FangSong", "Noto Serif CJK SC")
  let en_sans_serif = "Georgia"
  let en_serif = "Times New Roman"
  let en_typewriter = "Courier New"
  let en_code = "Menlo"
  // Moidfy the following to change the font.
  let title-font = (en_serif, ..zh_hei)
  let author-font = (en_typewriter, ..zh_fangsong)
  let body-font = (en_serif, ..zh_shusong)
  let heading-font = (en_serif, ..zh_xiaobiansong)
  let caption-font = (en_serif, ..zh_kai)
  let header-font = (en_serif, ..zh_kai)
  let strong-font = (en_serif, ..zh_hei)
  let emph-font = (en_serif, ..zh_kai)
  let raw-font = (en_code, ..zh_hei)

  let config = yaml("../config.yaml")
  let authors = config.authors
  
  set document(author: authors.map(author => author.name), title: title)

  let auth = authors.map(author => if "organization" in author {
      (author.organization, author.name).join("/")
  } else {
      author.name
  }).join("  ")

  set page(numbering: "1", number-align: center, header: box(
    width: 100%,
    inset: (x: 10pt, y: 5pt),
    stroke:(bottom: 0.5pt + black)
  )[
    #set text(font: header-font)
    #title #h(1fr) #auth
  ])
  set text(font: body-font, lang: "zh", region: "cn")
  
  show heading: it => box(width: 100%)[
    #v(0.50em)
    #set text(font: heading-font)
    #if it.numbering != none { counter(heading).display() }
    #h(0.75em)
    #it.body
  ]

  show heading.where(
    level: 1
  ): it => box(width: 100%)[
    #v(0.5em)
    #it
    #v(0.75em)
  ]

  v(2em, weak: true)

  // Main body
  set par(first-line-indent: 2em)
  set enum(indent: 2em)
  set list(indent: 2em)
  set figure(gap: 0.8cm)

  // 定义空白段，解决首段缩进问题
  let blank_par = par()[#text()[#v(0em, weak: true)];#text()[#h(0em)]]

  show figure: it => [
    #v(12pt)
    #set text(font: caption-font)
    #it
    #blank_par
    #v(12pt)
  ]

  show image: it => [
    #it
    #blank_par
  ]

  show list: it => [
    #it
    #blank_par
  ]

  show enum: it => [
    #it
    #blank_par
  ]

  show table: it => [
    #set text(font: body-font)
    #it
    #blank_par
  ]
  show strong: set text(font: strong-font)
  show emph: set text(font: emph-font)
  show ref: set text(red)
  show raw.where(block: true): block.with(
    width: 100%,
    fill: luma(240),
    inset: 10pt,
  )

  show raw.where(block: true): it => [
    #it
    #blank_par
  ]

  show raw: set text(font: raw-font)
  show link: underline
  show link: set text(blue)

  body
}
