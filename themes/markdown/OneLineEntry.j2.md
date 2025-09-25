    {
      "type": "indent",
      "indent": 2,
      "content": [
        {
          "type": "table",
          "properties": { "type": "tableproperty", "align": "l" },
          "columns": [
            { "type": "columnproperty", "align": "l", "size": { "mode": "fixed", "value": 0 } },
            { "type": "columnproperty", "align": "l", "size": { "mode": "flex" , "value": 1 }, "overflow": "wrap" }
          ],
          "rows": [
            [
              { "type": "text", "value": "<<entry.label>>:", "styles": [{ "$ref": "#/styles/title" }] },
              { "type": "text", "value": "<<entry.details>>", "styles": [{ "$ref": "#/styles/prim" }] }
            ]
          ]
        }
      ]
    },


