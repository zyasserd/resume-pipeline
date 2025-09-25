    // title, date
    {
      "type": "table",
      "properties": { "type": "tableproperty", "align": "l" },
      "columns": [
        { "type": "columnproperty", "align": "l", "size": { "mode": "flex", "value": 1 }, "overflow": "wrap" },
        { "type": "columnproperty", "align": "r", "size": { "mode": "fixed", "value": 0 } }
      ],
      "rows": [
        [
          { "type": "text", "value": "<<entry.title>>", "styles": [{ "$ref": "#/styles/title" }] },
          { "type": "text", "value": "<<entry.date_string>>", "styles": [{ "$ref": "#/styles/sec" }] }
        ]
      ]
    },

    {
      "type": "indent",
      "indent": 4,
      "content": [
        // authors
        {
          "type": "table",
          "properties": { "type": "tableproperty", "align": "l" },
          "columns": [
            { "type": "columnproperty", "align": "l", "size": { "mode": "flex" , "value": 1 }, "overflow": "wrap" }
          ],
          "rows": [
            [
              { "type": "text", "value": "<<entry.authors|join(", ")>>", "styles": [{ "$ref": "#/styles/prim" }] }
            ]
          ]
        },

        // link
        {
          "type": "table",
          "properties": { "type": "tableproperty", "align": "l" },
          "columns": [
            { "type": "columnproperty", "align": "l", "size": { "mode": "flex" , "value": 1 }, "overflow": "wrap" }
          ],
          "rows": [
            [
              {
                "type": "text",
                "value": "((* if entry.doi *))<<entry.doi>>((* elif entry.url *))<<entry.url>>((* endif *))",
                "styles": [
                    { "$ref": "#/styles/prim" },
                    { "type": "style", "link": "((* if entry.doi *))<<entry.doi_url>>((* elif entry.url *))<<entry.clean_url>>((* endif *))" }
                ] 
              }
            ]
          ]
        },
      ]
    },
    { "type": "br" },


