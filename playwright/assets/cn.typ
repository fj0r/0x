#let 字号 = (
  初号: 42pt,
  小初: 36pt,
  一号: 26pt,
  小一: 24pt,
  二号: 22pt,
  小二: 18pt,
  三号: 16pt,
  小三: 15pt,
  四号: 14pt,
  中四: 13pt,
  小四: 12pt,
  五号: 10.5pt,
  小五: 9pt,
  六号: 7.5pt,
  小六: 6.5pt,
  七号: 5.5pt,
  小七: 5pt,
)

#let 字体 = (
  仿宋: ("Times New Roman", "FangSong", "Noto Serif CJK SC"),
  宋体: ("Times New Roman", "SimSun", "Noto Serif CJK SC"),
  黑体: ("Times New Roman", "SimHei", "Noto Sans CJK SC"),
  楷体: ("Times New Roman", "KaiTi", "Noto Sans CJK SC"),
  代码: ("Jetbrains Mono", "New Computer Modern Mono", "Times New Roman", "SimSun"),
)

#let img(path) = align(center)[#image(path, width: 80%)]
#let screenshot(path, desc) = {
  figure(
    image(path, height: 20%),
    numbering: none,
    caption: desc,
  )
}

#let tt(text) = align(center)[= #text]

#let y(n) = [#sub[$yen$]#n]

#let conf(
    auth: "",
    audient: "",
    title,
    doc
) = {

  tt(title)

  set text(字号.小四, font: 字体.宋体, lang: "zh")

  set list(indent: 2em)
  set enum(indent: 2em)
  set par(first-line-indent: 2em, leading: 1em)
  show par: set block(spacing: 1em)


  if audient.len() > 0 {
    [ * #audient :* ]
  }

  doc

  set align(right)
  if auth.len() > 0 {
    [
      #auth
    ]
  }
  datetime.today().display("[year]年[month]月[day]日")
}
