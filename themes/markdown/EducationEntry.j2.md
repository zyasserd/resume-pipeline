    // institution, location
    {
      "type": "table",
      "properties": { "type": "tableproperty", "align": "l" },
      "columns": [
        { "type": "columnproperty", "align": "l", "size": { "mode": "flex", "value": 1 }, "overflow": "wrap" },
        { "type": "columnproperty", "align": "r", "size": { "mode": "fixed", "value": 0 } }
      ],
      "rows": [
        [
          { "type": "text", "value": "<<entry.institution>>", "styles": [{ "$ref": "#/styles/title" }] },
          { "type": "text", "value": "<<entry.location>>", "styles": [{ "$ref": "#/styles/sec" }] }
        ]
      ]
    },

    // degree, area, date
    {
      "type": "table",
      "properties": { "type": "tableproperty", "align": "l" },
      "columns": [
        { "type": "columnproperty", "align": "l", "size": { "mode": "flex", "value": 1 } },
        { "type": "columnproperty", "align": "r", "size": { "mode": "fixed", "value": 0 } }
      ],
      "rows": [
        [
          { "type": "text", "value": "<<entry.degree>> in <<entry.area>>", "styles": [{ "$ref": "#/styles/subtitle" }] },
          { "type": "text", "value": "<<entry.date_string>>", "styles": [{ "$ref": "#/styles/sec" }] }
        ]
      ]
    },

    ((* for item in entry.highlights *))
    {
      "type": "indent",
      "indent": 4,
      "content": [
        {
          "type": "table",
          "properties": { "type": "tableproperty", "align": "l" },
          "columns": [
            { "type": "columnproperty", "align": "l", "size": { "mode": "fixed", "value": 1 } },
            { "type": "columnproperty", "align": "l", "size": { "mode": "flex" , "value": 1 }, "overflow": "wrap" }
          ],
          "rows": [
            [
              { "type": "text", "value": ">" },
              { "type": "text", "value": "<<item>>", "styles": [{ "$ref": "#/styles/prim" }] }
            ]
          ]
        }
      ]
    },
    ((* endfor *))
    { "type": "br" },


