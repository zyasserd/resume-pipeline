{
  "$schema": "https://github.com/zyasserd/json2ansi/blob/main/src/json2ansi/schema.json?raw=true",
  // Define styles here
  "styles": {
    "title": { "type": "style", "fg": "#ffaf5f", "bold": true },
    "subtitle": { "type": "style", "fg": "#87d787", "italic": true },
    "prim": { "type": "style", "fg": "#87d7ff" },
    "sec": { "type": "style", "fg": "#d7afd7" }
  },
  "content": [

<<header>>

((* for section_beginning, entries in sections*))
<<section_beginning>>

    ((* for entry in entries *))
<<entry>>
    ((* endfor *))
((* endfor *))


  ]
}
